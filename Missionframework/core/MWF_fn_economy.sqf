/*
    Author: Theane / ChatGPT
    Function: MWF_fn_economy
    Project: Military War Framework

    Description:
    Handles resource income, notoriety decay, and shared economy helpers.
*/

if (!isServer) exitWith {};

if (missionNamespace getVariable ["MWF_EconomyLoopStarted", false]) exitWith {
    diag_log "[MWF Economy] Economy loop already running.";
};

missionNamespace setVariable ["MWF_EconomyLoopStarted", true, true];

if (isNil "MWF_Economy_Supplies") then {
    missionNamespace setVariable ["MWF_Economy_Supplies", 0, true];
};
if (isNil "MWF_res_intel") then {
    missionNamespace setVariable ["MWF_res_intel", 0, true];
};
if (isNil "MWF_res_notoriety") then {
    missionNamespace setVariable ["MWF_res_notoriety", 0, true];
};

missionNamespace setVariable ["MWF_Supplies", missionNamespace getVariable ["MWF_Economy_Supplies", 0], true];
missionNamespace setVariable ["MWF_Intel", missionNamespace getVariable ["MWF_res_intel", 0], true];

MWF_fnc_addResource = {
    params [
        ["_amount", 0, [0]],
        ["_type", "", [""]]
    ];

    private _normalizedType = toUpper _type;

    switch (_normalizedType) do {
        case "SUPPLIES": {
            private _value = missionNamespace getVariable ["MWF_Economy_Supplies", 0];
            _value = _value + _amount;
            missionNamespace setVariable ["MWF_Economy_Supplies", _value max 0, true];
            missionNamespace setVariable ["MWF_Supplies", _value max 0, true];
        };

        case "INTEL": {
            private _value = missionNamespace getVariable ["MWF_res_intel", 0];
            _value = _value + _amount;
            missionNamespace setVariable ["MWF_res_intel", _value max 0, true];
            missionNamespace setVariable ["MWF_Intel", _value max 0, true];
        };

        case "NOTORIETY": {
            private _value = missionNamespace getVariable ["MWF_res_notoriety", 0];
            _value = _value + _amount;
            missionNamespace setVariable ["MWF_res_notoriety", 0 max (100 min _value), true];
        };
    };

    remoteExec ["MWF_fnc_updateResourceUI", 0];

    if (!isNil "MWF_fnc_requestDelayedSave") then {
        [] call MWF_fnc_requestDelayedSave;
    };
};

while {true} do {
    private _sleepTime = (missionNamespace getVariable ["MWF_Economy_SupplyInterval", 10]) * 60;
    uiSleep _sleepTime;

    private _allZones = missionNamespace getVariable ["MWF_all_mission_zones", []];
    private _incomeSupplies = 0;
    private _activeZonesCount = 0;
    private _underAttackCount = 0;

    {
        private _zoneRef = _x;
        private _isMarkerZone = _zoneRef isEqualType "";
        private _isCaptured = false;
        private _isUnderAttack = false;

        if (_isMarkerZone) then {
            private _markerName = _zoneRef;
            _isCaptured = missionNamespace getVariable [format ["MWF_zoneState_%1_MWF_isCaptured", _markerName], false];
            _isUnderAttack = missionNamespace getVariable [format ["MWF_zoneState_%1_MWF_underAttack", _markerName], false];
        } else {
            if (!isNull _zoneRef) then {
                _isCaptured = _zoneRef getVariable ["MWF_isCaptured", false];
                _isUnderAttack = _zoneRef getVariable ["MWF_underAttack", false];
            };
        };

        if (_isCaptured) then {
            if (!_isUnderAttack) then {
                _incomeSupplies = _incomeSupplies + 5;
                _activeZonesCount = _activeZonesCount + 1;
            } else {
                _underAttackCount = _underAttackCount + 1;
            };
        };
    } forEach _allZones;

    if (_incomeSupplies > 0) then {
        [_incomeSupplies, "SUPPLIES"] call MWF_fnc_addResource;
        [format ["Income received: +%1 Supplies.", _incomeSupplies]] remoteExec ["systemChat", 0];
    };

    private _currentNotoriety = missionNamespace getVariable ["MWF_res_notoriety", 0];
    if (_currentNotoriety > 0) then {
        private _decay = missionNamespace getVariable ["MWF_Economy_HeatMult", 1];
        missionNamespace setVariable ["MWF_res_notoriety", 0 max (_currentNotoriety - _decay), true];
    };

    missionNamespace setVariable ["MWF_Supplies", missionNamespace getVariable ["MWF_Economy_Supplies", 0], true];
    missionNamespace setVariable ["MWF_Intel", missionNamespace getVariable ["MWF_res_intel", 0], true];

    remoteExec ["MWF_fnc_updateResourceUI", 0];

    diag_log format [
        "[MWF Economy] Safe Zones: %1 | Under Attack: %2 | Income: +%3",
        _activeZonesCount,
        _underAttackCount,
        _incomeSupplies
    ];
};
