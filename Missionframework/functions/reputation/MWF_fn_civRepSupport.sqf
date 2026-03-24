/*
    Author: OpenAI / ChatGPT
    Function: fn_civRepSupport
    Project: Military War Framework

    Description:
    Handles civilian-reputation-driven rebel support behavior.

    Modes:
    - SYNC_RELATIONS : updates Resistance friendliness toward BLUFOR / OPFOR based on civ rep
    - TRIGGER        : rolls for a rebel support group at a zone / mission context
*/

if (!isServer) exitWith { false };

params [
    ["_mode", "TRIGGER", [""]],
    ["_params", [], [[]]]
];

private _syncRelations = {
    private _rep = missionNamespace getVariable ["MWF_CivRep", 0];

    resistance setFriend [civilian, 1];
    civilian setFriend [resistance, 1];

    if (_rep >= (missionNamespace getVariable ["MWF_CivRep_PositiveSupportThreshold", 25])) exitWith {
        resistance setFriend [west, 1];
        west setFriend [resistance, 1];
        resistance setFriend [east, 0];
        east setFriend [resistance, 0];
    };

    if (_rep <= -(abs (missionNamespace getVariable ["MWF_CivRep_NegativeSupportThreshold", -25]))) exitWith {
        resistance setFriend [west, 0];
        west setFriend [resistance, 0];
        resistance setFriend [east, 1];
        east setFriend [resistance, 1];
    };

    resistance setFriend [west, 0];
    west setFriend [resistance, 0];
    resistance setFriend [east, 0];
    east setFriend [resistance, 0];
};

if ((toUpper _mode) isEqualTo "SYNC_RELATIONS") exitWith {
    call _syncRelations;
    true
};

call _syncRelations;

_params params [
    ["_center", [0,0,0], [[]]],
    ["_contextKey", "", [""]],
    ["_anchor", objNull, [objNull]]
];

if !(_center isEqualType [] && {count _center >= 2}) exitWith { false };

private _rep = missionNamespace getVariable ["MWF_CivRep", 0];
private _positiveThreshold = missionNamespace getVariable ["MWF_CivRep_PositiveSupportThreshold", 25];
private _negativeThreshold = abs (missionNamespace getVariable ["MWF_CivRep_NegativeSupportThreshold", -25]);
private _isPositive = _rep >= _positiveThreshold;
private _isNegative = _rep <= -_negativeThreshold;
if !(_isPositive || _isNegative) exitWith { false };

private _cooldowns = missionNamespace getVariable ["MWF_CivRepSupportCooldowns", createHashMap];
if !(_cooldowns isEqualType createHashMap) then {
    _cooldowns = createHashMap;
};

if (_contextKey isNotEqualTo "") then {
    private _nextAllowed = _cooldowns getOrDefault [_contextKey, -1];
    if (_nextAllowed > serverTime) exitWith { false };
};

private _chance = 0;
if (_isPositive) then {
    private _alpha = ((_rep - _positiveThreshold) max 0) / (100 - _positiveThreshold);
    _chance = 0.10 + (0.90 * _alpha);
} else {
    private _alpha = (((abs _rep) - _negativeThreshold) max 0) / (100 - _negativeThreshold);
    _chance = 0.25 + (0.75 * _alpha);
};

if ((random 1) > _chance) exitWith {
    if (_contextKey isNotEqualTo "") then {
        _cooldowns set [_contextKey, serverTime + 900];
        missionNamespace setVariable ["MWF_CivRepSupportCooldowns", _cooldowns, true];
    };
    false
};

private _resPreset = missionNamespace getVariable ["MWF_RES_Preset", createHashMap];
private _pool = [];
private _repStrength = (abs _rep) max 25;
private _maxTier = if (_repStrength >= 90) then {5} else {if (_repStrength >= 75) then {4} else {if (_repStrength >= 55) then {3} else {2}}};
if (!isNil "MWF_fnc_getEffectiveEnemyTier") then {
    _maxTier = [_maxTier] call MWF_fnc_getEffectiveEnemyTier;
};
for "_tier" from 1 to _maxTier do {
    private _key = format ["Infantry_T%1", _tier];
    private _tierPool = _resPreset getOrDefault [_key, []];
    if (_tierPool isEqualType []) then { _pool append _tierPool; };
};
if (_pool isEqualTo []) then {
    _pool = missionNamespace getVariable ["MWF_CIV_Units", missionNamespace getVariable ["MWF_Civ_List", ["I_G_Soldier_F", "I_G_Soldier_AR_F", "I_G_medic_F"]]];
};
if (_pool isEqualTo []) exitWith { false };

private _spawnPos = [_center, 90, 220, 5, 0, 0.45, 0, [], [_center, _center]] call BIS_fnc_findSafePos;
if !(_spawnPos isEqualType [] && {count _spawnPos >= 2}) then {
    _spawnPos = _center vectorAdd [60 - random 120, 60 - random 120, 0];
};

private _group = createGroup [resistance, true];
private _unitCount = if (_repStrength >= 90) then {6} else {if (_repStrength >= 70) then {5} else {4}};
private _spawnedUnits = [];
for "_i" from 1 to _unitCount do {
    private _class = selectRandom _pool;
    private _unit = _group createUnit [_class, _spawnPos, [], 8, "FORM"];
    if (!isNull _unit) then {
        _unit setSkill (0.35 + random 0.25);
        _unit setVariable ["MWF_RebelSupportUnit", true, true];
        _unit setVariable ["MWF_RebelSupportPolarity", if (_isPositive) then {"BLUFOR"} else {"OPFOR"}, true];
        if (!isNil "MWF_fnc_initInteractions") then {
            [_unit] call MWF_fnc_initInteractions;
        };
        _spawnedUnits pushBack _unit;
    };
};

if (_spawnedUnits isEqualTo []) exitWith {
    deleteGroup _group;
    false
};

_group setBehaviour "AWARE";
_group setCombatMode "RED";
private _wp = _group addWaypoint [_center, 0];
_wp setWaypointType "SAD";
_wp setWaypointBehaviour "AWARE";
_wp setWaypointCombatMode "RED";

if (_contextKey isNotEqualTo "") then {
    _cooldowns set [_contextKey, serverTime + 900];
    missionNamespace setVariable ["MWF_CivRepSupportCooldowns", _cooldowns, true];
};

private _msg = if (_isPositive) then {
    "Local rebel cells are moving to assist BLUFOR."
} else {
    "Hostile rebel cells are moving to support OPFOR."
};
[_msg] remoteExec ["systemChat", 0];

diag_log format ["[MWF REP] Rebel support triggered. Context: %1 | Rep: %2 | Chance: %3 | Units: %4 | Alignment: %5", _contextKey, _rep, _chance, count _spawnedUnits, if (_isPositive) then {"BLUFOR"} else {"OPFOR"}];
true
