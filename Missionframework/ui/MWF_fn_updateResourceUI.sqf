/*
    Author: Theane / OpenAI
    Function: MWF_fnc_updateResourceUI
    Project: Military War Framework

    Description:
    Starts or refreshes the resource bar HUD singleton.
    HUD visibility is driven by distance to registered base anchors (MOB/FOB)
    within 500 m. If the anchor registry has not propagated yet, the MOB anchor
    and FOB terminals are used as fallbacks so the HUD fails open near base.
*/

if (!hasInterface) exitWith { false };
disableSerialization;

if (missionNamespace getVariable ["MWF_UI_UpdateLoopRunning", false]) exitWith {
    missionNamespace setVariable ["MWF_UI_RefreshRequested", true];
    true
};

missionNamespace setVariable ["MWF_UI_UpdateLoopRunning", true];
missionNamespace setVariable ["MWF_UI_RefreshRequested", true];

private _defaultHudRadius = 500;
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

private _formatNumber = {
    params [["_value", 0, [0]]];
    [(_value max 0)] call BIS_fnc_numberText
};

private _toRoman = {
    params [["_value", 1, [0]]];
    switch (_value max 1 min 5) do {
        case 1: { "I" };
        case 2: { "II" };
        case 3: { "III" };
        case 4: { "IV" };
        case 5: { "V" };
        default { str _value };
    }
};

private _collectAnchors = {
    private _anchors = [];

    {
        if (_x isEqualType [] && {count _x >= 1}) then {
            private _anchor = _x param [0, objNull];
            private _radius = _x param [2, _defaultHudRadius];
            if (!isNull _anchor) then {
                _anchors pushBackUnique [_anchor, _radius max 25];
            };
        };
    } forEach (missionNamespace getVariable ["MWF_HUD_AnchorRegistry", []]);

    if (_anchors isEqualTo []) then {
        {
            private _obj = _x;
            if (!isNull _obj) then {
                _anchors pushBackUnique [_obj, _defaultHudRadius];
            };
        } forEach [
            ["MWF_MOB_AssetAnchor", "MWF_MOB_AssetAnchor"] call _resolveObjectAnchor,
            ["MWF_MainBase", "MWF_MainBase"] call _resolveObjectAnchor,
            ["MWF_Intel_Center", "MWF_Intel_Center"] call _resolveObjectAnchor,
            ["MWF_MOB_Table", "MWF_MOB_Table"] call _resolveObjectAnchor,
            missionNamespace getVariable ["MWF_MOB", objNull]
        ];

        {
            if (_x isEqualType [] && {count _x >= 2}) then {
                private _terminal = _x param [1, objNull];
                if (!isNull _terminal) then {
                    private _anchor = _terminal getVariable ["MWF_HUD_Anchor", objNull];
                    if (isNull _anchor) then { _anchor = _terminal; };
                    if (!isNull _anchor) then {
                        _anchors pushBackUnique [_anchor, _defaultHudRadius];
                    };
                };
            };
        } forEach (missionNamespace getVariable ["MWF_FOB_Registry", []]);
    };

    _anchors
};

private _isPlayerNearHudAnchor = {
    if (isNull player) exitWith { false };
    if (uiNamespace getVariable ["MWF_IntroCinematicActive", false]) exitWith { false };
    if ((missionNamespace getVariable ["MWF_UI_Position", 0]) isEqualTo 2) exitWith { false };

    private _anchors = call _collectAnchors;
    {
        private _anchor = _x param [0, objNull];
        private _radius = _x param [1, _defaultHudRadius];
        if (!isNull _anchor && {player distance2D _anchor <= _radius}) exitWith { true };
    } forEach _anchors;

    false
};

private _applyLayout = {
    params ["_display"];
    if (isNull _display) exitWith {};

    private _resourceGroup = _display displayCtrl 9000;
    private _resourceBg = _display displayCtrl 9005;

    private _positionMode = missionNamespace getVariable ["MWF_UI_Position", 0];
    private _opacity = missionNamespace getVariable ["MWF_UI_Opacity", 0.35];

    private _groupW = 0.152;
    private _groupH = 0.272;
    private _rightX = safeZoneX + safeZoneW - _groupW - 0.012;
    private _leftX = safeZoneX + 0.018;
    private _baseX = if (_positionMode isEqualTo 1) then { _leftX } else { _rightX };
    private _baseY = safeZoneY + (safeZoneH * 0.355);

    if (!isNull _resourceGroup) then {
        _resourceGroup ctrlSetPosition [_baseX, _baseY, _groupW, _groupH];
        _resourceGroup ctrlCommit 0;
    };

    if (!isNull _resourceBg) then {
        _resourceBg ctrlSetFade (1 - _opacity);
        _resourceBg ctrlCommit 0;
    };
};

while { hasInterface } do {
    private _display = uiNamespace getVariable ["MWF_ctrl_resBar", displayNull];
    if (isNull _display) then {
        "MWF_resLayer" cutRsc ["MWF_ResourceBar", "PLAIN"];
        uiSleep 0.1;
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
        private _worldTier = missionNamespace getVariable ["MWF_WorldTier", 1];

        private _resourceText = _display displayCtrl 9001;
        if (!isNull _resourceText) then {
            _resourceText ctrlSetStructuredText parseText format [
                "<t size='0.88' color='#FFFFFF'>Supplies:</t><br/><t size='0.98' color='#FFFFFF'>%1</t><br/><t size='0.88' color='#78D7FF'>Intel:</t><br/><t size='0.98' color='#78D7FF'>%2</t><br/><t size='0.88' color='#F4E29D'>World Tier:</t><br/><t size='0.98' color='#F4E29D'>%3</t><br/><t size='0.88' color='#FF5E73'>Threat:</t><br/><t size='0.98' color='#FF5E73'>%4%%</t>",
                [_supplies] call _formatNumber,
                [_intel] call _formatNumber,
                [_worldTier] call _toRoman,
                _heat
            ];
        };

        if (_showHud != _lastHudVisible) then {
            private _fade = if (_showHud) then { 0 } else { 1 };
            {
                if (!isNull _x) then {
                    _x ctrlSetFade _fade;
                    _x ctrlCommit 0.1;
                };
            } forEach [
                _display displayCtrl 9000,
                _display displayCtrl 9005,
                _display displayCtrl 9001
            ];
            _lastHudVisible = _showHud;
        };
    };

    uiSleep 0.2;
};

missionNamespace setVariable ["MWF_UI_UpdateLoopRunning", false];
false
