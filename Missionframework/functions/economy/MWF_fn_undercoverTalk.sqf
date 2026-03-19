/*
    Author: Theane / ChatGPT
    Function: fn_undercoverTalk
    Project: Military War Framework

    Description:
    Undercover conversation helper aligned with the current digital intel economy.
*/

params ["_enemy"];

if (isNull _enemy || {!alive _enemy}) exitWith {};
if (_enemy getVariable ["MWF_isQuestioned", false]) exitWith {};

player playAction "GestureHi";
sleep 2;

private _intel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];
private _successChance = 30 + (((_intel min 200) / 20) call BIS_fnc_floor);

if ((random 100) < _successChance) then {
    private _bonusType = selectRandom ["Patrol", "Supply", "General"];

    switch (_bonusType) do {
        case "Patrol": {
            _enemy sideChat "Don't go north, the boys are out on a heavy patrol there.";
            [0, true, player] remoteExecCall ["MWF_fnc_buyIntel", 2];
        };

        case "Supply": {
            _enemy sideChat "The supply truck is late again, probably stuck at the checkpoint.";
            if (isServer) then {
                [10, "INTEL"] call MWF_fnc_addResource;
            } else {
                [10, "INTEL"] remoteExecCall ["MWF_fnc_addResource", 2];
            };
        };

        default {
            _enemy sideChat "I heard the commander is bringing in the heavy armor tomorrow.";
            if (isServer) then {
                [16, "INTEL"] call MWF_fnc_addResource;
            } else {
                [16, "INTEL"] remoteExecCall ["MWF_fnc_addResource", 2];
            };
        };
    };

    _enemy setVariable ["MWF_isQuestioned", true, true];
    ["TaskSucceeded", ["", "Undercover Bonus: Enemy leaked information!"]] call BIS_fnc_showNotification;
} else {
    _enemy sideChat "Hey! You're that saboteur they warned us about!";

    player setVariable ["MWF_isUndercover", false, true];
    player setCaptive false;

    ["TaskFailed", ["", "Undercover compromised! Prepare for combat!"]] call BIS_fnc_showNotification;
};
