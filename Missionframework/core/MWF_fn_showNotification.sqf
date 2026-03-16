/*
    Author: Theane / ChatGPT
    Function: MWF_fn_showNotification
    Project: Military War Framework

    Description:
    Lightweight shared notification wrapper.
*/

params [
    ["_payload", [], [[]]],
    ["_style", "info", [""]]
];

private _title = "MWF";
private _message = "";

if (_payload isEqualType []) then {
    _title = _payload param [0, "MWF"];
    _message = _payload param [1, ""];
} else {
    _message = str _payload;
};

hintSilent parseText format [
    "<t size='1.1' color='#9ad8ff'>%1</t><br/><t size='0.95'>%2</t>",
    _title,
    _message
];
