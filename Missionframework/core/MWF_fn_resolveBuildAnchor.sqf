/*
    Resolves the active build anchor and player relocation point for Base Build.
    Returns [anchorPosATL, buildPosATL, sourceObject].
*/

params [["_terminal", objNull, [objNull]]];

private _sourceObj = objNull;
private _anchorPos = [];
private _buildPos = [];
private _fallbackPos = getPosATL player;

private _resolveFromObject = {
    params ["_obj"];
    if (isNull _obj) exitWith { [[], [], objNull] };

    private _objPos = getPosATL _obj;
    private _objDir = getDir _obj;
    private _candidate = [_objPos, 2.5, _objDir + 90] call BIS_fnc_relPos;
    private _safe = _candidate findEmptyPosition [1, 12, typeOf player];
    if !(_safe isEqualTo []) then {
        _candidate = _safe;
    };

    [_objPos, _candidate, _obj]
};

if (!isNull _terminal) then {
    if (_terminal getVariable ["MWF_isFOB", false]) then {
        private _fobAnchor = _terminal getVariable ["MWF_HUD_Anchor", _terminal];
        private _resolved = [_fobAnchor] call _resolveFromObject;
        _anchorPos = _resolved param [0, [], [[]]];
        _buildPos = _resolved param [1, [], [[]]];
        _sourceObj = _resolved param [2, objNull, [objNull]];
    } else {
        private _mobRespawnAnchor = missionNamespace getVariable ["MWF_MOB_RespawnAnchor", objNull];
        if (isNull _mobRespawnAnchor && {!isNil "MWF_MOB_RespawnAnchor"}) then {
            _mobRespawnAnchor = MWF_MOB_RespawnAnchor;
        };

        if (!isNull _mobRespawnAnchor) then {
            private _resolved = [_mobRespawnAnchor] call _resolveFromObject;
            _anchorPos = _resolved param [0, [], [[]]];
            _buildPos = _resolved param [1, [], [[]]];
            _sourceObj = _resolved param [2, objNull, [objNull]];
        };
    };
};

if (_anchorPos isEqualTo []) then {
    private _mainBase = missionNamespace getVariable ["MWF_MainBase", objNull];
    if (!isNull _mainBase) then {
        private _resolved = [_mainBase] call _resolveFromObject;
        _anchorPos = _resolved param [0, [], [[]]];
        _buildPos = _resolved param [1, [], [[]]];
        _sourceObj = _resolved param [2, objNull, [objNull]];
    };
};

if (_anchorPos isEqualTo [] && {markerColor "respawn_west" isNotEqualTo ""}) then {
    _anchorPos = getMarkerPos "respawn_west";
    _buildPos = [_anchorPos, 2.5, markerDir "respawn_west" + 90] call BIS_fnc_relPos;
};

if (_anchorPos isEqualTo [] || {_anchorPos isEqualTo [0, 0, 0]}) then {
    _anchorPos = +_fallbackPos;
};

if (_buildPos isEqualTo [] || {_buildPos isEqualTo [0, 0, 0]}) then {
    _buildPos = +_fallbackPos;
};

[_anchorPos, _buildPos, _sourceObj]
