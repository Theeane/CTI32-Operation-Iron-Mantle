/*
    Author: Theane / ChatGPT
    Function: fn_spawnZoneAssets
    Project: Military War Framework

    Description:
    Handles spawn zone assets for the zones system.
*/

params ["_zonePos", "_tier"];

// 1. Fetch Tier settings from config
private _tierData = MWF_Zone_Tier_Settings get _tier;
private _multiplier = _tierData select 2;

// 2. SPAWN ENEMIES (OPFOR)
private _enemyCount = round (8 * _multiplier); 
for "_i" from 1 to _enemyCount do {
    private _spawnPos = [_zonePos, 10, 150, 3, 0, 20, 0] call BIS_fnc_findSafePos;
    private _unitClass = selectRandom MWF_Army_Infantry; 
    
    private _group = createGroup east;
    private _unit = _group createUnit [_unitClass, _spawnPos, [], 0, "NONE"];

    // --- LOGIC APPLICATION ---
    
    // Assign Rank: Determines detection range in undercoverManager (Elite vs Grunt)
    if (random 100 < (20 * _multiplier)) then {
        _unit setRank "SERGEANT"; // Becomes Elite (Higher detection range)
    } else {
        _unit setRank "PRIVATE";  // Becomes Grunt (Lower detection range)
    };

    // Chance for the soldier to be an Informant (Intel Trading)
    if (random 100 < 15) then {
        _unit setVariable ["MWF_isInformant", true, true];
    };

    // Apply interaction suite (Search Body, Undercover, Hold-Action UI)
    [_unit] call MWF_fnc_initInteractions; 
    
    [_group, _zonePos, 150] call bis_fnc_taskPatrol;
};

// 3. SPAWN CIVILIANS
private _civCount = round (6 * _multiplier);
for "_i" from 1 to _civCount do {
    private _civClass = selectRandom MWF_Civ_List;
    private _spawnPos = [_zonePos, 20, 200, 3, 0, 20, 0] call BIS_fnc_findSafePos;
    
    private _group = createGroup civilian;
    private _civ = _group createUnit [_civClass, _spawnPos, [], 0, "NONE"];

    // Civilian Informants (Special Quests / Trade)
    if (random 100 < 25) then {
        _civ setVariable ["MWF_isInformant", true, true];
    };

    // Apply interaction suite (Talking / 5s UI Circle)
    [_civ] call MWF_fnc_initInteractions;
    
    [_group, _zonePos, 100] call bis_fnc_taskPatrol;
};

diag_log format ["[Iron Mantle] Zone Assets spawned at %1 with Tier %2", _zonePos, _tier];
