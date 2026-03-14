/*
    Author: Theane / ChatGPT
    Function: fn_abandonManager
    Project: Military War Framework

    Description:
    Handles abandon manager for the zones system.
*/

if (!isServer) exitWith {};

diag_log "[Iron Mantle] Abandon Manager started.";

while {true} do {
    {
        private _veh = _x;
        
        // Only track vehicles that are not static/wrecks and are alive
        if (alive _veh && !(_veh isKindOf "StaticWeapon")) then {
            
            private _isPermanent = _veh getVariable ["MWF_isPermanent", false];
            private _isBuilt     = _veh getVariable ["MWF_isBuiltByPlayer", false];

            // Only check vehicles that have been touched or bought by players
            if (_isPermanent || _isBuilt) then {
                
                // 1. Check for nearby players (500m safety zone)
                private _nearPlayers = allPlayers select { _x distance _veh < 500 };
                
                // 2. Check for nearby Friendly Bases (200m safety zone)
                // Assuming MWF_FriendlyZones contains [markerName, tier]
                private _nearFOB = MWF_ActiveZones select { (getMarkerPos (_x # 0)) distance _veh < 200 };

                // 3. If abandoned (No players and no base nearby)
                if (count _nearPlayers == 0 && count _nearFOB == 0) then {
                    
                    private _abandonTick = _veh getVariable ["MWF_abandonTick", 0];
                    _veh setVariable ["MWF_abandonTick", _abandonTick + 1];

                    // If abandoned for 3 ticks (Approx 30 minutes total)
                    if (_abandonTick >= 3) then {
                        diag_log format ["[Iron Mantle] Deleting abandoned vehicle: %1 at %2", typeOf _veh, getPos _veh];
                        deleteVehicle _veh;
                    };
                } else {
                    // Reset timer if someone is nearby or vehicle is home
                    if (_veh getVariable ["MWF_abandonTick", 0] != 0) then {
                        _veh setVariable ["MWF_abandonTick", 0];
                    };
                };
            };
        };
    } forEach vehicles;

    sleep 600; // 10 minute interval
};
