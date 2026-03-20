/*
    Spawns the full support package, including vehicle + crew if present.
*/
params [["_groupIndex", 1, [0]],["_buyer", objNull, [objNull]]];
if (!isServer) exitWith { [_groupIndex, _buyer] remoteExecCall ["MWF_fnc_spawnSupportUnit", 2]; false };
if (isNull _buyer) exitWith { false };
private _varName = format ["MWF_Support_Group%1", _groupIndex];
private _template = missionNamespace getVariable [_varName, []];
if (_template isEqualTo []) exitWith { false };
_template params [["_vehicleClass","",[""]],["_unitClasses",[],[[]]],["_price",0,[0]],["_minTier",1,[0]]];
private _tier = missionNamespace getVariable ["MWF_WorldTier", 1];
if (_tier < _minTier) exitWith { [format ["Support unlocks at Tier %1.", _minTier]] remoteExecCall ["systemChat", owner _buyer]; false };
private _sup = missionNamespace getVariable ["MWF_Supplies", missionNamespace getVariable ["MWF_Economy_Supplies", 0]];
if (_sup < _price) exitWith { ["Not enough Supplies for this support package."] remoteExecCall ["systemChat", owner _buyer]; false };
private _intel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];
private _notoriety = missionNamespace getVariable ["MWF_res_notoriety", 0];
[_sup - _price, _intel, _notoriety] call MWF_fnc_syncEconomyState;
private _ctx = [_buyer] call MWF_fnc_getSupportSpawnContext;
private _origin = +(_ctx get "position");
private _grp = createGroup [side group _buyer, true];
private _units = [];
private _veh = objNull;
if (_vehicleClass != "") then {
    private _vehPos = _origin findEmptyPosition [5, 40, _vehicleClass];
    if (_vehPos isEqualTo []) then { _vehPos = _origin vectorAdd [8,0,0]; };
    _veh = createVehicle [_vehicleClass, _vehPos, [], 0, "NONE"];
    _veh lock 0;
};
{ private _u = _grp createUnit [_x, _origin, [], 8, "FORM"]; _units pushBack _u; } forEach _unitClasses;
if (!isNull _veh && {_units isNotEqualTo []}) then {
    private _driver = _units deleteAt 0; _driver moveInDriver _veh;
    if (_units isNotEqualTo []) then { private _gunner = _units deleteAt 0; if ((_veh emptyPositions "gunner") > 0) then { _gunner moveInGunner _veh; } else { _gunner moveInCargo _veh; }; };
    if (_units isNotEqualTo []) then { private _cmd = _units deleteAt 0; if ((_veh emptyPositions "commander") > 0) then { _cmd moveInCommander _veh; } else { _cmd moveInCargo _veh; }; };
    { _x moveInCargo _veh; } forEach _units;
};
_grp setBehaviourStrong "AWARE";
{ doStop _x; } forEach units _grp;
[format ["Support package deployed near %1.", _ctx get "label"]] remoteExecCall ["systemChat", owner _buyer];
true
