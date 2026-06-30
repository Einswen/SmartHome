package com.smarthome.api.home;

import java.time.Instant;
import java.util.List;
import java.util.Map;

public record HomeStateDto(
    List<Map<String, Object>> rooms,
    List<Map<String, Object>> roomDevices,
    List<Map<String, Object>> deviceStates,
    List<Map<String, Object>> scenes,
    List<Map<String, Object>> automations,
    List<Map<String, Object>> notifications,
    List<Map<String, Object>> agentRecords,
    List<Map<String, Object>> agentMessages,
    Map<String, Object> preferences,
    String activeRoomId,
    String activeSceneId,
    boolean isNight,
    boolean manualPeriod,
    Instant updatedAt
) {
}
