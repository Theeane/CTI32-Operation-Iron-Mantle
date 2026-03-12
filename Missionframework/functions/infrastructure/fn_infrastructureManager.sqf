/*
    Author: Theane using gemini
    Function: KPIN_fnc_infrastructureManager
    Description: 
    Manages independent military infrastructure (HQs and Roadblocks). 
    Handles supply rewards, campaign progression, and triggers intel discovery 
    logic upon spawn.
*/

if (!isServer) exitWith {};

params [["_mode", "INIT"]];

// --- MODE: INIT ---
// Sets up the global listener for infrastructure destruction
if (_mode == "INIT") exitWith {
    diag_log "[KPIN INFRA]: Infrastructure Manager Initialized.";

    ["KPIN_Infra_Destroyed", {
        params ["_type"]; // "HQ" or "ROADBLOCK"

        private _supplyReward = 0;
        
        if (_type == "HQ") then {
            _supplyReward = 50;
            private _curr = missionNamespace getVariable ["KPIN_DestroyedHQs", 0];
            missionNamespace setVariable ["KPIN_DestroyedHQs", _curr + 1, true];
        };
        
        if (_type == "ROADBLOCK") then {
            _supplyReward = 20;
            private _curr = missionNamespace getVariable ["KPIN_DestroyedRoadblocks", 0];
            missionNamespace setVariable ["KPIN_DestroyedRoadblocks", _curr + 1, true];
        };

        // 1. Update Global Supplies
        private _totalSupplies = missionNamespace getVariable ["KPIN_GlobalSupplies", 0];
        missionNamespace setVariable ["KPIN_GlobalSupplies", _totalSupplies + _supplyReward, true];

        // 2. Trigger Save
        ["SAVE"] call KPIN_fnc_saveManager;

        diag_log format ["[KPIN INFRA]: %1 destroyed. Reward: %2 Supplies. Progression updated.", _type, _supplyReward];
        
        // Notification to players via CBA Event
        ["KPIN_Notify", ["Objective Complete", format ["%1 neutralized. Received %2 supplies.", _type, _supplyReward]]] call CBA_fnc_globalEvent;

    }] call CBA_fnc_addEventHandler;
};

// --- MODE: REGISTER ---
// Called for each HQ or Roadblock when they spawn in (at 1km range)
if (_mode == "REGISTER") exitWith {
    params ["", "_object", "_type"]; // ["REGISTER", _object, "HQ"]

    if (isNull _object) exitWith {};

    // Tag the object for the Event Handler
    _object setVariable ["KPIN_InfraType", _type, true];

    // 1. Trigger the Intel Spawn Check (70% base chance, modified by Intel Pool)
    ["SPAWN_INTEL", [getPos _object, _type]] call KPIN_fnc_intelManager;

    // 2. Add Destruction Listener
    _object addEventHandler ["Killed", {
        params ["_unit"];
        private _type = _unit getVariable ["KPIN_InfraType", "ROADBLOCK"];
        
        // Broadcast to server to process rewards and save
        ["KPIN_Infra_Destroyed", [_type]] call CBA_fnc_serverEvent;
    }];

    diag_log format ["[KPIN INFRA]: Registered %1 at %2. Intel check triggered.", _type, getPos _object];
};
