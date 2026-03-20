/*
    Author: OpenAI / ChatGPT
    Function: fn_applyMissionImpact
    Project: Military War Framework

    Description:
    Central strategic impact entrypoint for side missions, main operations, and future expansions.
    Applies deterministic tier/threat/economy changes while preserving special-case rules:
    - undercover/loud threat separation
    - temporary main-op threat progression blocks
    - temporary tier progression freezes
    - permanent Tier 3 floor after 50% map control
    - no stacking for tier-block operations
*/

if (!isServer) exitWith {createHashMap};

params [
    ["_profile", createHashMap, [createHashMap]],
    ["_context", createHashMap, [createHashMap]]
];

private _kind = toLower (_profile getOrDefault ["kind", "generic"]);
private _id = toLower str (_profile getOrDefault ["id", "unknown"]);
private _zoneId = toLower (_context getOrDefault ["zoneId", _profile getOrDefault ["zoneId", ""]]);
private _loud = _context getOrDefault ["loud", _profile getOrDefault ["loudRequired", true]];
private _threatDelta = _profile getOrDefault ["threatDelta", 0];
private _tierDelta = _profile getOrDefault ["tierDelta", 0];
private _supplies = _profile getOrDefault ["supplies", 0];
private _intel = _profile getOrDefault ["intel", 0];
private _fallbackSupplies = _profile getOrDefault ["fallbackSupplies", 200];
private _fallbackIntel = _profile getOrDefault ["fallbackIntel", 100];
private _blockTierProgressSeconds = _profile getOrDefault ["blockTierProgressSeconds", 0];
private _blockMainOpThreatSeconds = _profile getOrDefault ["blockMainOpThreatSeconds", 0];
private _note = _profile getOrDefault ["note", ""];

private _result = createHashMapFromArray [
    ["kind", _kind],
    ["id", _id],
    ["zoneId", _zoneId],
    ["loud", _loud],
    ["threatApplied", 0],
    ["tierApplied", 0],
    ["fallbackUsed", false],
    ["suppliesGranted", 0],
    ["intelGranted", 0],
    ["note", _note]
];

private _now = serverTime;
private _currentSupplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
private _currentIntel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];
private _notoriety = missionNamespace getVariable ["MWF_res_notoriety", 0];

private _score = missionNamespace getVariable ["MWF_WorldTierScore", 0];
private _halfMapLock = missionNamespace getVariable ["MWF_WorldTierHalfMapLock", false];
private _floorScore = if (_halfMapLock) then {200} else {0};
private _tierProgressBlockedUntil = missionNamespace getVariable ["MWF_WorldTierProgressBlockedUntil", 0];
private _tierBlockImmuneUntil = missionNamespace getVariable ["MWF_WorldTierBlockImmuneUntil", 0];
private _mainOpThreatBlockedUntil = missionNamespace getVariable ["MWF_MainOpThreatProgressBlockedUntil", 0];
private _threatPercent = missionNamespace getVariable ["MWF_GlobalThreatPercent", 0];

private _grantedSupplies = _supplies;
private _grantedIntel = _intel;
private _fallbackUsed = false;
private _effectiveThreatDelta = _threatDelta;
private _effectiveTierDelta = _tierDelta;
private _blockTierAlreadyActive = _blockTierProgressSeconds > 0 && {(_tierProgressBlockedUntil > _now) || (missionNamespace getVariable ["MWF_TierFreeze_Active", false])};
private _blockMainThreatAlreadyActive = _blockMainOpThreatSeconds > 0 && {_mainOpThreatBlockedUntil > _now};

if (_kind isEqualTo "main") then {
    if (_effectiveThreatDelta > 0 && {_mainOpThreatBlockedUntil > _now}) then {
        _effectiveThreatDelta = 0;
        _grantedSupplies = _grantedSupplies + _fallbackSupplies;
        _grantedIntel = _grantedIntel + _fallbackIntel;
        _fallbackUsed = true;
    };

    if (_blockTierProgressSeconds > 0 && {_tierBlockImmuneUntil > _now}) then {
        _blockTierProgressSeconds = 0;
        _blockMainOpThreatSeconds = 0;
        _grantedSupplies = _grantedSupplies + _fallbackSupplies;
        _grantedIntel = _grantedIntel + _fallbackIntel;
        _fallbackUsed = true;
        _note = if (_note isEqualTo "") then {"Tier block immunity active."} else {format ["%1 Tier block immunity active.", _note]};
    };

    if (_blockTierAlreadyActive) then {
        _blockTierProgressSeconds = 0;
        _blockMainOpThreatSeconds = 0;
        _grantedSupplies = _grantedSupplies + _fallbackSupplies;
        _grantedIntel = _grantedIntel + _fallbackIntel;
        _fallbackUsed = true;
        _note = if (_note isEqualTo "") then {"Tier block already active."} else {format ["%1 Tier block already active.", _note]};
    };

    if (_blockMainThreatAlreadyActive && {_blockTierProgressSeconds > 0}) then {
        _blockMainOpThreatSeconds = 0;
    };
};

