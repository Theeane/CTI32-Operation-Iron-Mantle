/*
    Author: Theane / ChatGPT
    Function: fn_spawnManager
    Project: Military War Framework

    Description:
    Handles infrastructure spawning.
    Updated to consume threat outputs when deciding what pressure profile to create.
*/

if (!isServer) exitWith {};

params [["_mode", "REFRESH_FIXED_BASES"], ["_params", []]];

// --- MODE: REFRESH_FIXED_BASES ---
if (_mode == "REFRESH_FIXED_BASES") exitWith {
    private _fixedBases = missionNamespace getVariable ["MWF_FixedInfrastructure", []];

    diag_log format ["[MWF SPAWN] Refreshing %1 fixed bases...", count _fixedBases];

    {
        private _pos = _x;
        if (count (nearestObjects [_pos, ["House", "Strategic"], 10]) == 0) then {
            ["CREATE_BASE", [_pos, "HQ"]] call MWF_fnc_spawnManager;
        };
    } forEach _fixedBases;
};

// --- MODE: CREATE_BASE ---
if (_mode == "CREATE_BASE") exitWith {
    _params params [
        ["_pos", [], [[]]],
        ["_type", "ROADBLOCK", [""]]
    ];

    if !((_pos isEqualType []) && {count _pos >= 2}) exitWith {objNull};

    private _composition = objNull;
    if (toUpper _type == "HQ") then {
        _composition = createVehicle ["Land_Cargo_HQ_V1_F", _pos, [], 0, "NONE"];
    } else {
        _composition = createVehicle ["Land_BagBunker_Large_F", _pos, [], 0, "NONE"];
    };

    if (!isNull _composition && !isNil "MWF_fnc_infrastructureManager") then {
        ["REGISTER", [_composition, _type]] call MWF_fnc_infrastructureManager;
    };

    diag_log format ["[MWF SPAWN] %1 created at %2 and registered.", _type, _pos];
    _composition
};

// --- MODE: DYNAMIC_CHECK ---
if (_mode == "DYNAMIC_CHECK") exitWith {
    while {true} do {
        private _checkDelay = ((missionNamespace getVariable ["MWF_ThreatQRFInterval", 900]) / 24) max 10;
        sleep _checkDelay;

        private _potentialLocations = + (missionNamespace getVariable ["MWF_PotentialBaseSites", []]);
        private _players = allPlayers select {alive _x};
        private _roadblockPressure = missionNamespace getVariable ["MWF_ThreatRoadblockPressure", 0];
        private _hqPressure = missionNamespace getVariable ["MWF_ThreatHQPressure", 0];
        private _patrolDensity = missionNamespace getVariable ["MWF_ThreatPatrolDensity", 0.2];

        {
            private _sitePos = _x;
            if ({_x distance _sitePos < 1000} count _players > 0) then {
                if ((random 1) <= (_patrolDensity min 0.85)) then {
                    private _spawnType = if (_hqPressure > (_roadblockPressure + 15) && {random 1 < 0.25}) then {"HQ"} else {"ROADBLOCK"};
                    ["CREATE_BASE", [_sitePos, _spawnType]] call MWF_fnc_spawnManager;
                };

                _potentialLocations = _potentialLocations - [_sitePos];
                missionNamespace setVariable ["MWF_PotentialBaseSites", _potentialLocations];
            };
        } forEach _potentialLocations;
    };
};
