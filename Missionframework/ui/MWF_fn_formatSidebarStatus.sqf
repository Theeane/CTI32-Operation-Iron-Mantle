/*
    Author: OpenAI
    Function: MWF_fnc_formatSidebarStatus
    Project: Military War Framework

    Description:
    Formats the right-side HUD using the same source values as the terminal.
*/

params [["_status", createHashMap, [createHashMap]]];

parseText format [
    "<t size='0.88' color='#FFFFFF'>SUP %1</t><br/><t size='0.88' color='#8CC8FF'>INT %2</t><br/><t size='0.88' color='#FFD27A'>TEMP %3</t><br/><t size='0.88' color='#FFFFFF'>WORLD T%4</t><br/><t size='0.88' color='#FFFFFF'>BASE T%5</t><br/><t size='0.88' color='#FFFFFF'>PHASE %6</t><br/><t size='0.88' color='#FF5E73'>THR %7%%</t>%8",
    _status getOrDefault ["supplies", 0],
    _status getOrDefault ["intel", 0],
    _status getOrDefault ["tempIntel", 0],
    _status getOrDefault ["worldTier", 1],
    _status getOrDefault ["baseTier", 1],
    _status getOrDefault ["phase", "TUTORIAL"],
    _status getOrDefault ["threat", 0],
    if (_status getOrDefault ["debugMode", false]) then { "<br/><t size='0.82' color='#FFD27A'>DEBUG</t>" } else { "" }
]
