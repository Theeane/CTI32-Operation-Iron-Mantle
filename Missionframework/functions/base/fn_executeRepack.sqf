/* Author: Theane
    Project: Operation Iron Mantle
    Description: Internal helper to swap FOB object for a transport vehicle/box.
    Language: English
*/

if (!isServer) exitWith {};

params ["_target", "_className"];

private _pos = getPosATL _target;
private _dir = getDir _target;

// 1. Remove Marker & Registry Link
private _marker = _target getVariable ["KPIN_FOB_Marker", ""];
if (_marker != "") then {
    deleteMarker _marker;
    KPIN_ActiveZones = KPIN_ActiveZones select { (_x # 0) != _marker };
    publicVariable "KPIN_ActiveZones";
};

// 2. Swap Objects
deleteVehicle _target;
private _newObject = createVehicle [_className, _pos, [], 0, "NONE"];
_newObject setDir _dir;
_newObject setPosATL _pos;

// 3. Re-initialize deployment logic on the new object
[_newObject] call KPIN_fnc_initFOB;

["TaskSucceeded", ["", "FOB Repacked for transport."]] remoteExec ["BIS_fnc_showNotification", allPlayers];
