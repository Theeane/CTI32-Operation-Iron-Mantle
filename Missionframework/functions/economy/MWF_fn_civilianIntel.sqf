/*
    Author: Theane / ChatGPT
    Function: fn_civilianIntel
    Project: Military War Framework

    Description:
    Civilian questioning helper aligned with the current digital intel economy.
*/

params ["_civ"];

if (isNull _civ || {!alive _civ}) exitWith {};
if (_civ getVariable ["MWF_isQuestioned", false]) exitWith {
    ["TaskFailed", ["", "This person has nothing more to say."]] call BIS_fnc_showNotification;
};

player playAction "GestureHi";
sleep 2;

private _intel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];
private _findChance = 25 + (((_intel min 200) / 20) call BIS_fnc_floor);
private _intelGained = 8 + floor (random 8);

if ((random 100) <= _findChance) then {
    if (isServer) then {
        [_intelGained, "INTEL"] call MWF_fnc_addResource;
    } else {
        [_intelGained, "INTEL"] remoteExecCall ["MWF_fnc_addResource", 2];
    };

    ["TaskSucceeded", ["", format ["The civilian shared local intel! (+%1 Intel)", _intelGained]]] call BIS_fnc_showNotification;
    _civ setVariable ["MWF_isQuestioned", true, true];
} else {
    private _refusalMessages = [
        "I don't know anything about the enemy.",
        "Please, I just want to be left alone.",
        "I have work to do, go away.",
        "I haven't seen any soldiers around here."
    ];

    _civ sideChat (selectRandom _refusalMessages);
    _civ setVariable ["MWF_isQuestioned", true, true];
};
