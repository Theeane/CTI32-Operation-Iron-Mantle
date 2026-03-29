/*
    Author: OpenAI / Operation Iron Mantle
    Function: MWF_fnc_handlePostSpawn
    Project: Military War Framework

    Description:
    Centralized local post-spawn pass. Ensures HUD/actions are started once per
    player entity and applies the saved respawn loadout on non-initial spawns.
*/

params [["_isInitialSpawn", false, [false]]];

if (!hasInterface) exitWith { false };
if (isNull player || {!alive player}) exitWith { false };

private _signature = format ["%1|%2", getPlayerUID player, netId player];
if (
    (missionNamespace getVariable ["MWF_LastPostSpawnSignature", ""]) isEqualTo _signature &&
    {missionNamespace getVariable ["MWF_ClientInitComplete", false]}
) exitWith { true };

missionNamespace setVariable ["MWF_PostSpawnInitRunning", true];
missionNamespace setVariable ["MWF_PostSpawnInitSince", diag_tickTime];
missionNamespace setVariable ["MWF_ClientInitStage", if (_isInitialSpawn) then {"INITIAL_POSTSPAWN"} else {"RESPAWN_POSTSPAWN"}];

if (!(missionNamespace getVariable ["MWF_UI_SettingsRegistered", false]) && {!isNil "MWF_fnc_initUI"}) then {
    [] call MWF_fnc_initUI;
    missionNamespace setVariable ["MWF_UI_SettingsRegistered", true];
};

if (!(missionNamespace getVariable ["MWF_LoadoutSystemInitialized", false]) && {!isNil "MWF_fnc_initLoadoutSystem"}) then {
    [] spawn MWF_fnc_initLoadoutSystem;
};

if (!_isInitialSpawn && {uiNamespace getVariable ["MWF_IntroCinematicPlayed", false]} && {!isNil "MWF_fnc_applyRespawnLoadout"}) then {
    [] call MWF_fnc_applyRespawnLoadout;
};

if (!isNil "MWF_fnc_setupInteractions") then {
    [] call MWF_fnc_setupInteractions;
};

if (!isNil "MWF_fnc_updateResourceUI") then {
    [] spawn MWF_fnc_updateResourceUI;
};


[] spawn {
    uiSleep 0.05;
    cutText ["", "BLACK IN", 0.15];
    titleCut ["", "BLACK IN", 0.15];
    showCinemaBorder false;
    if (!isNull player) then {
        player switchCamera "INTERNAL";
    };
};

missionNamespace setVariable ["MWF_LastPostSpawnSignature", _signature];
missionNamespace setVariable ["MWF_ClientInitComplete", true];
missionNamespace setVariable ["MWF_PostSpawnInitRunning", false];
missionNamespace setVariable ["MWF_ClientInitStage", "CLIENT_READY"];

true
