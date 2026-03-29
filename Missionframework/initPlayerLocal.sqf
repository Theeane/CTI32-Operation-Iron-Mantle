/*
    Author: OpenAI / Operation Iron Mantle
    File: initPlayerLocal.sqf
    Project: Military War Framework

    Description:
    Client-side bootstrap. Registers local UI/settings and starts the loadout
    monitor once after the server has released the client.
*/

if (!hasInterface) exitWith {};

missionNamespace setVariable ["MWF_ClientInitStage", "WAITING_FOR_SERVER"];
missionNamespace setVariable ["MWF_ClientInitComplete", false];
missionNamespace setVariable ["MWF_DeployUiClosed", false];

private _serverDeadline = diag_tickTime + 60;
waitUntil {
    uiSleep 0.5;
    (missionNamespace getVariable ["MWF_ServerReady", false]) ||
    {(missionNamespace getVariable ["MWF_ServerBootStage", ""]) isEqualTo "CRITICAL_RELEASED"} ||
    {diag_tickTime >= _serverDeadline}
};

if (diag_tickTime >= _serverDeadline) then {
    diag_log "[MWF] WARNING: Client proceeding after server-wait timeout. Some assets might be missing.";
};

missionNamespace setVariable ["MWF_ClientInitStage", "SERVER_CONNECTED"];

if (!(missionNamespace getVariable ["MWF_UI_SettingsRegistered", false]) && {!isNil "MWF_fnc_initUI"}) then {
    [] call MWF_fnc_initUI;
    missionNamespace setVariable ["MWF_UI_SettingsRegistered", true];
};

if (!(missionNamespace getVariable ["MWF_LoadoutSystemInitialized", false]) && {!isNil "MWF_fnc_initLoadoutSystem"}) then {
    [] spawn MWF_fnc_initLoadoutSystem;
};

if (!isNil "MWF_fnc_setupInteractions") then {
    [] spawn {
        uiSleep 1;
        [] call MWF_fnc_setupInteractions;
    };
};

if (!isNil "MWF_fnc_initWorldLocal") then { [] spawn MWF_fnc_initWorldLocal; };

diag_log "[MWF] initPlayerLocal: Client handshake complete.";
