package com.smarthome.api.store;

import java.sql.PreparedStatement;
import java.sql.Statement;
import java.util.List;
import java.util.Optional;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.stereotype.Repository;

@Repository
public class StoreAddressRepository {
  private final JdbcTemplate jdbc;

  public StoreAddressRepository(JdbcTemplate jdbc) {
    this.jdbc = jdbc;
  }

  public List<StoreAddressDto> findAll(long userId) {
    return jdbc.query("""
        SELECT id, name, phone, region, detail, tag, is_default, updated_at
        FROM user_store_addresses
        WHERE user_id = ?
        ORDER BY is_default DESC, updated_at DESC, id DESC
        """, (rs, rowNum) -> new StoreAddressDto(
        rs.getLong("id"),
        rs.getString("name"),
        rs.getString("phone"),
        rs.getString("region"),
        rs.getString("detail"),
        rs.getString("tag"),
        rs.getBoolean("is_default"),
        rs.getTimestamp("updated_at").toInstant()
    ), userId);
  }

  public Optional<StoreAddressDto> findById(long userId, long addressId) {
    return jdbc.query("""
        SELECT id, name, phone, region, detail, tag, is_default, updated_at
        FROM user_store_addresses
        WHERE user_id = ? AND id = ?
        """, (rs, rowNum) -> new StoreAddressDto(
        rs.getLong("id"),
        rs.getString("name"),
        rs.getString("phone"),
        rs.getString("region"),
        rs.getString("detail"),
        rs.getString("tag"),
        rs.getBoolean("is_default"),
        rs.getTimestamp("updated_at").toInstant()
    ), userId, addressId).stream().findFirst();
  }

  public int count(long userId) {
    Integer count = jdbc.queryForObject("""
        SELECT COUNT(*)
        FROM user_store_addresses
        WHERE user_id = ?
        """, Integer.class, userId);
    return count == null ? 0 : count;
  }

  public long insert(long userId, StoreAddressRequest request, boolean isDefault) {
    GeneratedKeyHolder keyHolder = new GeneratedKeyHolder();
    jdbc.update(connection -> {
      PreparedStatement statement = connection.prepareStatement("""
          INSERT INTO user_store_addresses (user_id, name, phone, region, detail, tag, is_default)
          VALUES (?, ?, ?, ?, ?, ?, ?)
          """, Statement.RETURN_GENERATED_KEYS);
      statement.setLong(1, userId);
      statement.setString(2, request.name().trim());
      statement.setString(3, request.phone().trim());
      statement.setString(4, request.region().trim());
      statement.setString(5, request.detail().trim());
      statement.setString(6, normalizedTag(request.tag()));
      statement.setBoolean(7, isDefault);
      return statement;
    }, keyHolder);
    Number key = keyHolder.getKey();
    return key == null ? 0 : key.longValue();
  }

  public int update(long userId, long addressId, StoreAddressRequest request, boolean isDefault) {
    return jdbc.update("""
        UPDATE user_store_addresses
        SET name = ?,
            phone = ?,
            region = ?,
            detail = ?,
            tag = ?,
            is_default = ?
        WHERE user_id = ? AND id = ?
        """,
        request.name().trim(),
        request.phone().trim(),
        request.region().trim(),
        request.detail().trim(),
        normalizedTag(request.tag()),
        isDefault,
        userId,
        addressId
    );
  }

  public void clearDefault(long userId) {
    jdbc.update("""
        UPDATE user_store_addresses
        SET is_default = FALSE
        WHERE user_id = ?
        """, userId);
  }

  public int markDefault(long userId, long addressId) {
    return jdbc.update("""
        UPDATE user_store_addresses
        SET is_default = TRUE
        WHERE user_id = ? AND id = ?
        """, userId, addressId);
  }

  public int delete(long userId, long addressId) {
    return jdbc.update("""
        DELETE FROM user_store_addresses
        WHERE user_id = ? AND id = ?
        """, userId, addressId);
  }

  private String normalizedTag(String tag) {
    return tag == null || tag.isBlank() ? "家庭" : tag.trim();
  }
}
