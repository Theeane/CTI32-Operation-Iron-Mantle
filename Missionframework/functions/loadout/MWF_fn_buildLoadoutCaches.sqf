/*
    Author: OpenAI
    Function: MWF_fnc_buildLoadoutCaches
    Project: Military War Framework

    Description:
    Builds uniform classification caches used by the loadout/arsenal and
    undercover systems. Uniforms are classified by the side of their linked
    uniformClass vehicle definition.
*/

private _cached = missionNamespace getVariable ["MWF_LoadoutCachesBuilt", false];
if (_cached) exitWith {
    [
        missionNamespace getVariable ["MWF_OpforUniformClasses", []],
        missionNamespace getVariable ["MWF_CivilianUniformClasses", []],
        missionNamespace getVariable ["MWF_ArsenalItemClasses", []]
    ]
};

private _opforUniforms = [];
private _civilianUniforms = [];
private _arsenalItems = [];

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

missionNamespace setVariable ["MWF_OpforUniformClasses", _opforUniforms];
missionNamespace setVariable ["MWF_CivilianUniformClasses", _civilianUniforms];
missionNamespace setVariable ["MWF_ArsenalItemClasses", _arsenalItems];
missionNamespace setVariable ["MWF_LoadoutCachesBuilt", true];

[
    _opforUniforms,
    _civilianUniforms,
    _arsenalItems
]
