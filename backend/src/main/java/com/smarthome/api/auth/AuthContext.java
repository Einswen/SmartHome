package com.smarthome.api.auth;

public final class AuthContext {
  private static final ThreadLocal<AuthUser> CURRENT = new ThreadLocal<>();

  private AuthContext() {
  }

  public static void set(AuthUser user) {
    CURRENT.set(user);
  }

  public static AuthUser require() {
    AuthUser user = CURRENT.get();
    if (user == null) {
      throw new IllegalStateException("Missing authenticated user");
    }
    return user;
  }

  public static void clear() {
    CURRENT.remove();
  }
}
