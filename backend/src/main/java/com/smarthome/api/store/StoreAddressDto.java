package com.smarthome.api.store;

import java.time.Instant;

public record StoreAddressDto(
    long id,
    String name,
    String phone,
    String region,
    String detail,
    String tag,
    boolean isDefault,
    Instant updatedAt
) {
}
