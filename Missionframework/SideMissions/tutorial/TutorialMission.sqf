/*
    File: TutorialMission.sqf
    Updated for new system (preset + reward + phase driven)
    Tutorial now reflects active undercover rules:
    - OPFOR uniform counts as valid disguise.
    - Civilian uniform counts only if the player has no vest and no weapons.
    - Backpack, headgear, facewear, NVG, binocular, GPS, map, compass and watch are ignored.
*/

if (!isServer) exitWith {};

if (missionNamespace getVariable ["MWF_Tutorial_Running", false]) exitWith {};
missionNamespace setVariable ["MWF_Tutorial_Running", true, true];

private _fnc_isUnitUndercoverForTutorial = {
    params [["_unit", objNull, [objNull]]];
    if (isNull _unit) exitWith {false};

    private _opforUniforms = missionNamespace getVariable ["MWF_OpforUniformClasses", []];
    private _civilianUniforms = missionNamespace getVariable ["MWF_CivilianUniformClasses", []];
    private _uniform = uniform _unit;

    if (_uniform in _opforUniforms) exitWith {true};

    private _hasVest = (vest _unit) != "";
    private _hasWeapon =
        (primaryWeapon _unit) != "" ||
        {(handgunWeapon _unit) != ""} ||
        {(secondaryWeapon _unit) != ""};

    if ((_uniform in _civilianUniforms) && {!_hasVest} && {!_hasWeapon}) exitWith {true};
    false
};

// === BASE ===
private _registry = missionNamespace getVariable ["MWF_FOB_Registry", []];
private _liveFobEntry = _registry select {
    !isNull (_x param [1, objNull])
};
private _fob = if (_liveFobEntry isEqualTo []) then {
    missionNamespace getVariable ["MWF_MainBase", objNull]
} else {
    (_liveFobEntry select 0) param [1, objNull]
};
private _fobPos = if (!isNull _fob) then { getPosATL _fob } else { getMarkerPos "respawn_west" };

if (_fobPos isEqualTo [0,0,0]) exitWith {
    missionNamespace setVariable ["MWF_Tutorial_Running", false, true];
};

// === SPAWN POSITION ===
private _spawnPos = [_fobPos, 1400, 1800, 10, 0, 0.3, 0] call BIS_fnc_findSafePos;
if (_spawnPos isEqualTo [0,0,0]) then {
    _spawnPos = _fobPos vectorAdd [1500, 0, 0];
};

// Snap to road if possible
private _roads = _spawnPos nearRoads 150;
if ((count _roads) > 0) then {
    _spawnPos = getPosATL (_roads select 0);
};

// === VEHICLE FROM CIV PRESET ===
private _civVehicles = missionNamespace getVariable ["MWF_Civ_Vehicles", []];
if ((count _civVehicles) == 0) exitWith {
    missionNamespace setVariable ["MWF_Tutorial_Running", false, true];
};

private _vehClass = selectRandom _civVehicles;
private _van = createVehicle [_vehClass, _spawnPos, [], 0, "NONE"];
_van setDir random 360;
_van setFuel 0.35;
_van setDamage 0;
_van lock 0;
missionNamespace setVariable ["MWF_Tutorial_Van", _van, true];

// === OPFOR FROM PRESET ===
private _enemyGroup = createGroup [east, true];
private _opforUnits = missionNamespace getVariable ["MWF_Opfor_Infantry", []];
private _spawnCount = 3 max 2;

for "_i" from 1 to _spawnCount do {
    private _class = selectRandom _opforUnits;
    private _pos = _spawnPos getPos [8 + random 15, random 360];
    private _unit = _enemyGroup createUnit [_class, _pos, [], 0, "FORM"];
    _unit setSkill 0.3;
    _unit setBehaviour "AWARE";
};

_enemyGroup deleteGroupWhenEmpty true;

// === TASK: RECOVER ===
private _taskRecover = "task_tutorial_recover_van";
[
    west,
    _taskRecover,
    [
        "Recover the vehicle and return it to the FOB. Civilian clothing can keep you hidden only if you stay unarmed and wear no vest. Completing the run undercover grants bonus Intel.",
        "Recover Vehicle",
        ""
    ],
    _van,
    "CREATED",
    5,
    true,
    "car",
    true
] call BIS_fnc_taskCreate;

// === WAIT FOR COMPLETION ===
waitUntil {
    sleep 2;
    isNull _van || {!alive _van} || {(_van distance2D _fobPos) < 35}
};

// === FAIL ===
if (isNull _van || {!alive _van}) exitWith {
    [_taskRecover, "FAILED", true] call BIS_fnc_taskSetState;
    missionNamespace setVariable ["MWF_Tutorial_Running", false, true];
};

// === SUCCESS ===
[_taskRecover, "SUCCEEDED", true] call BIS_fnc_taskSetState;

// === DETECT UNDERCOVER STATE AT COMPLETION ===
private _carrier = objNull;
private _driver = driver _van;
if (!isNull _driver && {_driver in allPlayers}) then {
    _carrier = _driver;
} else {
    private _nearPlayers = allPlayers select {alive _x && {_x distance2D _van < 50}};
    if ((count _nearPlayers) > 0) then {
        _carrier = _nearPlayers select 0;
    };
};

private _undercover = [_carrier] call _fnc_isUnitUndercoverForTutorial;
missionNamespace setVariable ["MWF_Tutorial_LastCompletionUndercover", _undercover, true];

// === PROGRESSION ===
[3, _undercover] call MWF_fnc_generateInitialMission;
missionNamespace setVariable ["MWF_Tutorial_Running", false, true];
