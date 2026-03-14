/*
    Author: Theane / ChatGPT
    File: initPlayerLocal.sqf
    Project: Military War Framework

    Description:
    Initializes player-local UI and command terminal interactions after the player and mission runtime are ready.
*/

if (!hasInterface) exitWith {};

[] spawn {
    waitUntil {
        !isNull player &&
        { time > 0 } &&
        { missionNamespace getVariable ["MWF_ServerInitialized", false] }
    };

    if (!isNil "MWF_fnc_initUI") then {
        [] call MWF_fnc_initUI;
    };

    private _terminals = [];

    {
        private _terminal = missionNamespace getVariable [_x, objNull];
        if (!isNull _terminal) then {
            _terminals pushBackUnique _terminal;
        };
    } forEach [
        "MWF_HQ_Terminal",
        "MWF_MOB_Terminal",
        "MWF_CommandTerminal"
    ];

    {
        [_x] call MWF_fnc_setupInteractions;
    } forEach _terminals;

    [] spawn MWF_fnc_updateResourceUI;

    diag_log format ["[MWF] Client initialization complete for %1.", profileName];
};
