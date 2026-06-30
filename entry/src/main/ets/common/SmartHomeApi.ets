import http from '@ohos.net.http';

export const SMART_HOME_API_BASE_URL: string = 'http://10.110.47.149:18080/api';
const API_TIMEOUT_MS: number = 8000;

export interface SmartHomeUser {
  id: number;
  phone: string;
  displayName: string;
}

export interface SmartHomeState {
  rooms: Object[];
  roomDevices: Object[];
  deviceStates: Object[];
  scenes: Object[];
  automations: Object[];
  notifications: Object[];
  agentRecords: Object[];
  agentMessages: Object[];
  preferences: Object;
  activeRoomId: string;
  activeSceneId: string;
  isNight: boolean;
  manualPeriod: boolean;
  updatedAt?: string;
}

export interface SmartHomeAuthResponse {
  token: string;
  user: SmartHomeUser;
  homeState: SmartHomeState;
}

export interface SmartHomeApiResult<T> {
  ok: boolean;
  statusCode: number;
  data?: T;
  error?: string;
}

export interface DeviceStatePatch {
  on?: boolean;
  value?: number;
  command?: string;
  extra?: Object;
}

export interface DeviceActionPayload extends DeviceStatePatch {
  pointId: string;
  actionType: string;
}

interface SmartHomeHeader {
  'Content-Type': string;
  'Authorization'?: string;
}

interface LoginRequestBody {
  phone: string;
  password: string;
}

interface RegisterRequestBody {
  phone: string;
  password: string;
  displayName: string;
}

interface SectionUpdateBody {
  value: Object;
}

interface RoomDevicesUpdateBody {
  roomId: string;
  pointIds: string[];
}

function authHeader(token: string): SmartHomeHeader {
  if (token.trim().length === 0) {
    return {
      'Content-Type': 'application/json'
    };
  }
  return {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`
  };
}

function parseBody<T>(raw: string): T | undefined {
  if (raw.length === 0) {
    return undefined;
  }
  try {
    return JSON.parse(raw) as T;
  } catch {
    return undefined;
  }
}

async function requestJson<T>(path: string, method: http.RequestMethod, token: string, body?: Object): Promise<SmartHomeApiResult<T>> {
  const request = http.createHttp();
  try {
    const response = await request.request(`${SMART_HOME_API_BASE_URL}${path}`, {
      method: method,
      header: authHeader(token),
      extraData: body === undefined ? undefined : JSON.stringify(body),
      expectDataType: http.HttpDataType.STRING,
      readTimeout: API_TIMEOUT_MS,
      connectTimeout: API_TIMEOUT_MS
    });
    const statusCode = Number(response.responseCode);
    const raw = `${response.result}`;
    const data = parseBody<T>(raw);
    if (statusCode < 200 || statusCode >= 300) {
      return {
        ok: false,
        statusCode: statusCode,
        error: raw.length > 0 ? raw : `HTTP ${statusCode}`
      };
    }
    return {
      ok: true,
      statusCode: statusCode,
      data: data
    };
  } catch (error) {
    return {
      ok: false,
      statusCode: 0,
      error: `${error}`
    };
  } finally {
    request.destroy();
  }
}

export async function loginSmartHome(phone: string, password: string): Promise<SmartHomeApiResult<SmartHomeAuthResponse>> {
  const body: LoginRequestBody = {
    phone: phone,
    password: password
  };
  return requestJson<SmartHomeAuthResponse>('/auth/login', http.RequestMethod.POST, '', body);
}

export async function registerSmartHome(phone: string, password: string, displayName: string): Promise<SmartHomeApiResult<SmartHomeAuthResponse>> {
  const body: RegisterRequestBody = {
    phone: phone,
    password: password,
    displayName: displayName
  };
  return requestJson<SmartHomeAuthResponse>('/auth/register', http.RequestMethod.POST, '', body);
}

export async function fetchHomeState(token: string): Promise<SmartHomeApiResult<SmartHomeState>> {
  return requestJson<SmartHomeState>('/home/state', http.RequestMethod.GET, token);
}

export async function replaceHomeState(token: string, state: SmartHomeState): Promise<SmartHomeApiResult<SmartHomeState>> {
  return requestJson<SmartHomeState>('/home/state', http.RequestMethod.PUT, token, state);
}

export async function updateHomeSection(token: string, section: string, value: Object): Promise<SmartHomeApiResult<SmartHomeState>> {
  const body: SectionUpdateBody = {
    value: value
  };
  return requestJson<SmartHomeState>(`/home/sections/${section}`, http.RequestMethod.PUT, token, body);
}

export async function updateRoomDevices(token: string, roomId: string, pointIds: string[]): Promise<SmartHomeApiResult<SmartHomeState>> {
  const body: RoomDevicesUpdateBody = {
    roomId: roomId,
    pointIds: pointIds
  };
  return requestJson<SmartHomeState>(`/home/room-devices/${roomId}`, http.RequestMethod.PUT, token, body);
}

export async function updateDeviceState(token: string, pointId: string, patch: DeviceStatePatch): Promise<SmartHomeApiResult<SmartHomeState>> {
  return requestJson<SmartHomeState>(`/home/device-states/${pointId}`, http.RequestMethod.PUT, token, patch);
}

export async function submitDeviceAction(token: string, payload: DeviceActionPayload): Promise<SmartHomeApiResult<Object>> {
  return requestJson<Object>('/home/device-actions', http.RequestMethod.POST, token, payload);
}
