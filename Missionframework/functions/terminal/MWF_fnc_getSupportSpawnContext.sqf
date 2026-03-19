/*
    Support spawn context resolver.
*/
params [["_buyer", player, [objNull]]];
if (isNull _buyer) exitWith { createHashMapFromArray [["label","Player"],["position", getPosATL player],["mode","PLAYER"]] };

private _mainOpPlacement = missionNamespace getVariable ["MWF_CurrentGrandOperationPlacement", []];
if ((missionNamespace getVariable ["MWF_GrandOperationActive", false]) && {!(_mainOpPlacement isEqualTo [])}) exitWith {
    private _pos = _mainOpPlacement param [1, getPosATL _buyer, [[]]];
    createHashMapFromArray [["label","Main Operation"],["position",_pos],["mode","MAIN_OPERATION"]]
};

private _activeSideMissions = (missionNamespace getVariable ["MWF_MissionBoardSlots", []]) select {
    toLower (_x param [8, "available", [""]]) isEqualTo "active"
};
if (_activeSideMissions isNotEqualTo []) exitWith {
    private _picked = selectRandom _activeSideMissions;
    createHashMapFromArray [["label", _picked param [7, "Mission", [""]]],["position", _picked param [6, getPosATL _buyer, [[]]]],["mode","SIDE_MISSION"]]
};

private _mobPos = if !((getMarkerPos "respawn_west") isEqualTo [0,0,0]) then { getMarkerPos "respawn_west" } else { getPosATL _buyer };
private _zones = (missionNamespace getVariable ["MWF_all_mission_zones", []]) select { !isNull _x };
private _enemyZones = _zones select {
    private _owner = toLower (_x getVariable ["MWF_zoneOwnerState", if (_x getVariable ["MWF_isCaptured", false]) then {"player"} else {"enemy"}]);
    !(_owner isEqualTo "player")
};
private _anchor = if ((_buyer distance2D _mobPos) <= 250) then { _mobPos } else { getPosATL _buyer };
private _nearest = objNull;
private _best = 1e10;
{
    private _dist = _anchor distance2D _x;
    if (_dist < _best) then { _best = _dist; _nearest = _x; };
} forEach _enemyZones;
if (!isNull _nearest) exitWith {
    createHashMapFromArray [["label", _nearest getVariable ["MWF_zoneName","Zone"]],["position", getPosATL _nearest],["mode","ZONE"]]
};
createHashMapFromArray [["label","Standby"],["position", getPosATL _buyer],["mode","PLAYER"]]
