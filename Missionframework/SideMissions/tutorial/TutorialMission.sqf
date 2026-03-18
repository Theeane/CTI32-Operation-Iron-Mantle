/*
File: TutorialMission.sqf
Updated for new system (preset + reward + phase driven)
*/

if (!isServer) exitWith {};

if (missionNamespace getVariable ["MWF_Tutorial_Running", false]) exitWith {};
missionNamespace setVariable ["MWF_Tutorial_Running", true, true];

// === BASE ===
private _fob = missionNamespace getVariable ["MWF_MainBase", objNull];
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

```
private _unit = _enemyGroup createUnit [_class, _pos, [], 0, "FORM"];
_unit setSkill 0.3;
_unit setBehaviour "AWARE";
```

};

_enemyGroup deleteGroupWhenEmpty true;

// === TASK: RECOVER ===
private _taskRecover = "task_tutorial_recover_van";

[
west,
_taskRecover,
[
"Recover the vehicle and return it to the FOB.",
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

// === DETECT UNDERCOVER ===
private _undercover = missionNamespace getVariable ["MWF_Player_WasUndercover", false];

// === APPLY REWARD (CENTRAL SYSTEM) ===
[_undercover] call MWF_fnc_applyTutorialReward;

// === PROGRESSION ===
missionNamespace setVariable ["MWF_Tutorial_SupplyRunDone", true, true];

// Shift phase properly
["SUPPLY_RUN", "Tutorial complete"] call MWF_fnc_setCampaignPhase;

missionNamespace setVariable ["MWF_Tutorial_Running", false, true];
