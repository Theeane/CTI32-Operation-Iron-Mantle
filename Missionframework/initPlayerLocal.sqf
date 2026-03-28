/*
    Author: OpenAI / Operation Iron Mantle
    File: initPlayerLocal.sqf
    Project: Military War Framework

    Description:
    Client-side entry point. Waits for the server to reach a stable state 
    before triggering the UI and interaction bootstrap.
*/

if (!hasInterface) exitWith {};

// 1. Initial Client State
missionNamespace setVariable ["MWF_ClientInitStage", "WAITING_FOR_SERVER"];
missionNamespace setVariable ["MWF_ClientInitComplete", false];
missionNamespace setVariable ["MWF_DeployUiClosed", false];

// 2. The Server Handshake
// We wait for the server to signal that critical assets (like the MOB) are spawned.
private _serverDeadline = diag_tickTime + 60;
waitUntil {
    uiSleep 0.5;
    (missionNamespace getVariable ["MWF_ServerReady", false]) || 
    {(missionNamespace getVariable ["MWF_ServerBootStage", ""]) isEqualTo "CRITICAL_RELEASED"} ||
    {diag_tickTime >= _serverDeadline}
};

// Log if we had to proceed due to timeout
if (diag_tickTime >= _serverDeadline) then {
    diag_log "[MWF] WARNING: Client proceeding after server-wait timeout. Some assets might be missing.";
};

missionNamespace setVariable ["MWF_ClientInitStage", "SERVER_CONNECTED"];

// 3. UI and Systems Initialization
if (!isNil "MWF_fnc_initUI") then { [] call MWF_fnc_initUI; };

// 4. Initial Deploy Handler
// Since respawnOnStart = 1, the engine will trigger onPlayerRespawn automatically.
// However, we run a staggered bootstrap here as a safety net to ensure the first
// spawn is always captured and the MOB interactions are injected.
[] spawn {
    missionNamespace setVariable ["MWF_ClientInitStage", "INITIAL_BOOTSTRAP_WAVES"];

    {
        [_x] spawn {
            params ["_delay"];
            uiSleep _delay;

            if (isNull player || {!alive player}) exitWith {};

            // Trigger the main bootstrap (True = Initial Deploy)
            if (!isNil "MWF_fnc_handlePostSpawn") then {
                [true] call MWF_fnc_handlePostSpawn;
            };

            // Setup the laptop/terminal scroll menus
            if (!isNil "MWF_fnc_setupInteractions") then {
                [] spawn MWF_fnc_setupInteractions;
            };
        };
    } forEach [0.5, 2, 5, 10, 20];
};

// 5. Infrastructure and Environment
if (!isNil "MWF_fnc_initWorldLocal") then { [] spawn MWF_fnc_initWorldLocal; };

diag_log "[MWF] initPlayerLocal: Client handshake complete. Monitoring spawn events.";