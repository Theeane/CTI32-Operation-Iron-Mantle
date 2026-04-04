/*
    Author: OpenAI
    Function: MWF_fnc_formatTerminalStatus
    Project: Military War Framework

    Description:
    Formats shared terminal status text from a central HUD snapshot.
*/

params [
    ["_status", createHashMap, [createHashMap]],
    ["_options", createHashMap, [createHashMap]]
];

private _showFreeOp = _options getOrDefault ["showFreeOp", false];
private _trailingLabel = _options getOrDefault ["trailingLabel", ""];

private _segments = [
    format ["<t size='0.9' color='#FFFFFF'>SUP %1</t>", _status getOrDefault ["supplies", 0]],
    format ["<t size='0.9' color='#8CC8FF'>INT %1</t>", _status getOrDefault ["intel", 0]],
    format ["<t size='0.9' color='#FFD27A'>TEMP %1</t>", _status getOrDefault ["tempIntel", 0]]
];

if (_showFreeOp) then {
    _segments pushBack format ["<t size='0.9' color='#B7FF9A'>FREE OP %1</t>", _status getOrDefault ["freeMainOpCharges", 0]];
};

_segments append [
    format ["<t size='0.9' color='#FFFFFF'>WORLD T%1</t>", _status getOrDefault ["worldTier", 1]],
    format ["<t size='0.9' color='#FFFFFF'>BASE T%1</t>", _status getOrDefault ["baseTier", 1]],
    format ["<t size='0.9' color='#FFFFFF'>PHASE %1</t>", _status getOrDefault ["phase", "TUTORIAL"]],
    format ["<t size='0.9' color='#FF5E73'>THR %1%%</t>", _status getOrDefault ["threat", 0]]
];

if !(_trailingLabel isEqualTo "") then {
    _segments pushBack format ["<t size='0.9' color='#FFFFFF'>%1</t>", _trailingLabel];
};

if (_status getOrDefault ["debugMode", false]) then {
    _segments pushBack "<t color='#FFD27A'>DEBUG</t>";
};

_segments joinString "<t color='#AAAAAA'> | </t>"
