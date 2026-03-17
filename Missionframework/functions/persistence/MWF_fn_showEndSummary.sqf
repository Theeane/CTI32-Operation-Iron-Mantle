/*
    Author: Theane / ChatGPT
    Function: fn_showEndSummary
    Project: Military War Framework

    Description:
    Builds and shows the dynamic end-of-campaign summary based on accumulated analytics.
    Call on server to broadcast to all clients, or locally with prepared data.
*/

params [["_analytics", [], [[]]]];

if (isServer && {!hasInterface}) exitWith {
    private _serverAnalytics = if (_analytics isEqualTo []) then {
        + (missionNamespace getVariable ["MWF_Campaign_Analytics", []])
    } else {
        + _analytics
    };

    [_serverAnalytics] remoteExec ["MWF_fnc_showEndSummary", 0];
};

private _rows = if (_analytics isEqualTo []) then {
    + (missionNamespace getVariable ["MWF_Campaign_Analytics", []])
} else {
    + _analytics
};

private _pickWinner = {
    params ["_fieldIndex"];
    private _best = [];
    private _bestValue = -1;
    {
        private _value = _x param [_fieldIndex, 0];
        if (_value > _bestValue) then {
            _best = + _x;
            _bestValue = _value;
        };
    } forEach _rows;
    [_best, _bestValue]
};

private _opfor = [2] call _pickWinner;
private _rebels = [3] call _pickWinner;
private _civs = [4] call _pickWinner;
private _buildings = [5] call _pickWinner;
private _hqrb = [6] call _pickWinner;
private _executioner = [7] call _pickWinner;

private _fmt = {
    params ["_title", "_winnerArray"];
    private _winner = _winnerArray param [0, []];
    private _value = _winnerArray param [1, 0];
    if (_winner isEqualTo [] || {_value <= 0}) exitWith {
        format ["%1: None", _title]
    };
    format ["%1: %2 (%3)", _title, _winner param [1, "Unknown"], _value]
};

private _textLines = [
    "<t size='1.35' color='#d8c27a'>Campaign End Summary</t>",
    " ",
    ["OPFOR Killed", _opfor] call _fmt,
    ["Rebels Killed", _rebels] call _fmt,
    ["Civilians Killed", _civs] call _fmt,
    ["Buildings Destroyed", _buildings] call _fmt,
    ["HQ / Roadblocks Destroyed", _hqrb] call _fmt,
    ["Executioner of Unarmed Boss", _executioner] call _fmt
];

private _finalText = _textLines joinString "<br/>";
hintSilent parseText _finalText;
