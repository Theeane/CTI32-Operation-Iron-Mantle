/*
    Author: OpenAI / ChatGPT
    Function: MWF_fnc_buildLoadoutCaches
    Project: Military War Framework

    Description:
    Builds clothing classification caches used by the loadout/arsenal and
    undercover systems.

    Caches built:
    - MWF_OpforUniformClasses      : all OPFOR-linked uniforms
    - MWF_CivilianUniformClasses   : all civilian-linked uniforms
    - MWF_ArsenalItemClasses       : Arsenal-visible non-OPFOR-uniform items minus user blacklist entries
    - MWF_OpforClothingClasses     : OPFOR uniform/vest/headgear classes sourced from the active OPFOR preset infantry
*/

private _cached = missionNamespace getVariable ["MWF_LoadoutCachesBuilt", false];
if (_cached) exitWith {
    [
        missionNamespace getVariable ["MWF_OpforUniformClasses", []],
        missionNamespace getVariable ["MWF_CivilianUniformClasses", []],
        missionNamespace getVariable ["MWF_ArsenalItemClasses", []],
        missionNamespace getVariable ["MWF_OpforClothingClasses", []]
    ]
};

if !(missionNamespace getVariable ["MWF_GlobalBlacklistLoaded", false]) then {
    missionNamespace setVariable ["MWF_GlobalBlacklist", [], true];
    call compile preprocessFileLineNumbers "Missionframework/global_blacklist.sqf";
    missionNamespace setVariable ["MWF_GlobalBlacklistLoaded", true];
};

private _globalBlacklist = + (missionNamespace getVariable ["MWF_GlobalBlacklist", []]);
private _opforUniforms = [];
private _civilianUniforms = [];
private _arsenalItems = [];
private _opforClothing = [];

{
    private _cfg = _x;
    if (getNumber (_cfg >> "scope") < 2) then { continue; };

    private _className = configName _cfg;
    private _uniformClass = if (isClass (_cfg >> "ItemInfo")) then {
        getText (_cfg >> "ItemInfo" >> "uniformClass")
    } else {
        ""
    };

    if !(_uniformClass isEqualTo "") then {
        private _side = getNumber (configFile >> "CfgVehicles" >> _uniformClass >> "side");
        switch (_side) do {
            case 0: { _opforUniforms pushBackUnique _className; };
            case 3: {
                _civilianUniforms pushBackUnique _className;
                _arsenalItems pushBackUnique _className;
            };
            default {
                _arsenalItems pushBackUnique _className;
            };
        };
    } else {
        _arsenalItems pushBackUnique _className;
    };
} forEach ("true" configClasses (configFile >> "CfgWeapons"));

private _isTrackedClothingItem = {
    params ["_itemClass"];
    if (_itemClass isEqualTo "") exitWith { false };
    if !(isClass (configFile >> "CfgWeapons" >> _itemClass)) exitWith { false };

    private _cfg = configFile >> "CfgWeapons" >> _itemClass;
    if !(isClass (_cfg >> "ItemInfo")) exitWith { false };

    private _uniformClass = getText (_cfg >> "ItemInfo" >> "uniformClass");
    if !(_uniformClass isEqualTo "") exitWith { true };

    private _itemType = getNumber (_cfg >> "ItemInfo" >> "type");
    _itemType in [605, 701]
};

private _collectOpforClothingFromUnit = {
    params ["_unitClass"];

    if !(_unitClass isEqualType "") exitWith {};
    if !(isClass (configFile >> "CfgVehicles" >> _unitClass)) exitWith {};

    private _unitCfg = configFile >> "CfgVehicles" >> _unitClass;

    private _uniformItem = getText (_unitCfg >> "uniformClass");
    if !(_uniformItem isEqualTo "") then {
        _opforClothing pushBackUnique _uniformItem;
        _opforUniforms pushBackUnique _uniformItem;
    };

    {
        if ([_x] call _isTrackedClothingItem) then {
            _opforClothing pushBackUnique _x;
        };
    } forEach (getArray (_unitCfg >> "linkedItems"));
};

private _opforPreset = missionNamespace getVariable ["MWF_OPFOR_Preset", createHashMap];
if (!isNil "_opforPreset" && {_opforPreset isEqualType createHashMap}) then {
    {
        {
            [_x] call _collectOpforClothingFromUnit;
        } forEach (_opforPreset getOrDefault [_x, []]);
    } forEach ["Infantry_T1", "Infantry_T2", "Infantry_T3", "Infantry_T4", "Infantry_T5"];
};

_arsenalItems = _arsenalItems - _globalBlacklist;

missionNamespace setVariable ["MWF_OpforUniformClasses", _opforUniforms];
missionNamespace setVariable ["MWF_CivilianUniformClasses", _civilianUniforms];
missionNamespace setVariable ["MWF_ArsenalItemClasses", _arsenalItems];
missionNamespace setVariable ["MWF_OpforClothingClasses", _opforClothing];
missionNamespace setVariable ["MWF_LoadoutCachesBuilt", true];

[
    _opforUniforms,
    _civilianUniforms,
    _arsenalItems,
    _opforClothing
]
