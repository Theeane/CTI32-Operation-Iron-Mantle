/*
    Author: Theane / ChatGPT
    Function: fn_spawnZoneAssets
    Project: Military War Framework

    Description:
    Handles spawn zone assets for the zones system.
*/

params ["_zonePos", "_tier"];

private _effectiveTier = if (!isNil "MWF_fnc_getEffectiveEnemyTier") then { [_tier] call MWF_fnc_getEffectiveEnemyTier } else { (_tier max 1) min 5 };

// 1. Fetch Tier settings from config
private _tierData = MWF_Zone_Tier_Settings get _tier;
private _multiplier = _tierData select 2;

// 2. SPAWN ENEMIES (OPFOR)
private _enemyBaseCount = round (8 * _multiplier);
private _enemyCountDesired = if (!isNil "MWF_fnc_scaleSpawnCount") then {
    [_enemyBaseCount, missionNamespace getVariable ["MWF_AIZoneEnemyMultiplier", 1], 1, 64] call MWF_fnc_scaleSpawnCount
} else {
    _enemyBaseCount
};
private _enemyCount = if (!isNil "MWF_fnc_getAISpawnAllowance") then {
    [_enemyCountDesired, 0, _enemyCountDesired > 0] call MWF_fnc_getAISpawnAllowance
} else {
    _enemyCountDesired
};
for "_i" from 1 to _enemyCount do {
    private _spawnPos = [_zonePos, 10, 150, 3, 0, 20, 0] call BIS_fnc_findSafePos;
    private _opforPreset = missionNamespace getVariable ["MWF_OPFOR_Preset", createHashMap];
    private _pool = [];
    if (_opforPreset isEqualType createHashMap) then {
        for "_tierIndex" from 1 to _effectiveTier do {
            _pool append (_opforPreset getOrDefault [format ["Infantry_T%1", _tierIndex], []]);
        };
    };
    if (_pool isEqualTo []) then { _pool = ["O_Soldier_F", "O_Soldier_AR_F", "O_Soldier_GL_F"]; };
    private _unitClass = selectRandom _pool; 
    
    private _group = createGroup east;
    private _unit = _group createUnit [_unitClass, _spawnPos, [], 0, "NONE"];

    // --- LOGIC APPLICATION ---
    
    // Assign Rank: Determines detection range in undercoverManager (Elite vs Grunt)
    if (random 100 < (20 * _multiplier)) then {
        _unit setRank "SERGEANT"; // Becomes Elite (Higher detection range)
    } else {
        _unit setRank "PRIVATE";  // Becomes Grunt (Lower detection range)
    };

    // Legacy flat informants are disabled when the civ-rep informant system is active.
    if (missionNamespace getVariable ["MWF_LegacyZoneInformantsEnabled", false]) then {
        if (random 100 < 15) then {
            _unit setVariable ["MWF_isInformant", true, true];
        };
    };

    // Apply interaction suite (Search Body, Undercover, Hold-Action UI)
    [_unit] call MWF_fnc_initInteractions; 
    
    [_group, _zonePos, 150] call bis_fnc_taskPatrol;
};

// 3. SPAWN CIVILIANS
private _civBaseCount = round (6 * _multiplier);
private _civCountDesired = if (!isNil "MWF_fnc_scaleSpawnCount") then {
    [_civBaseCount, missionNamespace getVariable ["MWF_AIZoneCivilianMultiplier", 1], 0, 64] call MWF_fnc_scaleSpawnCount
} else {
    _civBaseCount
};
private _civCount = if (!isNil "MWF_fnc_getAISpawnAllowance") then {
    [_civCountDesired, 0, false] call MWF_fnc_getAISpawnAllowance
} else {
    _civCountDesired
};
for "_i" from 1 to _civCount do {
    private _civClass = selectRandom MWF_Civ_List;
    private _spawnPos = [_zonePos, 20, 200, 3, 0, 20, 0] call BIS_fnc_findSafePos;
    
    private _group = createGroup civilian;
    private _civ = _group createUnit [_civClass, _spawnPos, [], 0, "NONE"];

    // Legacy flat informants are disabled when the civ-rep informant system is active.
    if (missionNamespace getVariable ["MWF_LegacyZoneInformantsEnabled", false]) then {
        if (random 100 < 25) then {
            _civ setVariable ["MWF_isInformant", true, true];
        };
    };

    // Apply interaction suite (Talking / 5s UI Circle)
    [_civ] call MWF_fnc_initInteractions;
    
    [_group, _zonePos, 100] call bis_fnc_taskPatrol;
};

diag_log format ["[Iron Mantle] Zone Assets spawned at %1 with Tier %2 (effective %3) | Enemies: %4 | Civilians: %5 | Scaling: %6 | Unit cap: %7", _zonePos, _tier, _effectiveTier, _enemyCount, _civCount, missionNamespace getVariable ["MWF_PlayerScalingLabel", "9-16 Players (Medium Group)"], missionNamespace getVariable ["MWF_DynamicUnitCap", 100]];
