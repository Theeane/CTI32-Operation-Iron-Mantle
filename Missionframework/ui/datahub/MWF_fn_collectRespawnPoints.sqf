/*
    Author: OpenAI / ChatGPT
    Function: MWF_fn_collectRespawnPoints
    Project: Military War Framework

    Description:
    Collects every known redeploy/respawn-capable node for the unified data map.
    Built to support later GUI integration.

    Return:
    [ [kind, label, positionATL, sourceObject], ... ]
*/

private _entries = [];
private _pushEntry = {
    params ["_kind", "_label", "_pos", ["_source", objNull, [objNull]]];

    if (_pos isEqualType objNull) then {
        _pos = getPosATL _pos;
    };

    if !(_pos isEqualType []) exitWith {};
    if ((count _pos) < 2) exitWith {};
    if ((_pos # 0) == 0 && {(_pos # 1) == 0}) exitWith {};

    private _duplicate = _entries findIf {
        private _existingPos = _x param [2, [0,0,0], [[]]];
        (_x param [1, "", [""]]) isEqualTo _label && {_existingPos distance2D _pos < 3}
    };

    if (_duplicate < 0) then {
        _entries pushBack [_kind, _label, _pos, _source];
    };
};

private _mainBase = missionNamespace getVariable ["MWF_MainBase", missionNamespace getVariable ["MWF_MOB", objNull]];
private _mobLabel = missionNamespace getVariable ["MWF_MOB_Name", "Main Operating Base"];
private _mobPos = if (!isNull _mainBase) then { getPosATL _mainBase } else { getMarkerPos "respawn_west" };
["MOB", _mobLabel, _mobPos, _mainBase] call _pushEntry;

{
    _x params ["", "_obj", ["_name", "FOB", [""]]];
    if (!isNull _obj) then {
        ["FOB", _name, getPosATL _obj, _obj] call _pushEntry;
    };
} forEach (missionNamespace getVariable ["MWF_FOB_Registry", []]);

{
    if (
        alive _x &&
        {_x getVariable ["MWF_isMobileRespawn", false]} &&
        {_x getVariable ["MWF_respawnAvailable", false]}
    ) then {
        private _label = _x getVariable ["MWF_MRU_DisplayName", _x getVariable ["MWF_respawnLabel", "Mobile Respawn Unit"]];
        ["MRU", _label, getPosATL _x, _x] call _pushEntry;
    };
} forEach vehicles;

private _tentClass = missionNamespace getVariable ["MWF_Tent_Object", ""];
{
    if (!isNull _x && {alive _x}) then {
        private _isTent = _x getVariable ["MWF_isRespawnTent", false];
        if (!_isTent && {_tentClass != ""}) then {
            _isTent = (typeOf _x) isEqualTo _tentClass;
        };

        if (_isTent && {_x getVariable ["MWF_respawnAvailable", true]}) then {
            private _label = _x getVariable ["MWF_respawnLabel", "Respawn Tent"];
            ["TENT", _label, getPosATL _x, _x] call _pushEntry;
        };
    };
} forEach (entities [["AllVehicles", "Thing"], [], true, false]);

_entries