if (!_loud && {_effectiveThreatDelta > 0}) then {
    _effectiveThreatDelta = 0;
};

if (_effectiveTierDelta > 0 && {(_tierProgressBlockedUntil > _now) || (missionNamespace getVariable ["MWF_TierFreeze_Active", false])}) then {
    _effectiveTierDelta = 0;
    _grantedSupplies = _grantedSupplies + _fallbackSupplies;
    _grantedIntel = _grantedIntel + _fallbackIntel;
    _fallbackUsed = true;
};

if (_effectiveTierDelta < 0 && {_halfMapLock}) then {
    if (_score <= _floorScore) then {
        _effectiveTierDelta = 0;
        _grantedSupplies = _grantedSupplies + _fallbackSupplies;
        _grantedIntel = _grantedIntel + _fallbackIntel;
        _fallbackUsed = true;
    } else {
        private _targetScore = (_score + _effectiveTierDelta) max _floorScore;
        _effectiveTierDelta = _targetScore - _score;
    };
};

if (_grantedSupplies > 0 || _grantedIntel > 0) then {
    [_currentSupplies + _grantedSupplies, _currentIntel + _grantedIntel, _notoriety] call MWF_fnc_syncEconomyState;
};

if (_effectiveTierDelta != 0) then {
    _score = (_score + _effectiveTierDelta) max _floorScore;
    _score = _score min 499;
    missionNamespace setVariable ["MWF_WorldTierScore", _score, true];
};

private _tier = ((_score / 100) call BIS_fnc_floor) + 1;
_tier = (_tier max (if (_halfMapLock) then {3} else {1})) min 5;
private _progress = if (_tier >= 5) then {100} else {_score mod 100};
missionNamespace setVariable ["MWF_WorldTier", _tier, true];
missionNamespace setVariable ["MWF_WorldTierProgress", _progress, true];

if (_effectiveThreatDelta != 0) then {
    _threatPercent = (_threatPercent + _effectiveThreatDelta) max 0;
    _threatPercent = _threatPercent min 100;
    missionNamespace setVariable ["MWF_GlobalThreatPercent", _threatPercent, true];

    if (_loud && {_zoneId != ""}) then {
        private _hotZones = + (missionNamespace getVariable ["MWF_ThreatHotZones", []]);
        private _expiry = _now + (missionNamespace getVariable ["MWF_ThreatHotspotDuration", 900]);
        private _existing = _hotZones findIf { toLower (_x param [0, "", [""]]) isEqualTo _zoneId };
        private _entry = [_zoneId, _expiry, (_effectiveThreatDelta max 1), _id];
        if (_existing >= 0) then {
            _hotZones set [_existing, _entry];
        } else {
            _hotZones pushBack _entry;
        };
        missionNamespace setVariable ["MWF_ThreatHotZones", _hotZones, true];
    };
};

if (_blockTierProgressSeconds > 0) then {
    private _until = _now + _blockTierProgressSeconds;
    missionNamespace setVariable ["MWF_WorldTierProgressBlockedUntil", _until, true];
    missionNamespace setVariable ["MWF_TierFreeze_Active", true, true];
    missionNamespace setVariable ["MWF_TierFreeze_EndTime", _until, true];
};

if (_blockMainOpThreatSeconds > 0) then {
    missionNamespace setVariable ["MWF_MainOpThreatProgressBlockedUntil", (_now + _blockMainOpThreatSeconds), true];
};

if (!isNil "MWF_fnc_markWorldDirty") then {
    [format ["impact_%1", _id]] call MWF_fnc_markWorldDirty;
};
if (!isNil "MWF_fnc_markThreatDirty") then {
    [format ["impact_%1", _id]] call MWF_fnc_markThreatDirty;
};
if (!isNil "MWF_fnc_registerThreatIncident" && {_effectiveThreatDelta > 0 && _loud}) then {
    [
        format ["%1_loud", _kind],
        _zoneId,
        ((_effectiveThreatDelta / 5) max 1) min 10,
        _id
    ] call MWF_fnc_registerThreatIncident;
};

_result set ["threatApplied", _effectiveThreatDelta];
_result set ["tierApplied", _effectiveTierDelta];
_result set ["fallbackUsed", _fallbackUsed];
_result set ["suppliesGranted", _grantedSupplies];
_result set ["intelGranted", _grantedIntel];
_result set ["note", _note];
_result
