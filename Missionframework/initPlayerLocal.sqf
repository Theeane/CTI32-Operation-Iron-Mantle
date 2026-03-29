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

if (!isNil "MWF_fnc_updateResourceUI") then {
    [] spawn {
        waitUntil {
            uiSleep 0.25;
            !isNull findDisplay 46 && {!isNull player}
        };
        [] spawn MWF_fnc_updateResourceUI;
    };
};

if (!isNil "MWF_fnc_setupInteractions") then {
    [] spawn {
        uiSleep 1;
        [] call MWF_fnc_setupInteractions;
    };
};

if (!isNil "MWF_fnc_initWorldLocal") then { [] spawn MWF_fnc_initWorldLocal; };

diag_log "[MWF] initPlayerLocal: Client handshake complete.";


[] spawn {
    waitUntil {
        uiSleep 0.25;
        uiNamespace getVariable ["MWF_IntroCinematicPlayed", false]
    };

    uiSleep 3;
    private _deadline = diag_tickTime + 45;
    while {hasInterface && {diag_tickTime < _deadline}} do {
        uiSleep 1;
        if (!isNull player && {alive player}) then {
            cutText ["", "BLACK IN", 0];
            titleCut ["", "BLACK IN", 0];
            showCinemaBorder false;

            if (!(missionNamespace getVariable ["MWF_ClientInitComplete", false]) && {!isNil "MWF_fnc_handlePostSpawn"}) then {
                [true] call MWF_fnc_handlePostSpawn;
            };

            if (missionNamespace getVariable ["MWF_ClientInitComplete", false]) exitWith {};
        };
    };
};
