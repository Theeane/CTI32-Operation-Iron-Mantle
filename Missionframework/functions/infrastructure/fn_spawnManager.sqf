/*
    Author: Theane / ChatGPT
    Function: fn_spawnManager
    Project: Military War Framework

    Description:
    Handles spawn manager for the infrastructure system.
*/

if (!isServer) exitWith {};

params [["_mode", "REFRESH_FIXED_BASES"]];

// --- MODE: REFRESH_FIXED_BASES ---
// Called after "Clean Slate" or server restart to respawn discovered bases
if (_mode == "REFRESH_FIXED_BASES") exitWith {
    private _fixedBases = missionNamespace getVariable ["MWF_FixedInfrastructure", []];
    
    diag_log format ["[KPIN SPAWN]: Refreshing %1 fixed bases...", count _fixedBases];

    {
        private _pos = _x;
        // Check if there is already something there to avoid double-spawning
        if (count (nearestObjects [_pos, ["House", "Strategic"], 10]) == 0) then {
            // Determine if it was an HQ or Roadblock (Logic could be expanded to save type)
            // For now, we spawn as HQ if near a major road/open area, or use a default
            ["CREATE_BASE", [_pos, "HQ"]] call MWF_fnc_spawnManager;
        };
    } forEach _fixedBases;
};

// --- MODE: CREATE_BASE ---
// Handles the actual placement of the composition
if (_mode == "CREATE_BASE") exitWith {
    params ["", "_params"];
    _params params ["_pos", "_type"];

    // 1. Spawn the Composition (Example classnames - replace with your preset variables)
    private _composition = objNull;
    if (_type == "HQ") then {
        _composition = createVehicle ["Land_Cargo_HQ_V1_F", _pos, [], 0, "NONE"]; // Replace with actual comp
    } else {
        _composition = createVehicle ["Land_BagBunker_Large_F", _pos, [], 0, "NONE"]; // Replace with actual comp
    };

    // 2. Register with Infrastructure Manager
    // This attaches the "Killed" EH and triggers the Intel-check
    ["REGISTER", _composition, _type] call MWF_fnc_infrastructureManager;

    diag_log format ["[KPIN SPAWN]: %1 created at %2 and registered.", _type, _pos];
    _composition
};

// --- MODE: DYNAMIC_CHECK ---
// A background loop (started in initServer) that checks for players near potential base sites
if (_mode == "DYNAMIC_CHECK") exitWith {
    while {true} do {
        sleep 10; // Check every 10 seconds to save performance

        // Potential positions logic: This would normally pull from a list of predefined 
        // locations on the map that aren't inside zones.
        private _potentialLocations = missionNamespace getVariable ["MWF_PotentialBaseSites", []];
        private _players = allPlayers select {alive _x};

        {
            private _sitePos = _x;
            // If player within 1000m and site is not already spawned
            if ({_x distance _sitePos < 1000} count _players > 0) then {
                // Check if this site has already been destroyed (using save data counters/log)
                // If OK:
                ["CREATE_BASE", [_sitePos, "ROADBLOCK"]] call MWF_fnc_spawnManager;
                
                // Remove from potential list for this session so it doesn't double-spawn
                _potentialLocations = _potentialLocations - [_sitePos];
                missionNamespace setVariable ["MWF_PotentialBaseSites", _potentialLocations];
            };
        } forEach _potentialLocations;
    };
};
