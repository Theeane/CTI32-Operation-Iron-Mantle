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

private _bootSupplies = missionNamespace getVariable ["MWF_Economy_Supplies", 0];
private _bootIntel = missionNamespace getVariable ["MWF_res_intel", 0];
private _bootNotoriety = missionNamespace getVariable ["MWF_res_notoriety", 0];

[_bootSupplies, _bootIntel, _bootNotoriety, true, false] call MWF_fnc_syncEconomyState;

while {true} do {
    private _sleepTime = (missionNamespace getVariable ["MWF_Economy_SupplyInterval", 10]) * 60;
    uiSleep _sleepTime;

    private _allZones = missionNamespace getVariable ["MWF_all_mission_zones", []];
    private _baseIncomeSupplies = 0;
    private _factoryBonusIncome = 0;
    private _activeZonesCount = 0;
    private _underAttackCount = 0;
    private _activeFactoryCount = 0;
    private _disabledFactoryCount = 0;

    {
        private _zoneRef = _x;
        private _isMarkerZone = _zoneRef isEqualType "";
        private _isCaptured = false;
        private _isUnderAttack = false;
        private _zoneType = "town";

        if (_isMarkerZone) then {
            private _markerName = _zoneRef;
            _isCaptured = missionNamespace getVariable [format ["MWF_zoneState_%1_MWF_isCaptured", _markerName], false];
            _isUnderAttack = missionNamespace getVariable [format ["MWF_zoneState_%1_MWF_underAttack", _markerName], false];
        } else {
            if (!isNull _zoneRef) then {
                _isCaptured = _zoneRef getVariable ["MWF_isCaptured", false];
                _isUnderAttack = _zoneRef getVariable ["MWF_underAttack", false];
                _zoneType = toLower (_zoneRef getVariable ["MWF_zoneType", "town"]);
            };
        };

        if (_isCaptured) then {
            if (!_isUnderAttack) then {
                _baseIncomeSupplies = _baseIncomeSupplies + 5;
                _activeZonesCount = _activeZonesCount + 1;

                if (_zoneType isEqualTo "factory") then {
                    _activeFactoryCount = _activeFactoryCount + 1;
                };
            } else {
                _underAttackCount = _underAttackCount + 1;

                if (_zoneType isEqualTo "factory") then {
                    _disabledFactoryCount = _disabledFactoryCount + 1;
                };
            };
        };
    } forEach _allZones;

    private _capturedFactoryCount = _activeFactoryCount + _disabledFactoryCount;
    private _storedProductionBonus = missionNamespace getVariable ["MWF_ProductionBonus", missionNamespace getVariable ["MWF_CapturedFactoryCount", _capturedFactoryCount]];

    if (_storedProductionBonus != _capturedFactoryCount) then {
        missionNamespace setVariable ["MWF_ProductionBonus", _capturedFactoryCount, true];
        _storedProductionBonus = _capturedFactoryCount;
    };

    private _onlineProductionBonus = 0 max (_storedProductionBonus - _disabledFactoryCount);
    _factoryBonusIncome = _onlineProductionBonus * 5;

    private _incomeSetting = missionNamespace getVariable ["MWF_Locked_IncomeMultiplier", missionNamespace getVariable ["MWF_Param_IncomeMultiplier", 1]];
    private _incomeMultiplier = switch (_incomeSetting) do {
        case 0: { 0.5 };
        case 2: { 2.0 };
        default { 1.0 };
    };

    private _grossIncomeSupplies = _baseIncomeSupplies + _factoryBonusIncome;
    private _incomeSupplies = round (_grossIncomeSupplies * _incomeMultiplier);

    if (_incomeSupplies > 0) then {
        [_incomeSupplies, "SUPPLIES"] call MWF_fnc_addResource;

        private _incomeMessage = if (_onlineProductionBonus > 0) then {
            format ["Income received: +%1 Supplies (%2 safe zones, %3 active factory production).", _incomeSupplies, _activeZonesCount, _onlineProductionBonus]
        } else {
            format ["Income received: +%1 Supplies.", _incomeSupplies]
        };

        [_incomeMessage] remoteExec ["systemChat", 0];
    };

    private _currentNotoriety = missionNamespace getVariable ["MWF_res_notoriety", 0];
    if (_currentNotoriety > 0) then {
        private _decay = missionNamespace getVariable ["MWF_Economy_HeatMult", 1];
        missionNamespace setVariable ["MWF_res_notoriety", 0 max (_currentNotoriety - _decay), true];
    };

    private _loopSupplies = missionNamespace getVariable ["MWF_Economy_Supplies", 0];
    private _loopIntel = missionNamespace getVariable ["MWF_res_intel", 0];
    private _loopNotoriety = missionNamespace getVariable ["MWF_res_notoriety", 0];
    [_loopSupplies, _loopIntel, _loopNotoriety, true, false] call MWF_fnc_syncEconomyState;

    diag_log format [
        "[MWF Economy] Safe Zones: %1 | Under Attack: %2 | Factory Production: %3 | Income: +%4",
        _activeZonesCount,
        _underAttackCount,
        _onlineProductionBonus,
        _incomeSupplies
    ];
};
