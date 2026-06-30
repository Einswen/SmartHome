package com.smarthome.api.common;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {
  private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

  @ExceptionHandler(ApiException.class)
  public ResponseEntity<ApiError> handleApi(ApiException exception) {
    return ResponseEntity.status(exception.status())
        .body(ApiError.of(exception.getMessage(), exception.status().value()));
  }

  @ExceptionHandler(MethodArgumentNotValidException.class)
  public ResponseEntity<ApiError> handleValidation(MethodArgumentNotValidException exception) {
    String message = exception.getBindingResult().getFieldErrors().isEmpty()
        ? "请求参数不合法"
        : exception.getBindingResult().getFieldErrors().get(0).getDefaultMessage();
    return ResponseEntity.badRequest().body(ApiError.of(message, HttpStatus.BAD_REQUEST.value()));
  }

  @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
  public ResponseEntity<ApiError> handleMethodNotSupported(HttpRequestMethodNotSupportedException exception) {
    return ResponseEntity.status(HttpStatus.METHOD_NOT_ALLOWED)
        .body(ApiError.of("请求方法不支持", HttpStatus.METHOD_NOT_ALLOWED.value()));
  }

  @ExceptionHandler(Exception.class)
  public ResponseEntity<ApiError> handleUnexpected(Exception exception) {
    log.error("Unhandled API exception", exception);
    return ResponseEntity.internalServerError()
        .body(ApiError.of("服务暂时不可用", HttpStatus.INTERNAL_SERVER_ERROR.value()));
  }
}
