package com.smarthome.api.auth;

import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.spec.InvalidKeySpecException;
import java.util.Base64;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import org.springframework.stereotype.Component;

@Component
public class PasswordHasher {
  private static final int ITERATIONS = 120_000;
  private static final int KEY_LENGTH = 256;
  private final SecureRandom random = new SecureRandom();

  public String hash(String password) {
    byte[] salt = new byte[16];
    random.nextBytes(salt);
    byte[] hash = pbkdf2(password, salt, ITERATIONS);
    return "pbkdf2$" + ITERATIONS + "$" + Base64.getEncoder().encodeToString(salt) + "$"
        + Base64.getEncoder().encodeToString(hash);
  }

  public boolean matches(String password, String encoded) {
    String[] parts = encoded.split("\\$");
    if (parts.length != 4 || !"pbkdf2".equals(parts[0])) {
      return false;
    }
    int iterations = Integer.parseInt(parts[1]);
    byte[] salt = Base64.getDecoder().decode(parts[2]);
    byte[] expected = Base64.getDecoder().decode(parts[3]);
    byte[] actual = pbkdf2(password, salt, iterations);
    if (actual.length != expected.length) {
      return false;
    }
    int diff = 0;
    for (int i = 0; i < actual.length; i++) {
      diff |= actual[i] ^ expected[i];
    }
    return diff == 0;
  }

  private byte[] pbkdf2(String password, byte[] salt, int iterations) {
    try {
      PBEKeySpec spec = new PBEKeySpec(password.toCharArray(), salt, iterations, KEY_LENGTH);
      return SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256").generateSecret(spec).getEncoded();
    } catch (NoSuchAlgorithmException | InvalidKeySpecException exception) {
      throw new IllegalStateException("Password hashing unavailable", exception);
    }
  }
}
