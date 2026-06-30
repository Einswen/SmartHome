package com.smarthome.api.home;

import com.smarthome.api.common.ApiException;
import com.smarthome.api.home.HomeDtos.ActiveStateRequest;
import com.smarthome.api.home.HomeDtos.DeviceActionRequest;
import com.smarthome.api.home.HomeDtos.DeviceStatePatch;
import com.smarthome.api.home.HomeDtos.RoomDeviceUpdateRequest;
import com.smarthome.api.home.HomeDtos.SectionUpdateRequest;
import java.time.Instant;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class HomeStateService {
  private final HomeStateRepository repository;
  private final DefaultHomeStateFactory defaults;

  public HomeStateService(HomeStateRepository repository, DefaultHomeStateFactory defaults) {
    this.repository = repository;
    this.defaults = defaults;
  }

  @Transactional
  public HomeStateDto ensureState(long userId) {
    return repository.find(userId).orElseGet(() -> {
      HomeStateDto state = defaults.create();
      repository.insert(userId, state);
      return state;
    });
  }

  public HomeStateDto getState(long userId) {
    return repository.find(userId).orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "家庭数据不存在"));
  }

  @Transactional
  public HomeStateDto replaceState(long userId, HomeStateDto state) {
    HomeStateDto next = touch(state);
    repository.save(userId, next);
    repository.logAction(userId, null, "replace_state", Map.of("source", "client_snapshot"), "accepted");
    return next;
  }

  @Transactional
  public HomeStateDto updateSection(long userId, String section, SectionUpdateRequest request) {
    HomeStateDto state = getState(userId);
    HomeStateDto next = switch (section) {
      case "rooms" -> withRooms(state, castList(request.value()));
      case "roomDevices" -> withRoomDevices(state, castList(request.value()));
      case "deviceStates" -> withDeviceStates(state, castList(request.value()));
      case "scenes" -> withScenes(state, castList(request.value()));
      case "automations" -> withAutomations(state, castList(request.value()));
      case "notifications" -> withNotifications(state, castList(request.value()));
      case "agentRecords" -> withAgentRecords(state, castList(request.value()));
      case "agentMessages" -> withAgentMessages(state, castList(request.value()));
      case "preferences" -> withPreferences(state, castMap(request.value()));
      default -> throw new ApiException(HttpStatus.BAD_REQUEST, "未知数据段: " + section);
    };
    next = touch(next);
    repository.save(userId, next);
    repository.logAction(userId, null, "update_" + section, request, "accepted");
    return next;
  }

  @Transactional
  public HomeStateDto updateDeviceState(long userId, String pointId, DeviceStatePatch patch) {
    HomeStateDto state = getState(userId);
    List<Map<String, Object>> states = copyList(state.deviceStates());
    Map<String, Object> target = null;
    for (Map<String, Object> item : states) {
      if (pointId.equals(String.valueOf(item.get("pointId")))) {
        target = item;
        break;
      }
    }
    if (target == null) {
      target = new LinkedHashMap<>();
      target.put("pointId", pointId);
      target.put("on", patch.on() != null ? patch.on() : true);
      target.put("value", patch.value() != null ? patch.value() : 0);
      states.add(target);
    }
    applyDevicePatch(target, patch.on(), patch.value(), patch.command(), patch.extra());
    HomeStateDto next = touch(withDeviceStates(state, states));
    repository.save(userId, next);
    repository.logAction(userId, pointId, "device_state_patch", patch, "accepted");
    return next;
  }

  @Transactional
  public HomeStateDto acceptDeviceAction(long userId, DeviceActionRequest request) {
    DeviceStatePatch patch = new DeviceStatePatch(request.on(), request.value(), request.command(), request.extra());
    HomeStateDto next = updateDeviceState(userId, request.pointId(), patch);
    repository.logAction(userId, request.pointId(), request.actionType(), request, "queued");
    return next;
  }

  @Transactional
  public HomeStateDto updateRoomDevices(long userId, RoomDeviceUpdateRequest request) {
    HomeStateDto state = getState(userId);
    List<Map<String, Object>> roomDevices = copyList(state.roomDevices());
    boolean updated = false;
    for (Map<String, Object> item : roomDevices) {
      if (request.roomId().equals(String.valueOf(item.get("roomId")))) {
        item.put("pointIds", request.pointIds());
        updated = true;
      }
    }
    if (!updated) {
      roomDevices.add(map("roomId", request.roomId(), "pointIds", request.pointIds()));
    }
    HomeStateDto next = touch(withRoomDevices(state, roomDevices));
    repository.save(userId, next);
    repository.logAction(userId, null, "room_devices_update", request, "accepted");
    return next;
  }

  @Transactional
  public HomeStateDto updateActiveState(long userId, ActiveStateRequest request) {
    HomeStateDto state = getState(userId);
    HomeStateDto next = new HomeStateDto(
        state.rooms(),
        state.roomDevices(),
        state.deviceStates(),
        state.scenes(),
        state.automations(),
        state.notifications(),
        state.agentRecords(),
        state.agentMessages(),
        state.preferences(),
        request.activeRoomId() == null ? state.activeRoomId() : request.activeRoomId(),
        request.activeSceneId() == null ? state.activeSceneId() : request.activeSceneId(),
        request.isNight() == null ? state.isNight() : request.isNight(),
        request.manualPeriod() == null ? state.manualPeriod() : request.manualPeriod(),
        Instant.now()
    );
    repository.save(userId, next);
    repository.logAction(userId, null, "active_state_update", request, "accepted");
    return next;
  }

  private void applyDevicePatch(Map<String, Object> target, Boolean on, Integer value, String command, Map<String, Object> extra) {
    if (command != null && !command.isBlank()) {
      if ("on".equals(command)) {
        target.put("on", true);
      } else if ("off".equals(command)) {
        target.put("on", false);
      } else {
        target.put("command", command);
      }
    }
    if (on != null) {
      target.put("on", on);
    }
    if (value != null) {
      target.put("value", value);
    }
    if (extra != null) {
      target.put("extra", extra);
    }
    target.put("updatedAt", Instant.now().toString());
  }

  private HomeStateDto touch(HomeStateDto state) {
    return new HomeStateDto(
        state.rooms(), state.roomDevices(), state.deviceStates(), state.scenes(), state.automations(),
        state.notifications(), state.agentRecords(), state.agentMessages(), state.preferences(),
        state.activeRoomId(), state.activeSceneId(), state.isNight(), state.manualPeriod(), Instant.now()
    );
  }

  private HomeStateDto withRooms(HomeStateDto state, List<Map<String, Object>> value) {
    return new HomeStateDto(value, state.roomDevices(), state.deviceStates(), state.scenes(), state.automations(), state.notifications(), state.agentRecords(), state.agentMessages(), state.preferences(), state.activeRoomId(), state.activeSceneId(), state.isNight(), state.manualPeriod(), state.updatedAt());
  }

  private HomeStateDto withRoomDevices(HomeStateDto state, List<Map<String, Object>> value) {
    return new HomeStateDto(state.rooms(), value, state.deviceStates(), state.scenes(), state.automations(), state.notifications(), state.agentRecords(), state.agentMessages(), state.preferences(), state.activeRoomId(), state.activeSceneId(), state.isNight(), state.manualPeriod(), state.updatedAt());
  }

  private HomeStateDto withDeviceStates(HomeStateDto state, List<Map<String, Object>> value) {
    return new HomeStateDto(state.rooms(), state.roomDevices(), value, state.scenes(), state.automations(), state.notifications(), state.agentRecords(), state.agentMessages(), state.preferences(), state.activeRoomId(), state.activeSceneId(), state.isNight(), state.manualPeriod(), state.updatedAt());
  }

  private HomeStateDto withScenes(HomeStateDto state, List<Map<String, Object>> value) {
    return new HomeStateDto(state.rooms(), state.roomDevices(), state.deviceStates(), value, state.automations(), state.notifications(), state.agentRecords(), state.agentMessages(), state.preferences(), state.activeRoomId(), state.activeSceneId(), state.isNight(), state.manualPeriod(), state.updatedAt());
  }

  private HomeStateDto withAutomations(HomeStateDto state, List<Map<String, Object>> value) {
    return new HomeStateDto(state.rooms(), state.roomDevices(), state.deviceStates(), state.scenes(), value, state.notifications(), state.agentRecords(), state.agentMessages(), state.preferences(), state.activeRoomId(), state.activeSceneId(), state.isNight(), state.manualPeriod(), state.updatedAt());
  }

  private HomeStateDto withNotifications(HomeStateDto state, List<Map<String, Object>> value) {
    return new HomeStateDto(state.rooms(), state.roomDevices(), state.deviceStates(), state.scenes(), state.automations(), value, state.agentRecords(), state.agentMessages(), state.preferences(), state.activeRoomId(), state.activeSceneId(), state.isNight(), state.manualPeriod(), state.updatedAt());
  }

  private HomeStateDto withAgentRecords(HomeStateDto state, List<Map<String, Object>> value) {
    return new HomeStateDto(state.rooms(), state.roomDevices(), state.deviceStates(), state.scenes(), state.automations(), state.notifications(), value, state.agentMessages(), state.preferences(), state.activeRoomId(), state.activeSceneId(), state.isNight(), state.manualPeriod(), state.updatedAt());
  }

  private HomeStateDto withAgentMessages(HomeStateDto state, List<Map<String, Object>> value) {
    return new HomeStateDto(state.rooms(), state.roomDevices(), state.deviceStates(), state.scenes(), state.automations(), state.notifications(), state.agentRecords(), value, state.preferences(), state.activeRoomId(), state.activeSceneId(), state.isNight(), state.manualPeriod(), state.updatedAt());
  }

  private HomeStateDto withPreferences(HomeStateDto state, Map<String, Object> value) {
    return new HomeStateDto(state.rooms(), state.roomDevices(), state.deviceStates(), state.scenes(), state.automations(), state.notifications(), state.agentRecords(), state.agentMessages(), value, state.activeRoomId(), state.activeSceneId(), state.isNight(), state.manualPeriod(), state.updatedAt());
  }

  private List<Map<String, Object>> copyList(List<Map<String, Object>> source) {
    List<Map<String, Object>> copy = new ArrayList<>();
    for (Map<String, Object> item : source) {
      copy.add(new LinkedHashMap<>(item));
    }
    return copy;
  }

  @SuppressWarnings("unchecked")
  private List<Map<String, Object>> castList(Object value) {
    if (value instanceof List<?> list) {
      return (List<Map<String, Object>>) list;
    }
    throw new ApiException(HttpStatus.BAD_REQUEST, "数据段必须是数组");
  }

  @SuppressWarnings("unchecked")
  private Map<String, Object> castMap(Object value) {
    if (value instanceof Map<?, ?> map) {
      return (Map<String, Object>) map;
    }
    throw new ApiException(HttpStatus.BAD_REQUEST, "数据段必须是对象");
  }

  private Map<String, Object> map(Object... entries) {
    Map<String, Object> result = new LinkedHashMap<>();
    for (int i = 0; i < entries.length; i += 2) {
      result.put(String.valueOf(entries[i]), entries[i + 1]);
    }
    return result;
  }
}
