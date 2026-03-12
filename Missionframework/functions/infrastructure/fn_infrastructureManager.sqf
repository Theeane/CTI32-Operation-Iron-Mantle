/*
    Author: Theane using gemini
    Function: KPIN_fnc_infrastructureManager
    Description: 
    Manages independent infrastructure (HQs/Roadblocks). Handles supply rewards upon 
    destruction and coordinates with the Intel Manager during spawn-in (1km range).
*/

if (!isServer) exitWith {};

params [["_mode", "INIT"]];

if (_mode == "INIT") exitWith {
    ["KPIN_Infra_Destroyed", {
        params ["_type"];

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

        // Add to global supplies
        private _totalSupplies = missionNamespace getVariable ["KPIN_GlobalSupplies", 0];
        missionNamespace setVariable ["KPIN_GlobalSupplies", _totalSupplies + _supplyReward, true];

        diag_log format ["[KPIN INFRA]: %1 Destroyed. Reward: %2 Supplies.", _type, _supplyReward];
        ["SAVE"] call KPIN_fnc_saveManager;
        
    }] call CBA_fnc_addEventHandler;
};

if (_mode == "REGISTER") exitWith {
    params ["", "_object", "_type"];
    
    _object setVariable ["KPIN_InfraType", _type];
    
    // Trigger Intel chance check when the base spawns
    ["SPAWN_INTEL", getPos _object, _type] call KPIN_fnc_intelManager;

    _object addEventHandler ["Killed", {
        params ["_unit"];
        private _type = _unit getVariable ["KPIN_InfraType", "ROADBLOCK"];
        ["KPIN_Infra_Destroyed", [_type]] call CBA_fnc_serverEvent;
    }];
};
