/* Author: Theeane
    Description: 
    Monitors zone distances and handles spawn/despawn triggers.
    Uses dynamic radii passed via params.
*/

params [
    ["_pos", [0,0,0]], 
    ["_tier", 1], 
    ["_spawnRadius", 800],    // Default spawn distance
    ["_despawnRadius", 1200]  // Default cleanup distance
];

private _isSpawned = false;

while {true} do {
    // Find the distance to the nearest player
    private _distances = allPlayers apply { _x distance _pos };
    private _minDist = if (count _distances > 0) then { selectMin _distances } else { 99999 };

    // 1. SPAWN TRIGGER
    if (_minDist < _spawnRadius && !_isSpawned) then {
        [_pos, _tier] spawn CTI_fnc_spawnZoneAssets;
        _isSpawned = true;
        diag_log format ["[Iron Mantle] Zone activated at %1 (Tier %2)", _pos, _tier];
    };

    // 2. DESPAWN TRIGGER
    if (_minDist > _despawnRadius && _isSpawned) then {
        [_pos, _despawnRadius] spawn CTI_fnc_despawnZoneAssets;
        _isSpawned = false;
        diag_log format ["[Iron Mantle] Zone deactivated at %1", _pos];
    };

    sleep 10; // Check every 10 seconds for performance
};
