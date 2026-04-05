/*
    Validation gate for Zeus base-building assets.
    Goal for this pass:
    - keep object/structure content available
    - block units/vehicles/weapons systems
    - block ruins/wrecks and other destroyed debris content
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

private _scopeCurator = getNumber (_cfg >> "scopeCurator");
if (_scopeCurator <= 0) exitWith { [false, "Hidden/invalid curator asset blocked."] };

if (
    _className isKindOf ["Man", configFile >> "CfgVehicles"] ||
    _className isKindOf ["LandVehicle", configFile >> "CfgVehicles"] ||
    _className isKindOf ["Air", configFile >> "CfgVehicles"] ||
    _className isKindOf ["Ship", configFile >> "CfgVehicles"] ||
    _className isKindOf ["StaticWeapon", configFile >> "CfgVehicles"]
) exitWith {
    [false, "Only build objects are allowed in Base Building."]
};

private _classLower = toLower _className;
private _displayName = toLower getText (_cfg >> "displayName");
private _editorCategory = toLower getText (_cfg >> "editorCategory");
private _editorSubcategory = toLower getText (_cfg >> "editorSubcategory");

private _blockedTokens = [
    "ruin", "wreck", "debris", "destroyed", "damaged"
];

private _blocked = _blockedTokens findIf {
    private _token = _x;
    (_classLower find _token) > -1 ||
    (_displayName find _token) > -1 ||
    (_editorCategory find _token) > -1 ||
    (_editorSubcategory find _token) > -1
} > -1;

if (_blocked) exitWith {
    [false, "Ruins and wreck/debris objects are blocked in Base Building."]
};

private _isObjectLike =
    (_className isKindOf ["House", configFile >> "CfgVehicles"]) ||
    (_className isKindOf ["Building", configFile >> "CfgVehicles"]) ||
    (_className isKindOf ["Thing", configFile >> "CfgVehicles"]) ||
    (_className isKindOf ["ThingX", configFile >> "CfgVehicles"]) ||
    (_className isKindOf ["Strategic", configFile >> "CfgVehicles"]) ||
    (_className isKindOf ["NonStrategic", configFile >> "CfgVehicles"]);

if !(_isObjectLike) exitWith {
    [false, "Only object/structure assets are allowed in Base Building."]
};

[true, "Build asset allowed."]
