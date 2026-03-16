/*
    File: TutorialMission.sqf
    Purpose:
    Simple tutorial mission for early playthrough:
    1. Retrieve a van guarded by a small enemy team
    2. Return it to the FOB
    3. Use the FOB terminal
    4. Complete tutorial
*/

if (!isServer) exitWith {};

private _tutorialState = missionNamespace getVariable ["MWF_Tutorial_Running", false];
if (_tutorialState) exitWith {};
missionNamespace setVariable ["MWF_Tutorial_Running", true, true];

private _fob = missionNamespace getVariable ["MWF_MainBase", objNull];
private _fobPos = if (!isNull _fob) then { getPosATL _fob } else { getMarkerPos "respawn_west" };

if (_fobPos isEqualTo [0,0,0]) exitWith {
    missionNamespace setVariable ["MWF_Tutorial_Running", false, true];
};

private _taskRecover = "task_tutorial_recover_van";
private _taskTerminal = "task_tutorial_use_terminal";

private _spawnPos = [_fobPos, 1400, 1800, 10, 0, 0.3, 0] call BIS_fnc_findSafePos;
if (_spawnPos isEqualTo [0,0,0]) then {
    _spawnPos = _fobPos vectorAdd [1500, 0, 0];
};

private _road = objNull;
private _roads = _spawnPos nearRoads 150;
if ((count _roads) > 0) then {
    _road = _roads select 0;
    _spawnPos = getPosATL _road;
};

private _vehClass = "C_Van_02_transport_F";
private _van = createVehicle [_vehClass, _spawnPos, [], 0, "NONE"];
_van setDir random 360;
_van setFuel 0.35;
_van setDamage 0;
_van lock 0;
_van setVehicleVarName "MWF_Tutorial_Van";
missionNamespace setVariable ["MWF_Tutorial_Van", _van, true];

private _enemyGroup = createGroup [east, true];
private _enemyClasses = [
    "O_G_Soldier_F",
    "O_G_Soldier_AR_F",
    "O_G_medic_F"
];

{
    private _unitPos = _spawnPos getPos [8 + random 15, random 360];
    private _unit = _enemyGroup createUnit [_x, _unitPos, [], 0, "FORM"];
    _unit setSkill 0.35;
    _unit setCombatMode "RED";
    _unit setBehaviour "AWARE";
} forEach _enemyClasses;

_enemyGroup deleteGroupWhenEmpty true;

[
    west,
    _taskRecover,
    [
        "A civilian van has been located outside the area. Eliminate the hostile patrol, secure the van, and return it to the FOB.",
        "Recover Utility Van",
        ""
    ],
    _van,
    "CREATED",
    5,
    true,
    "car",
    true
] call BIS_fnc_taskCreate;

private _recoverMarker = createMarker [format ["MWF_tutorial_van_%1", diag_tickTime], _spawnPos];
_recoverMarker setMarkerShape "ICON";
_recoverMarker setMarkerType "mil_objective";
_recoverMarker setMarkerText "Tutorial Van";
_recoverMarker setMarkerColor "ColorWEST";

waitUntil {
    sleep 2;
    isNull _van || {!alive _van} || {(_van distance2D _fobPos) < 35}
};

if (isNull _van || {!alive _van}) exitWith {
    [_taskRecover, "FAILED", true] call BIS_fnc_taskSetState;
    deleteMarker _recoverMarker;
    missionNamespace setVariable ["MWF_Tutorial_Running", false, true];
};

[_taskRecover, "SUCCEEDED", true] call BIS_fnc_taskSetState;
deleteMarker _recoverMarker;

[
    west,
    _taskTerminal,
    [
        "The van is back at the FOB. Move to the FOB terminal and use it to finalize setup.",
        "Use FOB Terminal",
        ""
    ],
    objNull,
    "CREATED",
    4,
    true,
    "interact",
    true
] call BIS_fnc_taskCreate;

private _terminal = missionNamespace getVariable ["MWF_FOB_Terminal", objNull];

if (isNull _terminal) then {
    private _nearObjects = nearestObjects [_fobPos, ["Land_Laptop_device_F","Land_DataTerminal_01_F","Land_Laptop_unfolded_F"], 30];
    if ((count _nearObjects) > 0) then {
        _terminal = _nearObjects select 0;
    };
};

if (isNull _terminal) exitWith {
    [_taskTerminal, "FAILED", true] call BIS_fnc_taskSetState;
    missionNamespace setVariable ["MWF_Tutorial_Running", false, true];
};

missionNamespace setVariable ["MWF_Tutorial_TerminalUsed", false, true];

[
    _terminal,
    "<t color='#00FF00'>Finalize FOB Setup</t>",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_connect_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_connect_ca.paa",
    "_this distance _target < 3",
    "_caller distance _target < 3",
    {},
    {},
    {
        missionNamespace setVariable ["MWF_Tutorial_TerminalUsed", true, true];
        systemChat "FOB setup finalized.";
    },
    {},
    [],
    3,
    0,
    true,
    false
] remoteExec ["BIS_fnc_holdActionAdd", 0, true];

waitUntil {
    sleep 1;
    missionNamespace getVariable ["MWF_Tutorial_TerminalUsed", false]
};

[_taskTerminal, "SUCCEEDED", true] call BIS_fnc_taskSetState;

[
    west,
    "task_tutorial_complete",
    [
        "Tutorial complete. You have recovered a vehicle, returned it to base, and used the FOB terminal.",
        "Tutorial Complete",
        ""
    ],
    objNull,
    "SUCCEEDED",
    3,
    true,
    "run",
    true
] call BIS_fnc_taskCreate;

missionNamespace setVariable ["MWF_Tutorial_Completed", true, true];
missionNamespace setVariable ["MWF_current_stage", 2, true];
missionNamespace setVariable ["MWF_Tutorial_Running", false, true];
