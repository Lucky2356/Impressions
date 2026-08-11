; Установщик «Впечатлений» для Windows.
;
; Flutter собирает не один exe, а папку с исполняемым файлом, DLL и данными,
; поэтому просто «выложить exe» нельзя — нужен установщик, который положит всё
; вместе, создаст ярлыки и пропишет удаление. Собирается командой:
;   ISCC.exe installer\impressions.iss
; Каталог сборки и версия передаются из scripts/build_installer.ps1.

#ifndef AppVersion
  #define AppVersion "1.1.0"
#endif
#ifndef SourceDir
  #define SourceDir "..\build\windows\x64\runner\Release"
#endif
#ifndef OutputDir
  #define OutputDir "..\dist"
#endif

#define AppName "Впечатления"
#define AppExeName "impressions.exe"
#define AppPublisher "Lucky2356"
#define AppUrl "https://github.com/Lucky2356/Impressions"

[Setup]
AppId={{7C1E9A54-2F3D-4B86-9E0A-5D2B7C4E8F13}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppUrl}
AppSupportURL={#AppUrl}/issues
AppUpdatesURL={#AppUrl}/releases
VersionInfoVersion={#AppVersion}
VersionInfoDescription={#AppName} — личная медиатека впечатлений

; Установка в профиль пользователя: права администратора не нужны.
DefaultDirName={autopf}\Impressions
DefaultGroupName={#AppName}
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog

; Обычный ход установки: приветствие, лицензия, выбор папки, подтверждение.
; Inno 6 по умолчанию пропускает приветствие, а из-за DisableProgramGroupPage
; установщик выглядел так, будто ничего не спрашивает вовсе.
DisableWelcomePage=no
DisableDirPage=no
DisableReadyPage=no
LicenseFile=license_ru.txt

OutputDir={#OutputDir}
OutputBaseFilename=Impressions-{#AppVersion}-windows-x64-setup
SetupIconFile={#SourceDir}\..\..\..\..\..\windows\runner\resources\app_icon.ico
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
DisableProgramGroupPage=yes
UninstallDisplayIcon={app}\{#AppExeName}
UninstallDisplayName={#AppName}

[Languages]
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"

[Tasks]
Name: "desktopicon"; Description: "Создать ярлык на рабочем столе"; GroupDescription: "Дополнительно:"

[Files]
; Всё содержимое релизной сборки Flutter: exe, DLL движка, плагины и data\.
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\{#AppExeName}"
Name: "{group}\Удалить {#AppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; Tasks: desktopicon

[Registry]
; Файл обмена открывается двойным щелчком. Раньше присланный профиль
; приходилось искать вручную в разделе «Импорт»: система про расширение ничего
; не знала. Записи идут в ветку текущего пользователя — прав администратора
; для установки по-прежнему не нужно.
Root: HKCU; Subkey: "Software\Classes\.impressions"; ValueType: string; ValueName: ""; ValueData: "Impressions.Profile"; Flags: uninsdeletevalue
Root: HKCU; Subkey: "Software\Classes\Impressions.Profile"; ValueType: string; ValueName: ""; ValueData: "Профиль «Впечатлений»"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\Impressions.Profile\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\{#AppExeName},0"
Root: HKCU; Subkey: "Software\Classes\Impressions.Profile\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#AppExeName}"" ""%1"""

[Run]
Filename: "{app}\{#AppExeName}"; Description: "Запустить {#AppName}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
; Настройки и база остаются в %APPDATA% — удаление программы не стирает данные.
Type: filesandordirs; Name: "{app}"
