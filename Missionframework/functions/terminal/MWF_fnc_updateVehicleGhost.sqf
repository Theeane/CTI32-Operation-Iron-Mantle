/*
    Author: OpenAI / ChatGPT
    Function: MWF_fnc_updateVehicleGhost
    Project: Military War Framework

    Description:
    Keeps the vehicle ghost aligned with the camera view and validates placement.
*/

if (!hasInterface) exitWith {};

while { missionNamespace getVariable ["MWF_VehiclePlacement_Active", false] && alive player } do {
    private _ghost = missionNamespace getVariable ["MWF_VehiclePlacement_Ghost", objNull];
    if (isNull _ghost) exitWith {};

    private _profile = missionNamespace getVariable ["MWF_VehiclePlacement_Profile", []];
    if (_profile isEqualTo [] || {(count _profile) < 6}) exitWith {};

    _profile params ["_vehicleType", "_surfaceRule", "_previewDistance", "_previewHeight"];

    private _rotation = missionNamespace getVariable ["MWF_VehiclePlacement_Rotation", getDir player];
    private _heightOffset = missionNamespace getVariable ["MWF_VehiclePlacement_HeightOffset", 0];

    private _targetATL = screenToWorld [0.5, 0.5];
    if ((_targetATL distance2D [0,0,0]) < 1) then {
        _targetATL = player modelToWorld [0, _previewDistance, 0];
    };

    private _posASL = AGLToASL _targetATL;

    if (_surfaceRule isEqualTo "WATER") then {
        _posASL set [2, (_previewHeight max 1) + _heightOffset];
        _ghost setVectorUp [0,0,1];
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
