/*
    Author: Theane / ChatGPT
    Function: MWF_fn_isBuildAssetAllowed
    Project: Military War Framework

    Description:
    Generic validation gate for Zeus base-building assets. Keeps the system flexible
    for presets/mods while blocking ruins, wrecks, and obviously destroyed variants.
*/

params [["_input", "", ["", objNull]]];

private _className = if (_input isEqualType objNull) then {
    if (isNull _input) then { "" } else { typeOf _input };
} else {
    _input;
};

if (_className isEqualTo "") exitWith { [false, "Invalid build asset."] };

private _cfg = configFile >> "CfgVehicles" >> _className;
if !(isClass _cfg) exitWith { [false, format ["Unknown build asset class: %1", _className]] };

private _classLower = toLower _className;
private _displayName = toLower getText (_cfg >> "displayName");
private _editorCategory = toLower getText (_cfg >> "editorCategory");
private _editorSubcategory = toLower getText (_cfg >> "editorSubcategory");
private _tokens = ["ruin", "wreck", "debris", "destroyed", "damaged"];

private _blocked = _tokens findIf {
    private _token = _x;
    (_classLower find _token) > -1 ||
    (_displayName find _token) > -1 ||
    (_editorCategory find _token) > -1 ||
    (_editorSubcategory find _token) > -1
} > -1;

if (_blocked) exitWith {
    [false, "Ruins, wrecks, and destroyed variants are blocked in Base Building."]
};

[true, "Build asset allowed."]
