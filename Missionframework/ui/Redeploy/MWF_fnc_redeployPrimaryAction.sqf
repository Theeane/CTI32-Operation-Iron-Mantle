if (!hasInterface) exitWith { false };
private _selected = uiNamespace getVariable ["MWF_Redeploy_Selected", []];
if (_selected isEqualTo []) exitWith { systemChat "Select a FOB or MOB first."; false };
if (!alive player) exitWith { systemChat "Redeploy unavailable while incapacitated."; false };
if (vehicle player != player) exitWith { systemChat "Exit your vehicle before redeploying."; false };
_selected params ["_kind", "_label", "_targetPos"];
private _teleportPos = [_targetPos, 3, 12, 2, 0, 0.25, 0] call BIS_fnc_findSafePos;
if (_teleportPos isEqualTo [] || {_teleportPos isEqualTo [0,0,0]}) then { _teleportPos = _targetPos vectorAdd [3,0,0]; };
player setPosATL _teleportPos;
["CLOSE"] call MWF_fnc_dataHub;
[["REDEPLOY COMPLETE", format ["Redeployed to %1.", _label]], "success"] call MWF_fnc_showNotification;
true
