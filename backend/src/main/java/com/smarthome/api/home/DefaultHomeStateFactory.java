package com.smarthome.api.home;

import java.time.Instant;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Component;

@Component
public class DefaultHomeStateFactory {
  public HomeStateDto create() {
    return new HomeStateDto(
        new ArrayList<>(),
        new ArrayList<>(),
        new ArrayList<>(),
        new ArrayList<>(),
        new ArrayList<>(),
        new ArrayList<>(),
        new ArrayList<>(),
        new ArrayList<>(),
        defaultPreferences(),
        "",
        "",
        false,
        false,
        Instant.now()
    );
  }

  private List<Map<String, Object>> defaultRooms() {
    List<Map<String, Object>> rooms = new ArrayList<>();
    rooms.add(room("living", "客厅", "会客、影音、空气联动", true));
    rooms.add(room("bedroom", "卧室", "睡眠、温控、安防联动", true));
    return rooms;
  }

  private List<Map<String, Object>> defaultRoomDevices() {
    List<Map<String, Object>> rooms = new ArrayList<>();
    rooms.add(map("roomId", "living", "pointIds", List.of(
        "living@living_air", "living@living_curtain", "living@living_tv",
        "living@living_purifier", "living@living_robot", "living@living_light"
    )));
    rooms.add(map("roomId", "bedroom", "pointIds", List.of(
        "bedroom@bedroom_air", "bedroom@bedroom_curtain", "bedroom@bedroom_left_light",
        "bedroom@bedroom_right_light", "bedroom@bedroom_robot", "bedroom@bedroom_door"
    )));
    return rooms;
  }

  private List<Map<String, Object>> defaultDeviceStates() {
    List<Map<String, Object>> states = new ArrayList<>();
    states.add(deviceState("living@living_air", true, 24));
    states.add(deviceState("living@living_curtain", true, 46));
    states.add(deviceState("living@living_tv", false, 0));
    states.add(deviceState("living@living_purifier", true, 70));
    states.add(deviceState("living@living_robot", false, 86));
    states.add(deviceState("living@living_light", false, 68));
    states.add(deviceState("bedroom@bedroom_air", true, 23));
    states.add(deviceState("bedroom@bedroom_curtain", true, 58));
    states.add(deviceState("bedroom@bedroom_left_light", false, 22));
    states.add(deviceState("bedroom@bedroom_right_light", false, 22));
    states.add(deviceState("bedroom@bedroom_robot", false, 91));
    states.add(deviceState("bedroom@bedroom_door", true, 100));
    return states;
  }

  private List<Map<String, Object>> defaultScenes() {
    List<Map<String, Object>> scenes = new ArrayList<>();
    scenes.add(scene("morning", "早安", "开帘与日间", "晨", "morning"));
    scenes.add(scene("arrive", "回家", "灯光与空气", "家", "arrive"));
    scenes.add(scene("movie", "观影", "客厅联动", "影", "movie"));
    scenes.add(scene("sleep", "睡眠", "夜间静音", "夜", "sleep"));
    scenes.add(scene("pet", "宠物模式", "看护与通风", "宠", "pet"));
    return scenes;
  }

  private List<Map<String, Object>> defaultAutomations() {
    List<Map<String, Object>> automations = new ArrayList<>();
    automations.add(map(
        "id", "auto_leave",
        "title", "离家断电",
        "trigger", "离家定位或手动点击离家场景",
        "action", "关闭客厅电视、空气净化器和主灯",
        "source", "agent",
        "enabled", true,
        "triggerSpec", map("type", "presence", "label", "离家定位或手动点击离家场景"),
        "actions", List.of(
            map("pointId", "living_tv", "command", "off", "label", "关闭客厅电视"),
            map("pointId", "living_purifier", "command", "off", "label", "关闭空气净化器"),
            map("pointId", "living_light", "command", "off", "label", "关闭客厅主灯")
        )
    ));
    automations.add(map(
        "id", "auto_sleep",
        "title", "睡眠安静模式",
        "trigger", "每天 22:30",
        "action", "拉上卧室窗帘，客厅灯关闭，卧室空调调至 23°C",
        "source", "manual",
        "enabled", true,
        "triggerSpec", map("type", "time", "label", "每天 22:30", "time", "22:30"),
        "actions", List.of(
            map("pointId", "bedroom_curtain", "command", "set", "label", "拉上卧室窗帘", "value", 100),
            map("pointId", "living_light", "command", "off", "label", "关闭客厅灯"),
            map("pointId", "bedroom_air", "command", "set", "label", "卧室空调调至 23°C", "value", 23)
        )
    ));
    return automations;
  }

  private List<Map<String, Object>> defaultNotifications() {
    List<Map<String, Object>> notifications = new ArrayList<>();
    notifications.add(map("id", "notice_seed_1", "category", "设备", "title", "客厅设备状态保持正常", "desc", "全部在线", "time", "18:45", "read", false));
    notifications.add(map("id", "notice_seed_2", "category", "自动化", "title", "睡眠安静模式已准备", "desc", "每天 22:30 执行", "time", "20:15", "read", false));
    return notifications;
  }

  private List<Map<String, Object>> defaultAgentRecords() {
    List<Map<String, Object>> records = new ArrayList<>();
    records.add(map("id", "record_seed_1", "title", "智能助手已整理晨间场景", "detail", "建议把窗帘、空调和照明联动成一个一键场景。", "time", "09:12", "status", "建议"));
    records.add(map("id", "record_seed_2", "title", "离家脚本已同步", "detail", "关闭高功率设备，并保留必要的安防提醒。", "time", "08:46", "status", "已执行"));
    return records;
  }

  private Map<String, Object> defaultPreferences() {
    return map(
        "pushEnabled", true,
        "autoUpgrade", false,
        "darkFollowHome", true,
        "mallNotify", true
    );
  }

  private Map<String, Object> room(String id, String name, String subtitle, boolean preset) {
    return map("id", id, "name", name, "subtitle", subtitle, "preset", preset);
  }

  private Map<String, Object> deviceState(String pointId, boolean on, int value) {
    return map("pointId", pointId, "on", on, "value", value);
  }

  private Map<String, Object> scene(String id, String label, String detail, String badge, String baseId) {
    return map("id", id, "label", label, "detail", detail, "badge", badge, "baseId", baseId);
  }

  @SafeVarargs
  private final <T> Map<String, T> map(Object... entries) {
    Map<String, T> result = new LinkedHashMap<>();
    for (int i = 0; i < entries.length; i += 2) {
      @SuppressWarnings("unchecked")
      T value = (T) entries[i + 1];
      result.put(String.valueOf(entries[i]), value);
    }
    return result;
  }
}
