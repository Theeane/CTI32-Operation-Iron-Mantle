/*
    Builds infantry-only support and joins it to the player's group.
*/
params [["_groupIndex", 1, [0]],["_buyer", objNull, [objNull]]];
if (!isServer) exitWith { [_groupIndex, _buyer] remoteExecCall ["MWF_fnc_spawnSupportGroup", 2]; false };
if (isNull _buyer) exitWith { false };
private _varName = format ["MWF_Support_Group%1", _groupIndex];
private _template = missionNamespace getVariable [_varName, []];
if (_template isEqualTo []) exitWith { false };
_template params [["_vehicleClass","",[""]],["_unitClasses",[],[[]]],["_price",0,[0]],["_minTier",1,[0]]];
private _tier = missionNamespace getVariable ["MWF_WorldTier", 1];
if (_tier < _minTier) exitWith { [format ["Support unlocks at Tier %1.", _minTier]] remoteExecCall ["systemChat", owner _buyer]; false };
private _sup = missionNamespace getVariable ["MWF_Supplies", missionNamespace getVariable ["MWF_Economy_Supplies", 0]];
if (_sup < _price) exitWith { ["Not enough Supplies for this support group."] remoteExecCall ["systemChat", owner _buyer]; false };
missionNamespace setVariable ["MWF_Supplies", _sup - _price, true];
missionNamespace setVariable ["MWF_Economy_Supplies", _sup - _price, true];
private _ctx = [_buyer] call MWF_fnc_getSupportSpawnContext;
private _spawnPos = (_ctx get "position") findEmptyPosition [2, 30, typeOf _buyer];
if (_spawnPos isEqualTo []) then { _spawnPos = (_ctx get "position") vectorAdd [3,3,0]; };
private _grp = group _buyer;
{ _grp createUnit [_x, _spawnPos, [], 8, "FORM"]; } forEach _unitClasses;
[format ["Support group joined your squad near %1.", _ctx get "label"]] remoteExecCall ["systemChat", owner _buyer];
true
