package com.smarthome.api.auth;

import com.smarthome.api.home.HomeStateDto;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public final class AuthDtos {
  private AuthDtos() {
  }

  public record LoginRequest(
      @NotBlank(message = "手机号不能为空") String phone,
      @NotBlank(message = "密码不能为空") String password
  ) {
  }

  public record RegisterRequest(
      @NotBlank(message = "手机号不能为空") String phone,
      @Size(min = 6, message = "密码至少 6 位") String password,
      String displayName
  ) {
  }

  public record AuthResponse(
      String token,
      AuthUser user,
      HomeStateDto homeState
  ) {
  }
}
