package com.smarthome.api.auth;

public record UserRecord(long id, String phone, String passwordHash, String displayName) {
  public AuthUser toAuthUser() {
    return new AuthUser(id, phone, displayName);
  }
}
