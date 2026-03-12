/*
    Author: Theane using gemini
    Function: Grand Finale Logic (The Decapitation Strike)
    Description: Monitors campaign progress. Automatically triggers the final mission, 
    cleans up non-essential tasks, and spawns the persistent final base.
*/

if (!isServer) exitWith {};

// Track if the finale has already started to avoid double execution
if (!isNil "CTI32_FinalMissionActive") exitWith {};

diag_log "[CTI32 FINAL] Manager initialized and monitoring progress.";

// 1. MONITOR PROGRESS
waitUntil {
    sleep 30;
    // Trigger condition: At least 1 Main Operation (Grand Op) is completed
    (missionNamespace getVariable ["CTI32_MainOpsCompleted", 0]) >= 1
};

CTI32_FinalMissionActive = true;
publicVariable "CTI32_FinalMissionActive";

// 2. THE GLOBAL ALERT
// Sending a priority notification to all players
["PriorityAlert", ["THE DECAPITATION STRIKE", "Enemy Leader location identified. All other operations suspended!"]] remoteExec ["BIS_fnc_showNotification", 0];

// 3. THE QUEST WIPE (Cleanup other tasks)
// Close all active side missions and ops unless players are inside the zone
{
    private _missionPos = _x getVariable ["CTI32_MissionPos", [0,0,0]];
    private _playersNearby = allPlayers anyWith {(_x distance _missionPos) < 1000};

    if (!_playersNearby) then {
        // Close mission logic (example: cancel task and delete units)
        [_x] call CTI32_fnc_cancelMission; 
        diag_log format ["[CTI32 FINAL] Mission %1 cancelled due to finale start.", _x];
    } else {
        diag_log format ["[CTI32 FINAL] Mission %1 kept active (players in zone).", _x];
    };
} forEach (missionNamespace getVariable ["CTI32_ActiveQuests", []]);

// 4. SPAWN FINAL BASE (Persistent units)
// The position for the final strike (could be a fixed HQ or random from a pool)
private _finalPos = [worldSize / 2, worldSize / 2, 0]; // Placeholder for actual HQ logic

// Create the leader and his escort
private _group = createGroup [east, true];
private _leader = _group createUnit ["O_Officer_F", _finalPos, [], 0, "NONE"];

// FLAG: Protection from cleanup_system.sqf
_leader setVariable ["CTI32_IsPersistent", true, true];

// Set Leader Hostility Logic (Hostile when outside FOB Alpha)
[_leader] spawn {
    params ["_target"];
    while {alive _target} do {
        private _nearFOB = (getPos _target distance (missionNamespace getVariable ["CTI32_FOB_Alpha_Pos", [0,0,0]])) < 200;
        
        if (!_nearFOB) then {
            _target setBehaviour "COMBAT";
            _target setCombatMode "RED";
            // Ensure no rep penalty when killed while hostile
            _target setVariable ["CTI32_PenaltyFree", true, true];
        };
        sleep 5;
    };
};

// 5. LOCK CIVILIAN REPUTATION
// No more buying rep or gaining/losing via missions
CTI32_ReputationLocked = true;
publicVariable "CTI32_ReputationLocked";

diag_log "[CTI32 FINAL] The Decapitation Strike is now ACTIVE.";
