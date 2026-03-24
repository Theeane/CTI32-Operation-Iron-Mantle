/*
    Author: Theane / ChatGPT
    Function: MWF_fn_startFOBPlacement
    Project: Military War Framework

    Description:
    Handles client-side FOB placement with ghost preview and confirmation.
    Preferred modern usage passes the deployable source object so the confirmed position
    can be routed into the server-side deploy pipeline. Legacy position-array usage is
    still accepted as a fallback for older call sites.
*/

params [
    ["_source", objNull, [objNull, []]]
];

if (!hasInterface) exitWith {};

private _legacyPos = if (_source isEqualType []) then { _source } else { [] };
private _sourceObject = if (_source isEqualType objNull) then { _source } else { objNull };

private _originPos = if (!isNull _sourceObject) then {
    getPosATL _sourceObject
} else {
    if (_legacyPos isEqualType [] && {count _legacyPos >= 2}) then { _legacyPos } else { player modelToWorld [0, 15, 0] }
};

private _originDir = if (!isNull _sourceObject) then { getDir _sourceObject } else { getDir player };

// Legacy composition offsets remain for the placement preview footprint.
private _compositionData = [
    ["Land_Cargo_HQ_V1_F", [0, 0, 0], 0],
    ["Land_HBarrier_5_F", [7, 7, 0], 45],
    ["Land_HBarrier_5_F", [-7, 7, 0], 315],
    ["Land_BagBunker_Small_F", [0, -10, 0], 180],
    ["Land_PortableLight_Single_F", [5, -5, 0], 0]
];

private _ghosts = [];
{
    _x params ["_type", "_offset", "_dirOffset"];
    private _ghost = _type createVehicleLocal [0, 0, 0];
    _ghost setAllowDamage false;
    _ghost enableSimulation false;
    _ghost setAlpha 0.5;
    _ghosts pushBack [_ghost, _offset, _dirOffset];
} forEach _compositionData;

private _confirmed = false;
private _abort = false;
private _currentDir = _originDir;
private _currentCenter = _originPos;
private _lastValidation = -10;
private _placementValid = false;

hint parseText "<t color='#00ff00'>FOB PLACEMENT MODE</t><br/>[LMB/Space]: Place<br/>[RMB/Esc]: Cancel<br/>[Q/E]: Rotate";

while {!_confirmed && !_abort && alive player} do {
    private _desiredCenter = player modelToWorld [0, 15, 0];
    _currentCenter = +_desiredCenter;

    if (inputAction "User1" > 0) then { _currentDir = _currentDir + 2; };
    if (inputAction "User2" > 0) then { _currentDir = _currentDir - 2; };

    {
        _x params ["_obj", "_offset", "_dirOffset"];
        private _rotatedOffset = [_offset, -_currentDir] call BIS_fnc_rotateVector2D;
        private _finalPos = _currentCenter vectorAdd _rotatedOffset;
        _obj setPosATL _finalPos;
        _obj setDir (_currentDir + _dirOffset);
    } forEach _ghosts;

    if ((diag_tickTime - _lastValidation) > 0.15) then {
        _placementValid = ["CAN_DEPLOY", [_currentCenter]] call MWF_fnc_baseManager;
        _lastValidation = diag_tickTime;
    };

    {
        (_x select 0) setAlpha (if (_placementValid) then {0.5} else {0.2});
    } forEach _ghosts;

    if (inputAction "DefaultAction" > 0) then {
        if (_placementValid) then {
            _confirmed = true;
        } else {
            hint "Invalid FOB location. Move farther from the MOB and other bases.";
        };
    };

    if (inputAction "ReloadMagazine" > 0 || {inputAction "MenuBack" > 0}) then {
        _abort = true;
    };

    uiSleep 0.01;
};

{ deleteVehicle (_x select 0); } forEach _ghosts;

if (_confirmed) then {
    if (!isNull _sourceObject) then {
        [_sourceObject, ATLToASL _currentCenter, _currentDir] remoteExec ["MWF_fnc_deployFOB", 2];
        hint "FOB deployment requested.";
        diag_log format ["[MWF FOB] FOB placement confirmed at %1 with direction %2.", _currentCenter, _currentDir];
    } else {
        [_currentCenter, _currentDir] remoteExec ["MWF_fnc_spawnFOBComposition", 2];
        missionNamespace setVariable ["MWF_system_active", true, true];
        hint "FOB Established!";
        diag_log format ["[MWF FOB] Legacy FOB placement confirmed at %1 with direction %2.", _currentCenter, _currentDir];
    };
} else {
    if (!isNull _sourceObject) then {
        _sourceObject setVariable ["MWF_FOB_PlacementInProgress", false, true];
    };
    hint "Placement Aborted.";
    diag_log "[MWF FOB] FOB placement aborted by player.";
};
