package com.smarthome.api.auth;

import java.sql.PreparedStatement;
import java.sql.Statement;
import java.util.Optional;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.stereotype.Repository;

@Repository
public class UserRepository {
  private final JdbcTemplate jdbc;

  public UserRepository(JdbcTemplate jdbc) {
    this.jdbc = jdbc;
  }

  public Optional<UserRecord> findByPhone(String phone) {
    return jdbc.query("""
        SELECT id, phone, password_hash, display_name
        FROM users
        WHERE phone = ?
        """, (rs, rowNum) -> new UserRecord(
        rs.getLong("id"),
        rs.getString("phone"),
        rs.getString("password_hash"),
        rs.getString("display_name")
    ), phone).stream().findFirst();
  }

  public Optional<UserRecord> findById(long id) {
    return jdbc.query("""
        SELECT id, phone, password_hash, display_name
        FROM users
        WHERE id = ?
        """, (rs, rowNum) -> new UserRecord(
        rs.getLong("id"),
        rs.getString("phone"),
        rs.getString("password_hash"),
        rs.getString("display_name")
    ), id).stream().findFirst();
  }

  public UserRecord create(String phone, String passwordHash, String displayName) {
    GeneratedKeyHolder keyHolder = new GeneratedKeyHolder();
    jdbc.update(connection -> {
      PreparedStatement statement = connection.prepareStatement("""
          INSERT INTO users (phone, password_hash, display_name)
          VALUES (?, ?, ?)
          """, Statement.RETURN_GENERATED_KEYS);
      statement.setString(1, phone);
      statement.setString(2, passwordHash);
      statement.setString(3, displayName);
      return statement;
    }, keyHolder);
    Number key = keyHolder.getKey();
    long id = key == null ? 0 : key.longValue();
    return new UserRecord(id, phone, passwordHash, displayName);
  }
}
