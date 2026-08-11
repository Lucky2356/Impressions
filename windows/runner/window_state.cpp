#include "window_state.h"

namespace {

constexpr wchar_t kKey[] = L"Software\\Impressions";
constexpr wchar_t kLeft[] = L"WindowLeft";
constexpr wchar_t kTop[] = L"WindowTop";
constexpr wchar_t kWidth[] = L"WindowWidth";
constexpr wchar_t kHeight[] = L"WindowHeight";
constexpr wchar_t kMaximized[] = L"WindowMaximized";

bool ReadValue(const wchar_t* name, DWORD* value) {
  DWORD size = sizeof(DWORD);
  DWORD type = 0;
  LSTATUS status = ::RegGetValueW(HKEY_CURRENT_USER, kKey, name, RRF_RT_DWORD,
                                  &type, value, &size);
  return status == ERROR_SUCCESS;
}

void WriteValue(HKEY key, const wchar_t* name, DWORD value) {
  ::RegSetValueExW(key, name, 0, REG_DWORD,
                   reinterpret_cast<const BYTE*>(&value), sizeof(value));
}

// Видно ли такое окно хоть на одном подключённом мониторе.
//
// Ноутбук закрывают с внешним монитором, и сохранённое положение может
// оказаться за краем: окно открылось бы там, где его не достать.
bool IsVisibleOnSomeMonitor(const RECT& rect) {
  HMONITOR monitor = ::MonitorFromRect(&rect, MONITOR_DEFAULTTONULL);
  return monitor != nullptr;
}

}  // namespace

namespace window_state {

void Restore(HWND window) {
  DWORD left = 0;
  DWORD top = 0;
  DWORD width = 0;
  DWORD height = 0;
  if (!ReadValue(kLeft, &left) || !ReadValue(kTop, &top) ||
      !ReadValue(kWidth, &width) || !ReadValue(kHeight, &height)) {
    return;
  }
  // Слишком маленькое окно означало бы испорченную запись, а не намерение.
  if (width < 640 || height < 480) {
    return;
  }

  RECT rect;
  rect.left = static_cast<LONG>(static_cast<INT32>(left));
  rect.top = static_cast<LONG>(static_cast<INT32>(top));
  rect.right = rect.left + static_cast<LONG>(width);
  rect.bottom = rect.top + static_cast<LONG>(height);
  if (!IsVisibleOnSomeMonitor(rect)) {
    return;
  }

  WINDOWPLACEMENT placement = {};
  placement.length = sizeof(placement);
  if (!::GetWindowPlacement(window, &placement)) {
    return;
  }
  placement.rcNormalPosition = rect;

  DWORD maximized = 0;
  ReadValue(kMaximized, &maximized);
  placement.showCmd = maximized != 0 ? SW_SHOWMAXIMIZED : SW_SHOWNORMAL;

  ::SetWindowPlacement(window, &placement);
}

void Save(HWND window) {
  WINDOWPLACEMENT placement = {};
  placement.length = sizeof(placement);
  if (!::GetWindowPlacement(window, &placement)) {
    return;
  }

  HKEY key = nullptr;
  if (::RegCreateKeyExW(HKEY_CURRENT_USER, kKey, 0, nullptr, 0, KEY_SET_VALUE,
                        nullptr, &key, nullptr) != ERROR_SUCCESS) {
    return;
  }

  // rcNormalPosition — размер окна в обычном состоянии: он остаётся верным и
  // когда окно развёрнуто, поэтому «развернуть — закрыть — открыть» возвращает
  // и развёрнутость, и прежний размер под ней.
  const RECT& rect = placement.rcNormalPosition;
  WriteValue(key, kLeft, static_cast<DWORD>(rect.left));
  WriteValue(key, kTop, static_cast<DWORD>(rect.top));
  WriteValue(key, kWidth, static_cast<DWORD>(rect.right - rect.left));
  WriteValue(key, kHeight, static_cast<DWORD>(rect.bottom - rect.top));
  WriteValue(key, kMaximized,
             placement.showCmd == SW_SHOWMAXIMIZED ? 1 : 0);
  ::RegCloseKey(key);
}

}  // namespace window_state
