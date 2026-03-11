/* Author: Theeane
    Description: 
    Main zone controller. Handles dynamic spawning, area capture logic, 
    and performance optimization based on player distance.
*/

params [
    ["_pos", [0,0,0]],            // Position of the zone
    ["_tier", 1],                 // Tier level (1-5)
    ["_marker", ""],              // The map marker associated with the zone
    ["_spawnRadius", 800],        // Distance to spawn assets
    ["_despawnRadius", 1200]      // Distance to clean up assets
];

if (!isServer) exitWith {}; // Only the server (or HC) should run zone logic

// --- PERFORMANCE AUTO-SCALE ---
// Increase ranges if a Headless Client is detected to take advantage of extra CPU
if (!isNil "HC1") then {
    _spawnRadius = 1200;
    _despawnRadius = 1600;
};

private _isSpawned = false;
private _sideOwner = east; // Zones start as enemy controlled
private _isCaptured = false;

// --- MAIN MONITORING LOOP ---
while {true} do {
    // 1. Calculate distance to the nearest player
    private _distances = allPlayers apply { _x distance _pos };
    private _minDist = if (count _distances > 0) then { selectMin _distances } else { 99999 };

    // 2. DYNAMIC SPAWN LOGIC
    if (_minDist < _spawnRadius && !_isSpawned && !_isCaptured) then {
        [_pos, _tier] spawn CTI_fnc_spawnZoneAssets;
        _isSpawned = true;
        diag_log format ["[Iron Mantle] Zone %1 triggered spawn at %2m", _marker, _minDist];
    };

    // 3. DYNAMIC DESPAWN LOGIC
    if (_minDist > _despawnRadius && _isSpawned) then {
        [_pos, _despawnRadius] spawn CTI_fnc_despawnZoneAssets;
        _isSpawned = false;
        diag_log format ["[Iron Mantle] Zone %1 triggered despawn at %2m", _marker, _minDist];
    };

    // 4. CAPTURE LOGIC (Only if not already captured)
    if (!_isCaptured) then {
        private _playersInZone = allPlayers select { _x distance _pos < 150 }; // 150m cap range
        private _enemiesInZone = allUnits select { 
            (side _x == east || side _x == resistance) && 
            {_x distance _pos < 150} && 
            {alive _x} 
        };

        // If players are present and all defenders are dead
        if (count _playersInZone > 0 && count _enemiesInZone == 0) then {
            
            _isCaptured = true;
            _sideOwner = west;

            // Visual feedback on map
            _marker setMarkerColor "ColorGreen";
            
            // Economy Integration: Register zone for supply income
            private _tierData = GVAR_Zone_Tier_Settings get _tier;
            private _income = _tierData select 0;
            
            // Add to active zones for the Economy Manager to track
            GVAR_ActiveZones pushBack [_marker, _tier];
            publicVariable "GVAR_ActiveZones";

            // Global Notification
            [format["STR_MISSION_ZONE_CAPTURED", _marker, _income]] remoteExec ["systemChat", 0];
            ["TaskSucceeded", ["", format["Zone Captured! Income: +%1 Supplies", _income]]] remoteExec ["BIS_fnc_showNotification", _playersInZone];

            // Cleanup remaining enemy scripts if any
            if (_isSpawned) then {
                [_pos, _despawnRadius] spawn CTI_fnc_despawnZoneAssets;
                _isSpawned = false;
            };
        };
    };

    sleep 10; // Performance friendly sleep
};
