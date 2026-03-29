/*
    Author: OpenAI / Operation Iron Mantle
    File: init.sqf
    Project: Military War Framework (MWF)

    Description:
    Master entry point. Starts the one-time client intro after the server handshake.
    The loadout/action systems are bootstrapped from initPlayerLocal/post-spawn.
*/

enableSaving [false, false];

if (isServer) then {
    diag_log "[MWF] Server: Starting Global State Manager...";
    ["INIT"] call MWF_fnc_globalStateManager;
};

if (hasInterface) then {
    diag_log "[MWF] Client: Waiting for server handshake before intro...";

    private _localBootDeadline = diag_tickTime + 120;
    waitUntil {
        uiSleep 0.25;
        (missionNamespace getVariable ["MWF_ServerInitialized", false]) ||
        (missionNamespace getVariable ["MWF_ServerReady", false]) ||
        {diag_tickTime >= _localBootDeadline}
    };

    if (
        (missionNamespace getVariable ["MWF_ServerInitialized", false]) ||
        (missionNamespace getVariable ["MWF_ServerReady", false])
    ) then {
        if !(uiNamespace getVariable ["MWF_IntroCinematicQueued", false]) then {
            uiNamespace setVariable ["MWF_IntroCinematicQueued", true];
            diag_log "[MWF] Client: Server ready. Queueing intro cinematic.";
            [] spawn {
                uiSleep 0.25;
                [] call MWF_fnc_playIntroCinematic;
            };
        };
    } else {
        diag_log "[MWF] Client: WARNING! Server initialization timed out.";
    };

    missionNamespace setVariable ["MWF_LocalInitReady", true];
};

diag_log "[MWF] init.sqf execution finished.";
