/*
    Author: Theane / ChatGPT
    Function: fn_searchBody
    Project: Military War Framework

    Description:
    Body-search helper for the temporary intel pipeline.
*/

params [
    ["_body", objNull, [objNull]],
    ["_caller", objNull, [objNull]]
];

if (isNull _body) exitWith {};
if (isNull _caller) then { _caller = player; };
if (_body getVariable ["MWF_isSearched", false]) exitWith {
    ["TaskFailed", ["", "This body has already been searched."]] call BIS_fnc_showNotification;
};

_body setVariable ["MWF_isSearched", true, true];
_caller playMove "AinvPknlMstpSnonWnonDnon_medic_1";
sleep 4;

private _findChance = 45;
private _intelGained = 4 + floor (random 6);

if ((random 100) <= _findChance) then {
    ["ADD_CARRIED", [_caller, _intelGained, "BODY SEARCH", format ["Recovered %1 temporary intel from the body.", _intelGained]]] remoteExecCall ["MWF_fnc_intelManager", 2];
    ["TaskSucceeded", ["", format ["Found intel documents! (+%1 Temp Intel)", _intelGained]]] call BIS_fnc_showNotification;
    diag_log format ["[Iron Mantle] Temp intel found on body. Awarded: %1", _intelGained];
} else {
    ["TaskFailed", ["", "No valuable intel found."]] call BIS_fnc_showNotification;
};
