/*
    Author: Theane / ChatGPT
    Function: fn_civilianIntel
    Project: Military War Framework

    Description:
    Civilian questioning helper for the temporary intel pipeline.
*/

params [
    ["_civ", objNull, [objNull]],
    ["_caller", objNull, [objNull]]
];

if (isNull _civ || {!alive _civ}) exitWith {};
if (isNull _caller) then { _caller = player; };
if (_civ getVariable ["MWF_isQuestioned", false]) exitWith {
    ["TaskFailed", ["", "This person has nothing more to say."]] call BIS_fnc_showNotification;
};

_caller playAction "GestureHi";
sleep 2;

private _findChance = 30;
private _intelGained = 8 + floor (random 8);

if ((random 100) <= _findChance) then {
    ["ADD_CARRIED", [_caller, _intelGained, "CIVILIAN TIP", format ["The civilian shared %1 temporary intel.", _intelGained]]] remoteExecCall ["MWF_fnc_intelManager", 2];
    ["TaskSucceeded", ["", format ["The civilian shared local intel! (+%1 Temp Intel)", _intelGained]]] call BIS_fnc_showNotification;
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
