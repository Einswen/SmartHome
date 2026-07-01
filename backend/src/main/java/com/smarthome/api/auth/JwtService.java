package com.smarthome.api.auth;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.smarthome.api.common.ApiException;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Base64;
import java.util.LinkedHashMap;
import java.util.Map;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

@Service
public class JwtService {
  private final ObjectMapper mapper;
  private final byte[] secret;
  private final long ttlSeconds;

  public JwtService(ObjectMapper mapper,
      @Value("${app.jwt-secret}") String secret,
      @Value("${app.jwt-ttl-seconds}") long ttlSeconds) {
    this.mapper = mapper;
    this.secret = secret.getBytes(StandardCharsets.UTF_8);
    this.ttlSeconds = ttlSeconds;
  }

  public String createToken(AuthUser user) {
    Map<String, Object> header = Map.of("alg", "HS256", "typ", "JWT");
    Map<String, Object> payload = new LinkedHashMap<>();
    payload.put("sub", user.id());
    payload.put("phone", user.phone());
    payload.put("name", user.displayName());
    payload.put("exp", Instant.now().getEpochSecond() + ttlSeconds);
    String headerPart = encodeJson(header);
    String payloadPart = encodeJson(payload);
    String signature = sign(headerPart + "." + payloadPart);
    return headerPart + "." + payloadPart + "." + signature;
  }

  public long verifyAndGetUserId(String token) {
    try {
      String[] parts = token.split("\\.");
      if (parts.length != 3) {
        throw unauthorized();
      }
      String expected = sign(parts[0] + "." + parts[1]);
      if (!constantTimeEquals(expected, parts[2])) {
        throw unauthorized();
      }
      Map<String, Object> payload = mapper.readValue(base64Decode(parts[1]), new TypeReference<>() {});
      long exp = ((Number) payload.get("exp")).longValue();
      if (Instant.now().getEpochSecond() > exp) {
        throw new ApiException(HttpStatus.UNAUTHORIZED, "登录已过期");
      }
      return ((Number) payload.get("sub")).longValue();
    } catch (ApiException exception) {
      throw exception;
    } catch (Exception exception) {
      throw unauthorized();
    }
  }

  private String encodeJson(Object value) {
    try {
      return Base64.getUrlEncoder().withoutPadding().encodeToString(mapper.writeValueAsBytes(value));
    } catch (Exception exception) {
      throw new IllegalStateException("JWT encode failed", exception);
    }
  }

  private byte[] base64Decode(String value) {
    return Base64.getUrlDecoder().decode(value);
  }

  private String sign(String value) {
    try {
      Mac mac = Mac.getInstance("HmacSHA256");
      mac.init(new SecretKeySpec(secret, "HmacSHA256"));
      return Base64.getUrlEncoder().withoutPadding().encodeToString(mac.doFinal(value.getBytes(StandardCharsets.UTF_8)));
    } catch (Exception exception) {
      throw new IllegalStateException("JWT sign failed", exception);
    }
  }

  private boolean constantTimeEquals(String a, String b) {
    if (a.length() != b.length()) {
      return false;
    }
    int diff = 0;
    for (int i = 0; i < a.length(); i++) {
      diff |= a.charAt(i) ^ b.charAt(i);
    }
    return diff == 0;
  }

  private ApiException unauthorized() {
    return new ApiException(HttpStatus.UNAUTHORIZED, "请先登录");
  }
}
