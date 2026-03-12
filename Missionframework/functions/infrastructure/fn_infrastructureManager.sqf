/*
    Author: Theane using gemini
    Function: KPIN_fnc_infrastructureManager
    Description: 
    Monitors and tracks the destruction of fixed enemy infrastructure (Roadblocks and HQs). 
    Increments global counters and triggers an immediate save via the Save Manager.
*/

if (!isServer) exitWith {};

params [["_mode", "INIT"]];

// --- MODE: INIT (Setup the global event listener) ---
if (_mode == "INIT") exitWith {
    diag_log "[KPIN INFRA]: Initializing Infrastructure Monitor...";

    // Listener for infrastructure destruction events
    ["KPIN_Infra_Destroyed", {
        params ["_type"]; // Expected: "HQ" or "ROADBLOCK"

        if (_type == "HQ") then {
            private _current = missionNamespace getVariable ["KPIN_DestroyedHQs", 0];
            missionNamespace setVariable ["KPIN_DestroyedHQs", _current + 1, true];
            diag_log format ["[KPIN INFRA]: HQ Destroyed. New Total: %1", _current + 1];
        };

        if (_type == "ROADBLOCK") then {
            private _current = missionNamespace getVariable ["KPIN_DestroyedRoadblocks", 0];
            missionNamespace setVariable ["KPIN_DestroyedRoadblocks", _current + 1, true];
            diag_log format ["[KPIN INFRA]: Roadblock Destroyed. New Total: %1", _current + 1];
        };

        // Strict Rule: Always trigger an instant save when infrastructure is removed
        ["SAVE"] call KPIN_fnc_saveManager;
        
    }] call CBA_fnc_addEventHandler;
};

// --- MODE: REGISTER (Attach event handler to specific objects) ---
// Use this during spawn/initialization of roadblocks or HQs
if (_mode == "REGISTER") exitWith {
    params ["", "_object", "_type"]; // ["REGISTER", _object, "HQ"]

    if (isNull _object) exitWith { diag_log "[KPIN INFRA]: Error - Attempted to register null object."; };

    // Tag the object so the EH knows what it is
    _object setVariable ["KPIN_InfraType", _type];

    _object addEventHandler ["Killed", {
        params ["_unit"];
        private _type = _unit getVariable ["KPIN_InfraType", "ROADBLOCK"];
        
        // Broadcast to the server-side listener
        ["KPIN_Infra_Destroyed", [_type]] call CBA_fnc_serverEvent;
    }];
};
