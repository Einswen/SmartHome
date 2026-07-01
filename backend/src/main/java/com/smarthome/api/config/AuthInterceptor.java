package com.smarthome.api.config;

import com.smarthome.api.auth.AuthContext;
import com.smarthome.api.auth.AuthService;
import com.smarthome.api.auth.JwtService;
import com.smarthome.api.common.ApiException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

@Component
public class AuthInterceptor implements HandlerInterceptor {
  private final JwtService jwt;
  private final AuthService auth;

  public AuthInterceptor(JwtService jwt, AuthService auth) {
    this.jwt = jwt;
    this.auth = auth;
  }

  @Override
  public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
    if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
      return true;
    }
    String authorization = request.getHeader("Authorization");
    if (authorization == null || !authorization.startsWith("Bearer ")) {
      throw new ApiException(HttpStatus.UNAUTHORIZED, "请先登录");
    }
    long userId = jwt.verifyAndGetUserId(authorization.substring("Bearer ".length()).trim());
    AuthContext.set(auth.me(userId));
    return true;
  }

  @Override
  public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) {
    AuthContext.clear();
  }
}
