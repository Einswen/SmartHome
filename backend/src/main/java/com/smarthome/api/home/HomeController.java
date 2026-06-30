package com.smarthome.api.home;

import com.smarthome.api.auth.AuthContext;
import com.smarthome.api.home.HomeDtos.AcceptedResponse;
import com.smarthome.api.home.HomeDtos.ActiveStateRequest;
import com.smarthome.api.home.HomeDtos.DeviceActionRequest;
import com.smarthome.api.home.HomeDtos.DeviceStatePatch;
import com.smarthome.api.home.HomeDtos.RoomDeviceUpdateRequest;
import com.smarthome.api.home.HomeDtos.SectionUpdateRequest;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/home")
public class HomeController {
  private final HomeStateService homeStates;

  public HomeController(HomeStateService homeStates) {
    this.homeStates = homeStates;
  }

  @GetMapping("/state")
  public HomeStateDto state() {
    return homeStates.ensureState(AuthContext.require().id());
  }

  @PutMapping("/state")
  public HomeStateDto replaceState(@Valid @RequestBody HomeStateDto state) {
    return homeStates.replaceState(AuthContext.require().id(), state);
  }

  @PatchMapping("/active")
  public HomeStateDto updateActive(@RequestBody ActiveStateRequest request) {
    return homeStates.updateActiveState(AuthContext.require().id(), request);
  }

  @PutMapping("/sections/{section}")
  public HomeStateDto updateSection(@PathVariable String section, @Valid @RequestBody SectionUpdateRequest request) {
    return homeStates.updateSection(AuthContext.require().id(), section, request);
  }

  @PutMapping("/room-devices/{roomId}")
  public HomeStateDto updateRoomDevices(@PathVariable String roomId, @Valid @RequestBody RoomDeviceUpdateRequest request) {
    RoomDeviceUpdateRequest normalized = new RoomDeviceUpdateRequest(roomId, request.pointIds());
    return homeStates.updateRoomDevices(AuthContext.require().id(), normalized);
  }

  @PatchMapping("/device-states/{pointId}")
  public HomeStateDto updateDeviceState(@PathVariable String pointId, @RequestBody DeviceStatePatch request) {
    return homeStates.updateDeviceState(AuthContext.require().id(), pointId, request);
  }

  @PutMapping("/device-states/{pointId}")
  public HomeStateDto putDeviceState(@PathVariable String pointId, @RequestBody DeviceStatePatch request) {
    return homeStates.updateDeviceState(AuthContext.require().id(), pointId, request);
  }

  @PostMapping("/device-actions")
  public AcceptedResponse acceptDeviceAction(@Valid @RequestBody DeviceActionRequest request) {
    HomeStateDto state = homeStates.acceptDeviceAction(AuthContext.require().id(), request);
    return new AcceptedResponse(true, state);
  }
}
