package com.smarthome.api.home;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class HomeStateRepository {
  private final JdbcTemplate jdbc;
  private final ObjectMapper mapper;

  public HomeStateRepository(JdbcTemplate jdbc, ObjectMapper mapper) {
    this.jdbc = jdbc;
    this.mapper = mapper;
  }

  public Optional<HomeStateDto> find(long userId) {
    return jdbc.query("""
        SELECT rooms_json, room_devices_json, device_states_json, scenes_json, automations_json,
               notifications_json, agent_records_json, agent_messages_json, preferences_json,
               active_room_id, active_scene_id, is_night, manual_period, updated_at
        FROM user_home_states
        WHERE user_id = ?
        """, (rs, rowNum) -> mapState(rs), userId).stream().findFirst();
  }

  public void insert(long userId, HomeStateDto state) {
    jdbc.update("""
        INSERT INTO user_home_states (
          user_id, rooms_json, room_devices_json, device_states_json, scenes_json, automations_json,
          notifications_json, agent_records_json, agent_messages_json, preferences_json,
          active_room_id, active_scene_id, is_night, manual_period
        ) VALUES (?, CAST(? AS JSON), CAST(? AS JSON), CAST(? AS JSON), CAST(? AS JSON), CAST(? AS JSON),
                  CAST(? AS JSON), CAST(? AS JSON), CAST(? AS JSON), CAST(? AS JSON), ?, ?, ?, ?)
        """,
        userId,
        json(state.rooms()),
        json(state.roomDevices()),
        json(state.deviceStates()),
        json(state.scenes()),
        json(state.automations()),
        json(state.notifications()),
        json(state.agentRecords()),
        json(state.agentMessages()),
        json(state.preferences()),
        state.activeRoomId(),
        state.activeSceneId(),
        state.isNight(),
        state.manualPeriod()
    );
  }

  public void save(long userId, HomeStateDto state) {
    jdbc.update("""
        UPDATE user_home_states
        SET rooms_json = CAST(? AS JSON),
            room_devices_json = CAST(? AS JSON),
            device_states_json = CAST(? AS JSON),
            scenes_json = CAST(? AS JSON),
            automations_json = CAST(? AS JSON),
            notifications_json = CAST(? AS JSON),
            agent_records_json = CAST(? AS JSON),
            agent_messages_json = CAST(? AS JSON),
            preferences_json = CAST(? AS JSON),
            active_room_id = ?,
            active_scene_id = ?,
            is_night = ?,
            manual_period = ?
        WHERE user_id = ?
        """,
        json(state.rooms()),
        json(state.roomDevices()),
        json(state.deviceStates()),
        json(state.scenes()),
        json(state.automations()),
        json(state.notifications()),
        json(state.agentRecords()),
        json(state.agentMessages()),
        json(state.preferences()),
        state.activeRoomId(),
        state.activeSceneId(),
        state.isNight(),
        state.manualPeriod(),
        userId
    );
  }

  public void logAction(long userId, String pointId, String actionType, Object payload, String status) {
    jdbc.update("""
        INSERT INTO action_logs (user_id, point_id, action_type, payload_json, status)
        VALUES (?, ?, ?, CAST(? AS JSON), ?)
        """, userId, pointId, actionType, json(payload), status);
  }

  private HomeStateDto mapState(ResultSet rs) throws SQLException {
    return new HomeStateDto(
        readList(rs.getString("rooms_json")),
        readList(rs.getString("room_devices_json")),
        readList(rs.getString("device_states_json")),
        readList(rs.getString("scenes_json")),
        readList(rs.getString("automations_json")),
        readList(rs.getString("notifications_json")),
        readList(rs.getString("agent_records_json")),
        readList(rs.getString("agent_messages_json")),
        readMap(rs.getString("preferences_json")),
        rs.getString("active_room_id"),
        rs.getString("active_scene_id"),
        rs.getBoolean("is_night"),
        rs.getBoolean("manual_period"),
        rs.getTimestamp("updated_at").toInstant()
    );
  }

  private List<Map<String, Object>> readList(String json) {
    try {
      return mapper.readValue(json, new TypeReference<>() {});
    } catch (JsonProcessingException exception) {
      throw new IllegalStateException("Invalid state JSON", exception);
    }
  }

  private Map<String, Object> readMap(String json) {
    try {
      return mapper.readValue(json, new TypeReference<>() {});
    } catch (JsonProcessingException exception) {
      throw new IllegalStateException("Invalid state JSON", exception);
    }
  }

  private String json(Object value) {
    try {
      return mapper.writeValueAsString(value);
    } catch (JsonProcessingException exception) {
      throw new IllegalStateException("JSON encode failed", exception);
    }
  }
}
