/*
    Author: Theane / OpenAI
    Function: MWF_fnc_updateResourceUI
    Project: Military War Framework

    Description:
    Starts or refreshes the resource bar HUD singleton.
    HUD visibility is driven by proximity to the MOB or any FOB within 500 m,
    with fallbacks for replicated loadout triggers and marker anchors.
*/

if (!hasInterface) exitWith { false };
disableSerialization;

if (missionNamespace getVariable ["MWF_UI_UpdateLoopRunning", false]) exitWith {
    missionNamespace setVariable ["MWF_UI_RefreshRequested", true];
    true
};

missionNamespace setVariable ["MWF_UI_UpdateLoopRunning", true];
missionNamespace setVariable ["MWF_UI_RefreshRequested", true];

private _hudRadius = 500;
private _lastHudVisible = -1;

private _resolveObjectAnchor = {
    params ["_varName", ["_globalName", "", [""]]];

    private _obj = missionNamespace getVariable [_varName, objNull];
    if (!isNull _obj) exitWith { _obj };

    if !(_globalName isEqualTo "") then {
        if (!isNil _globalName) then {
            _obj = call compile _globalName;
        };
    };

    _obj
};

private _collectAnchorPositions = {
    private _positions = [];

    {
        private _obj = _x;
        if (!isNull _obj) then {
            _positions pushBackUnique (getPosATL _obj);
        };
    } forEach [
        ["MWF_MOB_AssetAnchor", "MWF_MOB_AssetAnchor"] call _resolveObjectAnchor,
        ["MWF_Intel_Center", "MWF_Intel_Center"] call _resolveObjectAnchor,
        ["MWF_MainBase", "MWF_MainBase"] call _resolveObjectAnchor,
        ["MWF_MOB_Table", "MWF_MOB_Table"] call _resolveObjectAnchor,
        missionNamespace getVariable ["MWF_MOB", objNull]
    ];

    if ((markerColor "MWF_MOB_Marker") isNotEqualTo "") then {
        _positions pushBackUnique (getMarkerPos "MWF_MOB_Marker");
    };

    if ((markerColor "respawn_west") isNotEqualTo "") then {
        _positions pushBackUnique (getMarkerPos "respawn_west");
    };

    {
        if (_x isEqualType [] && {count _x >= 2}) then {
            private _markerName = _x param [0, ""];
            private _terminal = _x param [1, objNull];

            if (!isNull _terminal) then {
                _positions pushBackUnique (getPosATL _terminal);
            } else {
                if (_markerName isEqualType "" && {markerShape _markerName isNotEqualTo ""}) then {
                    _positions pushBackUnique (getMarkerPos _markerName);
                };
            };
        };
    } forEach (missionNamespace getVariable ["MWF_FOB_Registry", []]);

    _positions
};

private _isPlayerNearHudAnchor = {
    if (isNull player) exitWith { false };
    if (uiNamespace getVariable ["MWF_IntroCinematicActive", false]) exitWith { false };

    private _loadoutZones = missionNamespace getVariable ["MWF_LoadoutZones", []];
    {
        if (!isNull _x && {player inArea _x}) exitWith { true };
    } forEach _loadoutZones;

    private _mobHudTrigger = missionNamespace getVariable ["MWF_MOB_HUDTrigger", objNull];
    if (!isNull _mobHudTrigger && {player inArea _mobHudTrigger}) exitWith { true };

    private _mobLoadoutTrigger = missionNamespace getVariable ["MWF_MOB_LoadoutTrigger", objNull];
    if (!isNull _mobLoadoutTrigger && {player inArea _mobLoadoutTrigger}) exitWith { true };

    {
        if (player distance2D _x <= _hudRadius) exitWith { true };
    } forEach (call _collectAnchorPositions);

    false
};

private _applyLayout = {
    params ["_display"];
    if (isNull _display) exitWith {};

    private _resourceGroup = _display displayCtrl 9000;
    private _notorietyGroup = _display displayCtrl 9200;
    private _eyeGroup = _display displayCtrl 9100;
    private _resourceBg = _display displayCtrl 9005;

    private _positionMode = missionNamespace getVariable ["MWF_UI_Position", 0];
    private _opacity = missionNamespace getVariable ["MWF_UI_Opacity", 0.5];

    private _rightX = safeZoneX + safeZoneW - 0.238;
    private _leftX = safeZoneX + 0.015;
    private _topY = safeZoneY + 0.035;
    private _resourceX = if (_positionMode isEqualTo 1) then { _leftX } else { _rightX };
    private _eyeX = if (_positionMode isEqualTo 1) then { _leftX + 0.172 } else { _rightX + 0.172 };

    _resourceGroup ctrlSetPosition [_resourceX, _topY, 0.23, 0.04];
    _resourceGroup ctrlCommit 0;

    _notorietyGroup ctrlSetPosition [_resourceX, _topY + 0.045, 0.23, 0.04];
    _notorietyGroup ctrlCommit 0;

    _eyeGroup ctrlSetPosition [_eyeX, _topY + 0.092, 0.06, 0.06];
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
        _lastHudVisible = -1;
    };

    if (!isNull _display) then {
        if (missionNamespace getVariable ["MWF_UI_RefreshRequested", false]) then {
            [_display] call _applyLayout;
            missionNamespace setVariable ["MWF_UI_RefreshRequested", false];
        };

        private _showHud = call _isPlayerNearHudAnchor;
        player setVariable ["MWF_isNearFOB", _showHud];

        private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
        private _intel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];
        private _heat = missionNamespace getVariable ["MWF_res_notoriety", missionNamespace getVariable ["MWF_ThreatLevel", 0]];

        (_display displayCtrl 9001) ctrlSetText format ["SUP: %1", _supplies];
        (_display displayCtrl 9002) ctrlSetText format ["INT: %1", _intel];
        (_display displayCtrl 9003) ctrlSetText format ["HEAT: %1%%", _heat];

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

        if (_showHud != _lastHudVisible) then {
            private _groupFade = if (_showHud) then { 0 } else { 1 };
            private _notorietyFade = if (_showHud) then { 0 } else { 1 };

            {
                if (!isNull _x) then {
                    _x ctrlSetFade _groupFade;
                    _x ctrlCommit 0.1;
                };
            } forEach [
                _display displayCtrl 9000,
                _display displayCtrl 9100
            ];

            private _notorietyGroup = _display displayCtrl 9200;
            if (!isNull _notorietyGroup) then {
                _notorietyGroup ctrlSetFade _notorietyFade;
                _notorietyGroup ctrlCommit 0.1;
            };

            _lastHudVisible = _showHud;
        };
    };

    uiSleep 0.2;
};

missionNamespace setVariable ["MWF_UI_UpdateLoopRunning", false];
false
