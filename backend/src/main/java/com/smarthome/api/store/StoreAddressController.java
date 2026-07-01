package com.smarthome.api.store;

import com.smarthome.api.auth.AuthContext;
import jakarta.validation.Valid;
import java.util.List;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/store/addresses")
public class StoreAddressController {
  private final StoreAddressService addresses;

  public StoreAddressController(StoreAddressService addresses) {
    this.addresses = addresses;
  }

  @GetMapping
  public List<StoreAddressDto> list() {
    return addresses.list(AuthContext.require().id());
  }

  @PostMapping
  public StoreAddressDto create(@Valid @RequestBody StoreAddressRequest request) {
    return addresses.create(AuthContext.require().id(), request);
  }

  @PutMapping("/{addressId}")
  public StoreAddressDto update(@PathVariable long addressId, @Valid @RequestBody StoreAddressRequest request) {
    return addresses.update(AuthContext.require().id(), addressId, request);
  }

  @PutMapping("/{addressId}/default")
  public List<StoreAddressDto> setDefault(@PathVariable long addressId) {
    return addresses.setDefault(AuthContext.require().id(), addressId);
  }

  @DeleteMapping("/{addressId}")
  public List<StoreAddressDto> delete(@PathVariable long addressId) {
    return addresses.delete(AuthContext.require().id(), addressId);
  }
}
