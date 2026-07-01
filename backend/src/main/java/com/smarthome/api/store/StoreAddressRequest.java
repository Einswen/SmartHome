package com.smarthome.api.store;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record StoreAddressRequest(
    @NotBlank(message = "联系人不能为空") @Size(max = 80, message = "联系人过长") String name,
    @NotBlank(message = "手机号不能为空") @Size(max = 32, message = "手机号过长") String phone,
    @NotBlank(message = "所在地区不能为空") @Size(max = 120, message = "所在地区过长") String region,
    @NotBlank(message = "详细地址不能为空") @Size(max = 255, message = "详细地址过长") String detail,
    @Size(max = 40, message = "标签过长") String tag,
    Boolean isDefault
) {
}
