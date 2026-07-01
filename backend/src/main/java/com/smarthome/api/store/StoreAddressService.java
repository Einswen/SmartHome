package com.smarthome.api.store;

import com.smarthome.api.common.ApiException;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class StoreAddressService {
  private final StoreAddressRepository addresses;

  public StoreAddressService(StoreAddressRepository addresses) {
    this.addresses = addresses;
  }

  public List<StoreAddressDto> list(long userId) {
    return addresses.findAll(userId);
  }

  @Transactional
  public StoreAddressDto create(long userId, StoreAddressRequest request) {
    boolean makeDefault = Boolean.TRUE.equals(request.isDefault()) || addresses.count(userId) == 0;
    if (makeDefault) {
      addresses.clearDefault(userId);
    }
    long id = addresses.insert(userId, request, makeDefault);
    return findRequired(userId, id);
  }

  @Transactional
  public StoreAddressDto update(long userId, long addressId, StoreAddressRequest request) {
    StoreAddressDto current = findRequired(userId, addressId);
    boolean makeDefault = request.isDefault() == null ? current.isDefault() : request.isDefault();
    if (makeDefault) {
      addresses.clearDefault(userId);
    }
    int updated = addresses.update(userId, addressId, request, makeDefault);
    if (updated == 0) {
      throw new ApiException(HttpStatus.NOT_FOUND, "地址不存在");
    }
    ensureOneDefault(userId);
    return findRequired(userId, addressId);
  }

  @Transactional
  public List<StoreAddressDto> setDefault(long userId, long addressId) {
    findRequired(userId, addressId);
    addresses.clearDefault(userId);
    addresses.markDefault(userId, addressId);
    return addresses.findAll(userId);
  }

  @Transactional
  public List<StoreAddressDto> delete(long userId, long addressId) {
    StoreAddressDto current = findRequired(userId, addressId);
    addresses.delete(userId, addressId);
    if (current.isDefault()) {
      ensureOneDefault(userId);
    }
    return addresses.findAll(userId);
  }

  private StoreAddressDto findRequired(long userId, long addressId) {
    return addresses.findById(userId, addressId)
        .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "地址不存在"));
  }

  private void ensureOneDefault(long userId) {
    List<StoreAddressDto> remaining = addresses.findAll(userId);
    if (remaining.isEmpty()) {
      return;
    }
    for (StoreAddressDto address : remaining) {
      if (address.isDefault()) {
        return;
      }
    }
    addresses.markDefault(userId, remaining.get(0).id());
  }
}
