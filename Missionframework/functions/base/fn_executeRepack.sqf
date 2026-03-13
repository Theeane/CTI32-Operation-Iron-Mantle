/* Author: Theane / Gemini
    Project: Operation Iron Mantle
    Function: KPIN_fnc_executeRepack
    Description: Swaps a deployed FOB object back into a transport vehicle or box.
    Language: English
*/

if (!isServer) exitWith {};

params [
    ["_target", objNull, [objNull]],
    ["_className", "", [""]]
];

if (isNull _target || _className == "") exitWith { diag_log "[KPIN ERROR]: Invalid repack parameters."; };

private _pos = getPosATL _target;
private _dir = getDir _target;
private _marker = _target getVariable ["KPIN_FOB_Marker", ""];

// 1. Remove from Logistical Registry and Persistence
// This handles marker deletion and KPIN_ActiveZones cleanup via the manager
if (_marker != "") then {
    ["REMOVE", _marker] call KPIN_fnc_baseManager;
};

// 2. Swap Objects
deleteVehicle _target;
private _newObject = createVehicle [_className, _pos, [], 0, "NONE"];
_newObject setDir _dir;
_newObject setPosATL _pos;

// 3. Re-initialize deployment logic on the new object (Truck/Box)
// This ensures the player can deploy it again later
[_newObject] call KPIN_fnc_initFOB;

// 4. Global Notification
["TaskSucceeded", ["", "FOB Repacked for transport."]] remoteExec ["BIS_fnc_showNotification", 0];

diag_log format ["[KPIN] Logistics: FOB repacked into %1 at %2.", _className, mapGridPosition _newObject];
