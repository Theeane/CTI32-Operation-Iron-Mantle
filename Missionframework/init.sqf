/*
    Author: OpenAI / repaired from patch
    File: init.sqf
    Project: Military War Framework (MWF)

    Description:
    Master entry point. Handles early server state and safe client bootstrap.
    The intro camera now plays once after server readiness without forcing a respawn menu
    or stripping the player's gear during normal join/continue flow.
*/

enableSaving [false, false];

if (isServer) then {
    diag_log "[MWF] Server: Starting Global State Manager...";
    ["INIT"] call MWF_fnc_globalStateManager;
};

if (hasInterface) then {
    diag_log "[MWF] Client: Waiting for server to be ready...";

    private _localBootDeadline = diag_tickTime + 120;
    waitUntil {
        uiSleep 0.25;
        (missionNamespace getVariable ["MWF_ServerInitialized", false]) ||
        {diag_tickTime >= _localBootDeadline}
    };

    if (!isNil "MWF_fnc_initLoadoutSystem") then {
        [] spawn MWF_fnc_initLoadoutSystem;
    };

    if (missionNamespace getVariable ["MWF_ServerInitialized", false]) then {
        diag_log "[MWF] Client: Server ready. Starting intro cinematic.";
        [] spawn MWF_fnc_playIntroCinematic;
    } else {
        diag_log "[MWF] Client: WARNING! Server initialization timed out.";
    };

    missionNamespace setVariable ["MWF_LocalInitReady", true];
};

diag_log "[MWF] init.sqf execution finished.";
