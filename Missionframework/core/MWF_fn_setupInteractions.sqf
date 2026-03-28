/*
    Author: Theane / ChatGPT
    Function: MWF_fn_setupInteractions
    Project: Military War Framework

    Description:
    Lightweight terminal setup for the server-spawned MOB/FOB asset pipeline.
    This version does not block in a retry loop. It resolves the current terminal
    from runtime references/anchors and lets the caller retry later if the asset
    has not replicated to the client yet.
*/

params [["_object", objNull, [objNull]]];

if (!hasInterface) exitWith { false };

private _terminalClasses = [];
{
    if (_x isEqualType "" && {_x isNotEqualTo ""} && {(_terminalClasses find _x) < 0}) then {
        _terminalClasses pushBack _x;
    };
} forEach [
    missionNamespace getVariable ["MWF_FOB_Asset_Terminal", "Land_Laptop_unfolded_F"],
    "Land_Laptop_unfolded_F",
    "RuggedTerminal_01_communications_F",
    "Land_DataTerminal_01_F"
];

private _isValidTerminal = {
    params ["_candidate", ["_classes", []]];
    if (isNull _candidate) exitWith { false };
    private _class = typeOf _candidate;
    (_class in _classes)
};

if (!isNull _object && {!([_object, _terminalClasses] call _isValidTerminal)}) then {
    _object = objNull;
};

if (isNull _object) then {
    _object = missionNamespace getVariable ["MWF_Intel_Center", objNull];
    if (isNull _object && {!isNil "MWF_Intel_Center"}) then {
        _object = MWF_Intel_Center;
    };
    if (!isNull _object && {!([_object, _terminalClasses] call _isValidTerminal)}) then {
        _object = objNull;
    };
};

private _findAtAnchor = {
    params ["_anchor", ["_radius", 12]];
    if (isNull _anchor) exitWith { objNull };
    private _candidates = nearestObjects [_anchor, _terminalClasses, _radius, true];
    if (_candidates isEqualTo []) exitWith { objNull };
    _candidates # 0
};

if (isNull _object) then {
    private _assetAnchor = missionNamespace getVariable ["MWF_MOB_AssetAnchor", objNull];
    if (isNull _assetAnchor && {!isNil "MWF_MOB_AssetAnchor"}) then {
        _assetAnchor = MWF_MOB_AssetAnchor;
    };
    _object = [_assetAnchor, 12] call _findAtAnchor;
};

if (isNull _object) then {
    private _respawnAnchor = missionNamespace getVariable ["MWF_MOB_RespawnAnchor", objNull];
    if (isNull _respawnAnchor && {!isNil "MWF_MOB_RespawnAnchor"}) then {
        _respawnAnchor = MWF_MOB_RespawnAnchor;
    };
    _object = [_respawnAnchor, 20] call _findAtAnchor;
};

if (isNull _object && {markerColor "MWF_MOB_Marker" isNotEqualTo ""}) then {
    private _candidates = nearestObjects [getMarkerPos "MWF_MOB_Marker", _terminalClasses, 20, true];
    if (_candidates isNotEqualTo []) then {
        _object = _candidates # 0;
    };
};

if (isNull _object && {markerColor "respawn_west" isNotEqualTo ""}) then {
    private _candidates = nearestObjects [getMarkerPos "respawn_west", _terminalClasses, 25, true];
    if (_candidates isNotEqualTo []) then {
        _object = _candidates # 0;
    };
};

if (isNull _object) exitWith {
    diag_log "[MWF Setup] Terminal setup deferred: no valid MOB terminal object resolved yet.";
    false
};

missionNamespace setVariable ["MWF_system_active", true, true];
player setVariable ["MWF_Player_Authenticated", true, true];
missionNamespace setVariable ["MWF_Intel_Center", _object, true];
MWF_Intel_Center = _object;

if (!isNil "MWF_fnc_terminal_main") then {
    ["INIT_SCROLL", _object] call MWF_fnc_terminal_main;
    ["INIT_ACE", _object] call MWF_fnc_terminal_main;
};

_object setVariable ["MWF_MOB_TerminalReady", true, true];
diag_log format ["[MWF Setup] MOB terminal initialized locally on %1.", _object];
true
