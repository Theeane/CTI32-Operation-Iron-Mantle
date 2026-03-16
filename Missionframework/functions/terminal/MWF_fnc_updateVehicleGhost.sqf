/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_updateVehicleGhost
    Project: Military War Framework

    Description:
    Client-side loop that keeps the vehicle ghost aligned with player movement and rotation,
    and continuously validates placement.
*/

if (!hasInterface) exitWith {};

while { missionNamespace getVariable ["MWF_VehiclePlacement_Active", false] && alive player } do {
    private _ghost = missionNamespace getVariable ["MWF_VehiclePlacement_Ghost", objNull];
    if (isNull _ghost) exitWith {};

    private _profile = missionNamespace getVariable ["MWF_VehiclePlacement_Profile", []];
    if (_profile isEqualTo [] || {(count _profile) < 7}) exitWith {};

    _profile params ["_vehicleType", "_surfaceRule", "_previewDistance", "_previewHeight"];

    private _rotation = missionNamespace getVariable ["MWF_VehiclePlacement_Rotation", getDir player];
    if (inputAction "TurnLeft" > 0) then { _rotation = _rotation - 1.5; };
    if (inputAction "TurnRight" > 0) then { _rotation = _rotation + 1.5; };
    missionNamespace setVariable ["MWF_VehiclePlacement_Rotation", _rotation];

    private _posASL = AGLToASL (player modelToWorld [0, _previewDistance, 0]);

    if (_surfaceRule isEqualTo "WATER") then {
        _posASL set [2, _previewHeight max 1];
        _ghost setVectorUp [0, 0, 1];
        _ghost setPosASL _posASL;
    } else {
        private _posATL = ASLToATL _posASL;
        _posATL set [2, _previewHeight max 0.05];
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

    missionNamespace setVariable ["MWF_VehiclePlacement_IsValid", _isValid];
    missionNamespace setVariable ["MWF_VehiclePlacement_LastReason", _reason];
    missionNamespace setVariable ["MWF_VehiclePlacement_LastPosASL", _posASL];
    missionNamespace setVariable ["MWF_VehiclePlacement_LastDir", _rotation];

    _ghost setAlpha ([0.65, 0.25] select (!_isValid));

    uiSleep 0.02;
};

if (!alive player) then {
    [] call MWF_fnc_cleanupVehiclePlacement;
};
