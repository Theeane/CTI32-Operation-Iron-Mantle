/*
    Author: KPIN
    Description: Monitors infrastructure (Roadblocks/HQs) and triggers the Save Manager.
    
    Rules:
    - Starts at 0, increments on destruction.
    - Uses CBA events to notify the Save Manager.
    - English only.
*/

if (!isServer) exitWith {};

params [["_mode", "INIT"]];

// --- MODE: INIT (Setup listeners for infrastructure) ---
if (_mode == "INIT") exitWith {
    diag_log "[KPIN INFRA]: Initializing Infrastructure Monitor...";

    // This event is triggered whenever an HQ or Roadblock is destroyed
    ["KPIN_Infra_Destroyed", {
        params ["_type"]; // "HQ" or "ROADBLOCK"

        if (_type == "HQ") then {
            private _current = missionNamespace getVariable ["KPIN_DestroyedHQs", 0];
            missionNamespace setVariable ["KPIN_DestroyedHQs", _current + 1, true];
            diag_log format ["[KPIN INFRA]: HQ Destroyed. Total: %1", _current + 1];
        };

        if (_type == "ROADBLOCK") then {
            private _current = missionNamespace getVariable ["KPIN_DestroyedRoadblocks", 0];
            missionNamespace setVariable ["KPIN_DestroyedRoadblocks", _current + 1, true];
            diag_log format ["[KPIN INFRA]: Roadblock Destroyed. Total: %1", _current + 1];
        };

        // Trigger an Instant Save after every destruction
        ["SAVE"] call KPIN_fnc_saveManager;
        
    }] call CBA_fnc_addEventHandler;
};

// --- MODE: REGISTER (Utility to tag objects as infrastructure) ---
// Use this to add EH to objects when they spawn
if (_mode == "REGISTER") exitWith {
    params ["", "_object", "_type"];

    _object addEventHandler ["Killed", {
        params ["_unit"];
        private _type = _unit getVariable ["KPIN_InfraType", "ROADBLOCK"];
        ["KPIN_Infra_Destroyed", [_type]] call CBA_fnc_serverEvent;
    }];
};
