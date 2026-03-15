/*
    File: MWF_fn_buildMode.sqf
    Author: Theane / ChatGPT
    Project: Military War Framework (MWF)

    Description:
    Handles local build placement preview and commits the purchase
    through the shared economy system.

    Notes:
    - Logic preserved 100%
    - Uses digital economy (MWF_Supplies / MWF_Intel)
*/

params [
    ["_className", "", [""]],
    ["_price", 0, [0]]
];

if (!hasInterface) exitWith {};
if (_className isEqualTo "") exitWith {};

private _currentSupplies =
    missionNamespace getVariable [
        "MWF_Economy_Supplies",
        missionNamespace getVariable ["MWF_Supplies", 0]
    ];

if (_currentSupplies < _price) exitWith {
    diag_log parseText "Not enough Supplies!";
};

private _ghost = _className createVehicleLocal [0,0,0];

_ghost setAllowDamage false;
_ghost enableSimulation false;
_ghost setVectorUp surfaceNormal getPosATL player;
_ghost setAlpha 0.6;

private _confirmed = false;
private _aborted = false;
private _rotation = getDir player;

diag_log "Use [LMB] to Place, [RMB] to Cancel, [Q/E] to Rotate.";

while { !_confirmed && !_aborted && alive player } do
{
    private _pos = player modelToWorld [0,5,0];

    _ghost setPosATL _pos;
    _ghost setDir _rotation;

    if (inputAction "TurnLeft" > 0) then {
        _rotation = _rotation - 2;
    };

    if (inputAction "TurnRight" > 0) then {
        _rotation = _rotation + 2;
    };

    if (inputAction "DefaultAction" > 0) then {
        _confirmed = true;
    };

    if (inputAction "ReloadMagazine" > 0) then {
        _aborted = true;
    };

    uiSleep 0.01;
};

private _finalPos = getPosATL _ghost;
private _finalDir = getDir _ghost;

deleteVehicle _ghost;

if (_confirmed) then
{
    [(_price * -1), "SUPPLIES"] call MWF_fnc_addResource;

    private _realObject =
        createVehicle [
            _className,
            _finalPos,
            [],
            0,
            "CAN_COLLIDE"
        ];

    _realObject setDir _finalDir;
    _realObject setPosATL _finalPos;

    if (_className == "B_Slingload_01_Cargo_F") then
    {
        [_realObject] remoteExec ["MWF_fnc_setupFOBAction", 0, true];
    };

    diag_log "Object Deployed.";
}
else
{
    diag_log "Construction Aborted.";
};
