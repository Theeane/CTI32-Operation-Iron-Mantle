/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_showEndingScreen
    Description: Presents the 30-second finale screen while the endgame music continues.
*/
params [
    ["_endingType", "PLAYER", [""]],
    ["_analytics", [], [[]]],
    ["_duration", 30, [0]]
];

if (isServer && {!hasInterface}) exitWith {
    private _rows = if (_analytics isEqualTo []) then { +(missionNamespace getVariable ["MWF_Campaign_Analytics", []]) } else { +_analytics };
    [_endingType, _rows, _duration] remoteExec ["MWF_fnc_showEndingScreen", 0];
};

private _rows = if (_analytics isEqualTo []) then { +(missionNamespace getVariable ["MWF_Campaign_Analytics", []]) } else { +_analytics };

private _pickWinner = {
    params ["_fieldIndex"];
    private _best = [];
    private _bestValue = -1;
    {
        private _value = _x param [_fieldIndex, 0];
        if (_value > _bestValue) then {
            _best = +_x;
            _bestValue = _value;
        };
    } forEach _rows;
    [_best, _bestValue]
};

private _fmt = {
    params ["_title", "_winnerArray"];
    private _winner = _winnerArray param [0, []];
    private _value = _winnerArray param [1, 0];
    if (_winner isEqualTo [] || {_value <= 0}) exitWith { format ["%1: None", _title] };
    format ["%1: %2 (%3)", _title, _winner param [1, "Unknown"], _value]
};

private _endingTitle = switch (toUpper _endingType) do {
    case "REBEL": {"Rebel Ending"};
    default {"Player Ending"};
};

private _executioner = [7] call _pickWinner;
private _textLines = [
    format ["<t size='1.35' color='#d8c27a'>%1</t>", _endingTitle],
    " ",
    ["OPFOR Killed", [2] call _pickWinner] call _fmt,
    ["Rebels Killed", [3] call _pickWinner] call _fmt,
    ["Civilians Killed", [4] call _pickWinner] call _fmt,
    ["Buildings Destroyed", [5] call _pickWinner] call _fmt,
    ["HQ / Roadblocks Destroyed", [6] call _pickWinner] call _fmt,
    ["Executioner of Unarmed Boss", _executioner] call _fmt
];

private _finalText = _textLines joinString "<br/>";
hintSilent parseText _finalText;

[_duration] spawn {
    params ["_dur"];
    uiSleep (_dur max 1);
    hintSilent "";
};
