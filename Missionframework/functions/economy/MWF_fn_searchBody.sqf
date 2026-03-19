/*
    Author: Theane / ChatGPT
    Function: fn_searchBody
    Project: Military War Framework

    Description:
    Body-search helper aligned with the current digital intel economy.
*/

params ["_body"];

if (isNull _body) exitWith {};
if (_body getVariable ["MWF_isSearched", false]) exitWith {
    ["TaskFailed", ["", "This body has already been searched."]] call BIS_fnc_showNotification;
};

_body setVariable ["MWF_isSearched", true, true];

player playMove "AinvPknlMstpSnonWnonDnon_medic_1";
sleep 4;

private _intel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];
private _findChance = 35 + (((_intel min 200) / 25) call BIS_fnc_floor);
private _intelGained = 4 + floor (random 6);

if ((random 100) <= _findChance) then {
    if (isServer) then {
        [_intelGained, "INTEL"] call MWF_fnc_addResource;
    } else {
        [_intelGained, "INTEL"] remoteExecCall ["MWF_fnc_addResource", 2];
    };

    ["TaskSucceeded", ["", format ["Found intel documents! (+%1 Intel)", _intelGained]]] call BIS_fnc_showNotification;
    diag_log format ["[Iron Mantle] Intel found on body. Awarded: %1", _intelGained];
} else {
    ["TaskFailed", ["", "No valuable intel found."]] call BIS_fnc_showNotification;
};
