/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_updateVehicleGhost
    Project: Military War Framework

    Description:
    Client-side loop that keeps the vehicle ghost aligned with the player's camera and
    continuously validates placement.
*/

if (!hasInterface) exitWith {};

private _resolvePreviewPosASL = {
    params [["_previewDistance", 5, [0]]];

    private _camStartASL = AGLToASL (positionCameraToWorld [0, 0, 0]);
    private _camEndASL = AGLToASL (positionCameraToWorld [0, 0, 1000]);
    private _hits = lineIntersectsSurfaces [_camStartASL, _camEndASL, player, objNull, true, 1, "GEOM", "VIEW"];

    if (_hits isNotEqualTo []) exitWith { (_hits select 0) select 0 };

    AGLToASL (positionCameraToWorld [0, _previewDistance, 0])
};

while { missionNamespace getVariable ["MWF_VehiclePlacement_Active", false] && alive player } do {
    private _ghost = missionNamespace getVariable ["MWF_VehiclePlacement_Ghost", objNull];
    if (isNull _ghost) exitWith {};

    private _profile = missionNamespace getVariable ["MWF_VehiclePlacement_Profile", []];
    if (_profile isEqualTo [] || {(count _profile) < 7}) exitWith {};

    _profile params ["_vehicleType", "_surfaceRule", "_previewDistance", "_previewHeight"];

    private _rotation = missionNamespace getVariable ["MWF_VehiclePlacement_Rotation", getDir player];
    private _heightOffset = missionNamespace getVariable ["MWF_VehiclePlacement_HeightOffset", 0];
    private _posASL = [_previewDistance] call _resolvePreviewPosASL;

    if (_surfaceRule isEqualTo "WATER") then {
        _posASL set [2, ((_posASL select 2) max 0.5) + _heightOffset];
        _ghost setVectorUp [0, 0, 1];
        _ghost setPosASL _posASL;
    } else {
        private _posATL = ASLToATL _posASL;
        _posATL set [2, (_previewHeight max 0.05) + _heightOffset];
        _ghost setVectorUp surfaceNormal _posATL;
        _ghost setPosATL _posATL;
        _posASL = AGLToASL _posATL;
    };

    _ghost setDir _rotation;

    private _result = [
        missionNamespace getVariable ["MWF_VehiclePlacement_Class", ""],
        _posASL,
        _rotation,
        _profile
    ] call MWF_fnc_validateVehiclePlacement;

    private _isValid = _result param [0, false];
    private _reason = _result param [1, "Placement invalid."];

    private _basePos = missionNamespace getVariable ["MWF_VehiclePlacement_BasePos", []];
    private _baseRadius = missionNamespace getVariable ["MWF_VehiclePlacement_BaseRadius", 500];
    if ((_basePos isEqualType []) && {(count _basePos) >= 2}) then {
        private _previewATL = ASLToATL _posASL;
        if ((_previewATL distance2D _basePos) > _baseRadius) then {
            _isValid = false;
            _reason = "Placement outside base radius.";
        };
    };

    missionNamespace setVariable ["MWF_VehiclePlacement_IsValid", _isValid];
    missionNamespace setVariable ["MWF_VehiclePlacement_LastReason", _reason];
    missionNamespace setVariable ["MWF_VehiclePlacement_LastPosASL", _posASL];
    missionNamespace setVariable ["MWF_VehiclePlacement_LastDir", _rotation];

    _ghost setAlpha (if (_isValid) then {0.25} else {0.65});
    uiSleep 0.02;
};

if (!alive player) then {
    [] call MWF_fnc_cleanupVehiclePlacement;
};
