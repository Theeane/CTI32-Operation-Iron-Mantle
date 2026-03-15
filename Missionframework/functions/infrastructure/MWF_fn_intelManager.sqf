/*
    Author: Theane / ChatGPT
    Function: fn_intelManager
    Project: Military War Framework

    Description:
    Handles intel manager for the infrastructure system.
*/

if (!isServer) exitWith {};

params [["_mode", "SPAWN_INTEL"], ["_params", []]];

// --- MODE: SPAWN_INTEL ---
// Called when a Roadblock or HQ composition is spawned at 1km range
if (_mode == "SPAWN_INTEL") exitWith {
    _params params ["_basePos", "_type"];

    private _intelPool = missionNamespace getVariable ["MWF_IntelPool", 0];
    
    // Logic: 70% base chance, reduced by 5% for every 10 intel points already held. Minimum 10%.
    private _chance = (70 - (_intelPool / 2)) max 10;

    if (random 100 <= _chance) then {
        // Randomize between Laptop (object) or Officer (unit)
        private _intelType = if (random 100 > 50) then {"Laptop"} else {"Officer"};
        
        // Spawn logic (Placeholders for actual classnames from your presets)
        private _class = if (_intelType == "Laptop") then {"Land_Laptop_unfolded_F"} else {"O_Officer_F"};
        private _intelObj = createVehicle [_class, _basePos, [], 5, "NONE"];
        
        if (_intelType == "Officer") then {
            // Ensure officer doesn't run away immediately
            group _intelObj setBehaviour "SAFE";
            _intelObj disableAI "MOVE";
        };

        _intelObj setVariable ["MWF_isDiscovered", false, true];
        _intelObj setVariable ["MWF_parentBasePos", _basePos, true];

        // Start the detection loop for this specific intel object
        ["DETECTION_LOOP", [_intelObj]] spawn MWF_fnc_intelManager;
        
        diag_log format ["[KPIN INTEL]: %1 spawned at %2. Discovery chance was %3 percent.", _intelType, _basePos, _chance];
    };
};

// --- MODE: DETECTION_LOOP ---
// Monitored on the server, checking player line-of-sight and optics
if (_mode == "DETECTION_LOOP") exitWith {
    _params params ["_intelObj"];

    while {alive _intelObj && !(_intelObj getVariable ["MWF_isDiscovered", false])} do {
        sleep 2;

        private _potentialSpotters = allPlayers select {(_x distance _intelObj) < 800};
        
        {
            private _player = _x;
            
            // Check if player is looking through optics (Binoculars or Scopes)
            if (cameraView == "GUNNER" || cameraView == "INTERNAL") then {
                private _target = cursorObject;
                
                // If player is looking directly at the intel object
                if (_target == _intelObj) then {
                    _intelObj setVariable ["MWF_isDiscovered", true, true];
                    
                    // 1. Map Notification
                    private _m = createMarker [format ["intel_ping_%1", floor(random 1000)], getPos _intelObj];
                    _m setMarkerType "hd_objective";
                    _m setMarkerText "Intel Discovered";
                    _m setMarkerColor "ColorYellow";

                    // 2. Lock the base position in the persistent array
                    private _basePos = _intelObj getVariable ["MWF_parentBasePos", [0,0,0]];
                    private _fixed = missionNamespace getVariable ["MWF_FixedInfrastructure", []];
                    _fixed pushBackUnique _basePos;
                    missionNamespace setVariable ["MWF_FixedInfrastructure", _fixed, true];

                    // 3. Save progress immediately
                    ["SAVE"] call MWF_fnc_saveManager;

                    diag_log format ["[KPIN INTEL]: Base at %1 has been discovered and locked by %2.", _basePos, name _player];
                };
            };
        } forEach _potentialSpotters;

        // Cleanup: If no players are within 1200m and intel isn't discovered, stop monitoring
        if ({_x distance _intelObj < 1200} count allPlayers == 0) exitWith {
            deleteVehicle _intelObj;
        };
    };
};
