/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_confirmVehiclePlacement
    Project: Military War Framework

    Description:
    Confirms preset-driven ghost placement.
    Client branch validates and forwards the build request to the server.
    Server branch performs final resource validation, spawns the real vehicle, syncs resources,
    and auto-initializes preset-defined Mobile Respawn Units.
*/

params [
    ["_className", "", [""]],
    ["_cost", -1, [0]],
    ["_minTier", 1, [0]],
    ["_posASL", [0, 0, 0], [[]]],
    ["_dir", 0, [0]],
    ["_surfaceRule", "LAND", [""]],
    ["_requiredUnlock", "", [""]],
    ["_isTier5", false, [false]]
];

if (hasInterface && {_className isEqualTo ""}) exitWith {
    if !(missionNamespace getVariable ["MWF_VehiclePlacement_Active", false]) exitWith { false };

    private _isValid = missionNamespace getVariable ["MWF_VehiclePlacement_IsValid", false];
    if (!_isValid) exitWith {
        systemChat (missionNamespace getVariable ["MWF_VehiclePlacement_LastReason", "Placement invalid."]);
        false
    };

    private _payload = [
        missionNamespace getVariable ["MWF_VehiclePlacement_Class", ""],
        missionNamespace getVariable ["MWF_VehiclePlacement_Cost", 0],
        missionNamespace getVariable ["MWF_VehiclePlacement_MinTier", 1],
        missionNamespace getVariable ["MWF_VehiclePlacement_LastPosASL", getPosASL player],
        missionNamespace getVariable ["MWF_VehiclePlacement_LastDir", getDir player],
        (missionNamespace getVariable ["MWF_VehiclePlacement_Profile", ["LAND", "LAND"]]) param [1, "LAND"],
        missionNamespace getVariable ["MWF_VehiclePlacement_RequiredUnlock", ""],
        missionNamespace getVariable ["MWF_VehiclePlacement_IsTier5", false]
    ];

    [] call MWF_fnc_cleanupVehiclePlacement;
    _payload remoteExecCall ["MWF_fnc_serverPurchasePlacedVehicle", 2];
    systemChat "Vehicle build request sent to server.";
    true
};

if (!isServer) exitWith { false };
if (_className isEqualTo "") exitWith { false };

[_className, _cost, _minTier, _posASL, _dir, _surfaceRule, _requiredUnlock, _isTier5] call MWF_fnc_serverPurchasePlacedVehicle
