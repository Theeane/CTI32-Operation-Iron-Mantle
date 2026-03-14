/*
    Author: Theane / ChatGPT
    Function: initPlayerLocal
    Project: Military War Framework

    Description:
    Initializes player-local UI and command-terminal interactions.
*/

if (!hasInterface) exitWith {};

[] spawn {
    waitUntil { !isNull player && { time > 0 } };

    [] call MWF_fnc_initUI;

    private _terminals = [];
    {
        if (!isNull _x) then {
            _terminals pushBackUnique _x;
        };
    } forEach [
        missionNamespace getVariable ["MWF_HQ_Terminal", objNull],
        missionNamespace getVariable ["MWF_MOB_Terminal", objNull],
        missionNamespace getVariable ["MWF_CommandTerminal", objNull]
    ];

    {
        [_x] call MWF_fnc_setupInteractions;
    } forEach (_terminals select { !isNull _x });

    diag_log format ["[MWF] Client initialization complete for %1.", profileName];
};
