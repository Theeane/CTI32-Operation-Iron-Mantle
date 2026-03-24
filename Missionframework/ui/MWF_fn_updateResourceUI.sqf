/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_updateResourceUI
    Project: Military War Framework

    Description:
    Starts or refreshes the resource bar HUD singleton.
*/

if (!hasInterface) exitWith { false };
disableSerialization;

if (missionNamespace getVariable ["MWF_UI_UpdateLoopRunning", false]) exitWith {
    missionNamespace setVariable ["MWF_UI_RefreshRequested", true];
    true
};

missionNamespace setVariable ["MWF_UI_UpdateLoopRunning", true];
missionNamespace setVariable ["MWF_UI_RefreshRequested", true];

private _applyLayout = {
    params ["_display"];
    if (isNull _display) exitWith {};

    private _resourceGroup = _display displayCtrl 9000;
    private _notorietyGroup = _display displayCtrl 9200;
    private _eyeGroup = _display displayCtrl 9100;
    private _resourceBg = _display displayCtrl 9005;

    private _positionMode = missionNamespace getVariable ["MWF_UI_Position", 0];
    private _opacity = missionNamespace getVariable ["MWF_UI_Opacity", 0.5];
    private _hidden = (_positionMode isEqualTo 2);

    private _resourceX = if (_positionMode isEqualTo 1) then { safeZoneX + 0.02 } else { safeZoneX + safeZoneW - 0.25 };
    private _notorietyX = _resourceX;
    private _eyeX = if (_positionMode isEqualTo 1) then { safeZoneX + 0.10 } else { safeZoneX + safeZoneW - 0.15 };

    {
        _x ctrlSetFade (if (_hidden) then { 1 } else { 0 });
        _x ctrlCommit 0;
    } forEach [_resourceGroup, _notorietyGroup, _eyeGroup];

    _resourceGroup ctrlSetPosition [_resourceX, safeZoneY + (safeZoneH * 0.45), 0.23, 0.04];
    _resourceGroup ctrlCommit 0;
    _notorietyGroup ctrlSetPosition [_notorietyX, safeZoneY + (safeZoneH * 0.45) + 0.045, 0.23, 0.04];
    _notorietyGroup ctrlCommit 0;
    _eyeGroup ctrlSetPosition [_eyeX, safeZoneY + (safeZoneH * 0.55), 0.06, 0.06];
    _eyeGroup ctrlCommit 0;

    if (!isNull _resourceBg) then {
        _resourceBg ctrlSetFade (1 - _opacity);
        _resourceBg ctrlCommit 0;
    };
};

while { hasInterface } do {
    private _display = uiNamespace getVariable ["MWF_ctrl_resBar", displayNull];
    if (isNull _display) then {
        "MWF_resLayer" cutRsc ["MWF_ResourceBar", "PLAIN"];
        uiSleep 0.05;
        _display = uiNamespace getVariable ["MWF_ctrl_resBar", displayNull];
        missionNamespace setVariable ["MWF_UI_RefreshRequested", true];
    };

    if (!isNull _display) then {
        if (missionNamespace getVariable ["MWF_UI_RefreshRequested", false]) then {
            [_display] call _applyLayout;
            missionNamespace setVariable ["MWF_UI_RefreshRequested", false];
        };

        private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
        private _intel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];
        private _heat = missionNamespace getVariable ["MWF_res_notoriety", 0];
        private _mainBase = missionNamespace getVariable ["MWF_MainBase", missionNamespace getVariable ["MWF_MOB", objNull]];
        private _isNearBase = (!isNull _mainBase && {player distance2D _mainBase <= 120});
        if (!_isNearBase) then {
            {
                private _terminal = _x param [1, objNull];
                if (!isNull _terminal && {player distance2D _terminal <= 120}) exitWith { _isNearBase = true; };
            } forEach (missionNamespace getVariable ["MWF_FOB_Registry", []]);
        };
        player setVariable ["MWF_isNearFOB", _isNearBase];

        (_display displayCtrl 9001) ctrlSetText format ["SUP: %1", _supplies];
        (_display displayCtrl 9002) ctrlSetText format ["INT: %1", _intel];
        (_display displayCtrl 9003) ctrlSetText format ["HEAT: %1%%", _heat];

        private _notorietyGroup = _display displayCtrl 9200;
        _notorietyGroup ctrlSetFade (if (_heat > 0 || _isNearBase) then {0} else {1});
        _notorietyGroup ctrlCommit 0.2;

        private _eyeCtrl = _display displayCtrl 9004;
        if (!isNull _eyeCtrl) then {
            private _eyeState = toUpper (player getVariable ["MWF_UndercoverEyeState", if (player getVariable ["MWF_isUndercover", false]) then {"GREEN"} else {"OFF"}]);
            private _eyePath = switch (_eyeState) do {
                case "GREEN": { "ui\eye_green.paa" };
                case "YELLOW": { "ui\eye_yellow.paa" };
                case "RED": { "ui\eye_red.paa" };
                default { "" };
            };
            private _eyeTip = switch (_eyeState) do {
                case "GREEN": { "Undercover secure" };
                case "YELLOW": { "Undercover compromised risk" };
                case "RED": { "Exposed / capture allowed" };
                default { "Open BLUFOR presence / capture allowed" };
            };
            _eyeCtrl ctrlSetText _eyePath;
            _eyeCtrl ctrlSetTooltip _eyeTip;
        };
    };

    uiSleep 0.2;
};

missionNamespace setVariable ["MWF_UI_UpdateLoopRunning", false];
false
