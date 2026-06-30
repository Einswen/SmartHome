package com.smarthome.api.auth;

import com.smarthome.api.auth.AuthDtos.AuthResponse;
import com.smarthome.api.auth.AuthDtos.LoginRequest;
import com.smarthome.api.auth.AuthDtos.RegisterRequest;
import com.smarthome.api.common.ApiException;
import com.smarthome.api.home.HomeStateDto;
import com.smarthome.api.home.HomeStateService;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {
  private final UserRepository users;
  private final PasswordHasher passwords;
  private final JwtService jwt;
  private final HomeStateService homeStates;

  public AuthService(UserRepository users, PasswordHasher passwords, JwtService jwt, HomeStateService homeStates) {
    this.users = users;
    this.passwords = passwords;
    this.jwt = jwt;
    this.homeStates = homeStates;
  }

  @Transactional
  public AuthResponse register(RegisterRequest request) {
    String phone = request.phone().trim();
    users.findByPhone(phone).ifPresent(user -> {
      throw new ApiException(HttpStatus.CONFLICT, "手机号已注册");
    });
    String displayName = request.displayName() == null || request.displayName().isBlank()
        ? "Lumi 用户"
        : request.displayName().trim();
    UserRecord user = users.create(phone, passwords.hash(request.password()), displayName);
    HomeStateDto state = homeStates.ensureState(user.id());
    AuthUser authUser = user.toAuthUser();
    return new AuthResponse(jwt.createToken(authUser), authUser, state);
  }

  public AuthResponse login(LoginRequest request) {
    UserRecord user = users.findByPhone(request.phone().trim())
        .orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "手机号或密码错误"));
    if (!passwords.matches(request.password(), user.passwordHash())) {
      throw new ApiException(HttpStatus.UNAUTHORIZED, "手机号或密码错误");
    }
    HomeStateDto state = homeStates.ensureState(user.id());
    AuthUser authUser = user.toAuthUser();
    return new AuthResponse(jwt.createToken(authUser), authUser, state);
  }

  public AuthUser me(long userId) {
    return users.findById(userId)
        .orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "用户不存在"))
        .toAuthUser();
  }
}
