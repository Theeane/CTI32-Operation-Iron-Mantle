/*
    Author: OpenAI
    Function: MWF_fnc_formatSidebarStatus
    Project: Military War Framework

    Description:
    Formats the right-side HUD using the same source values as the terminal.
*/

params [["_status", createHashMap, [createHashMap]]];

private _worldTier = _status getOrDefault ["worldTier", 1];
private _worldRoman = switch (_worldTier max 1 min 5) do {
    case 1: { "I" };
    case 2: { "II" };
    case 3: { "III" };
    case 4: { "IV" };
    case 5: { "V" };
    default { str _worldTier };
};

parseText format [
    "<t font='PuristaBold' size='0.96' color='#EDEDED'>SUPPLIES:</t><br/><t font='PuristaBold' size='1.08' color='#FFFFFF'>%1</t><br/><t font='PuristaBold' size='0.96' color='#9FD7FF'>INTEL:</t><br/><t font='PuristaBold' size='1.08' color='#DFF4FF'>%2</t><br/><t font='PuristaBold' size='0.96' color='#FF9DA9'>THREAT:</t><br/><t font='PuristaBold' size='1.08' color='#FFC0C8'>%3%%</t><br/><t font='PuristaBold' size='0.96' color='#FFE08A'>WORLD:</t><br/><t font='PuristaBold' size='1.08' color='#FFF1BF'>T %4</t>",
    _status getOrDefault ["supplies", 0],
    _status getOrDefault ["intel", 0],
    _status getOrDefault ["threat", 0],
    _worldRoman
]
