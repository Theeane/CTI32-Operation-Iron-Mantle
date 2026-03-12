/*
    Author: Theane using gemini
    Function: KPIN_fnc_intelManager
    Description: 
    Handles the discovery logic for Intel (Laptops/Officers). 
    If discovered via optics, it pings the map and locks the base position into the Save Manager.
*/

if (!isServer) exitWith {};

params [["_mode", "SPAWN_CHECK"]];

// --- MODE: SPAWN_INTEL (Called when HQ/Roadblock spawns at 1km) ---
if (_mode == "SPAWN_INTEL") exitWith {
    params ["", "_basePos", "_type"]; // _type: "HQ" or "ROADBLOCK"

    private _intelPool = missionNamespace getVariable ["KPIN_IntelPool", 0];
    // Logic: Higher pool = lower chance. 
    // Example: Base 70% chance, -5% per 10 intel in pool.
    private _chance = (70 - (_intelPool / 2)) max 10;

    if (random 100 <= _chance) then {
        private _intelType = if (random 100 > 50) then {"Laptop"} else {"Officer"};
        private _intelObj = objNull;

        // Spawn logic for the specific composition (placeholder for actual spawn)
        // _intelObj = createVehicle ... 
        
        _intelObj setVariable ["KPIN_isDiscovered", false, true];
        _intelObj setVariable ["KPIN_parentBasePos", _basePos, true];

        // Start the detection loop for this specific intel
        [_intelObj] spawn KPIN_fnc_intelManager; 
    };
};

// --- MODE: DETECTION_LOOP (Monitoring player optics/zoom) ---
if (canSuspend) then {
    params ["_intelObj"];
    
    while {alive _intelObj && !(_intelObj getVariable ["KPIN_isDiscovered", false])} do {
        sleep 2;
        
        private _potentialSpotters = allPlayers select {(_x distance _intelObj) < 800};
        
        {
            private _player = _x;
            // Check if player is looking at the object and using optics (zoom)
            if (cameraView == "GUNNER" || cameraView == "INTERNAL") then {
                private _target = cursorObject;
                if (_target == _intelObj) then {
                    [_intelObj, _player] call {
                        params ["_obj", "_spotter"];
                        _obj setVariable ["KPIN_isDiscovered", true, true];
                        
                        // 1. Create Map Ping/Marker
                        private _m = createMarker [format ["intel_%1", getPos _obj], getPos _obj];
                        _m setMarkerType "hd_objective";
                        _m setMarkerText "Intel Discovered";
                        _m setMarkerColor "ColorYellow";

                        // 2. Lock Base Position in Save Manager
                        private _basePos = _obj getVariable ["KPIN_parentBasePos", [0,0,0]];
                        private _fixedBases = missionNamespace getVariable ["KPIN_FixedInfrastructure", []];
                        _fixedBases pushBackUnique _basePos;
                        missionNamespace setVariable ["KPIN_FixedInfrastructure", _fixedBases, true];

                        ["SAVE"] call KPIN_fnc_saveManager;

                        diag_log "[KPIN INTEL]: Intel discovered! Position locked in persistence.";
                    };
                };
            };
        } forEach _potentialSpotters;

        // Cleanup: If no players nearby and not discovered, this loop dies with the object despawn
        if ({_x distance _intelObj < 1200} count allPlayers == 0) exitWith {};
    };
};
