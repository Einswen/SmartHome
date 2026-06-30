package com.smarthome.api.home;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.util.List;
import java.util.Map;

public final class HomeDtos {
  private HomeDtos() {
  }

  public record SectionUpdateRequest(@NotNull Object value) {
  }

  public record DeviceStatePatch(Boolean on, Integer value, String command, Map<String, Object> extra) {
  }

  public record DeviceActionRequest(
      @NotBlank(message = "pointId 不能为空") String pointId,
      @NotBlank(message = "actionType 不能为空") String actionType,
      Boolean on,
      Integer value,
      String command,
      Map<String, Object> extra
  ) {
  }

  public record RoomDeviceUpdateRequest(
      @NotBlank(message = "roomId 不能为空") String roomId,
      @NotNull List<String> pointIds
  ) {
  }

  public record ActiveStateRequest(String activeRoomId, String activeSceneId, Boolean isNight, Boolean manualPeriod) {
  }

  public record AcceptedResponse(boolean accepted, HomeStateDto homeState) {
  }
}
