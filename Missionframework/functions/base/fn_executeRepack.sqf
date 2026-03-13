/* Author: Theane / Gemini
    Project: Operation Iron Mantle
    Function: KPIN_fnc_executeRepack
    Description: Deletes all linked FOB assets and spawns back the transport vehicle/box.
    Language: English
*/

if (!isServer) exitWith {};

params [
    ["_target", objNull, [objNull]], // This is the Laptop/Command PC
    ["_className", "", [""]]        // The vehicle or box class to return to
];

if (isNull _target || _className == "") exitWith { diag_log "[KPIN ERROR]: Invalid repack parameters."; };

private _pos = getPosATL _target;
private _dir = getDir _target;
private _marker = _target getVariable ["KPIN_FOB_Marker", ""];

// 1. COLLECT LINKED ASSETS (From variables we set in initFOB)
private _locker = _target getVariable ["KPIN_AttachedLocker", objNull];
private _siren  = _target getVariable ["KPIN_AttachedSiren", objNull];
private _table  = attachedTo _target; // The laptop is attached to the table

// 2. REGISTRY CLEANUP
if (_marker != "") then {
    ["REMOVE", _marker] call KPIN_fnc_baseManager;
    deleteMarker _marker;
};

// 3. THE CLEAN SWEEP
// Delete the technical assets
{
    if (!isNull _x) then { deleteVehicle _x };
} forEach [_target, _locker, _siren, _table];

// Delete the optional roof (Camo net) if it exists nearby
private _roofClass = missionNamespace getVariable ["KPIN_FOB_Asset_Roof", ""];
if (_roofClass != "") then {
    private _roofs = nearestObjects [_pos, [_roofClass], 15];
    { deleteVehicle _x } forEach _roofs;
};

// 4. SPAWN TRANSPORT BACK
private _newObject = createVehicle [_className, _pos, [], 0, "NONE"];
_newObject setDir _dir;
_newObject setPosATL _pos;

// Re-add the deployment holdAction
[_newObject] call KPIN_fnc_initFOB;

// 5. NOTIFICATION
["TaskSucceeded", ["", "FOB Repacked for transport."]] remoteExec ["BIS_fnc_showNotification", 0];

diag_log format ["[KPIN] Logistics: FOB kit cleaned and repacked into %1.", _className];
