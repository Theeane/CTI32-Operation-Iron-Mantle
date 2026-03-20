/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_resolveCompositionPath
    Project: Military War Framework

    Description:
    Resolves a composition key against the staged era/domain/type composition structure.
    Patch 3A introduces the new layout:
    preset/compositions/{era}/{domain}/{type}/...

    Runtime rules in 3A:
    - composition era defaults to modern
    - domain defaults to land
    - type is inferred from compositionKey when omitted
    - exact per-key files are preferred when they exist
    - current baseline falls back to modern/land generic compositions
      using difficulty -> 01/02/03 mapping

    Parameter(s):
        0: composition key <STRING>
        1: mission domain <STRING> (optional, default: land)
        2: mission type/category <STRING> (optional, default: inferred from key)
        3: composition era <STRING> (optional, default: namespace value or modern)

    Returns:
        Relative mission path string, or empty string if no valid composition could be resolved.
*/
params [
    ["_compositionKey", "", [""]],
    ["_domain", "land", [""]],
    ["_category", "", [""]],
    ["_compositionEra", "", [""]]
];

if (_compositionKey isEqualTo "") exitWith {""};

private _normalize = {
    params ["_value", "_fallback"];
    private _text = toLower str _value;
    if (_text isEqualTo "") then {_text = toLower str _fallback;};
    _text
};

private _era = [_compositionEra, missionNamespace getVariable ["MWF_CompositionType", "modern"]] call _normalize;
private _resolvedDomain = [_domain, "land"] call _normalize;
private _resolvedCategory = [_category, ""] call _normalize;
private _key = toLower _compositionKey;

private _parts = _key splitString "_";
if (_resolvedCategory isEqualTo "") then {
    if ((count _parts) > 0) then {
        _resolvedCategory = _parts # 0;
    };
};

if !(_resolvedCategory in ["disrupt", "intel", "supply"]) exitWith {""};
if !(_resolvedDomain in ["land", "naval", "air"]) then {
    _resolvedDomain = "land";
};
if !(_era in ["modern", "vietnam", "world_war_2", "global_mobilization"]) then {
    _era = "modern";
};

private _difficulty = "easy";
if ((count _parts) > 0) then {
    private _tail = _parts # ((count _parts) - 1);
    if (_tail in ["easy", "medium", "hard"]) then {
        _difficulty = _tail;
    };
};

private _suffix = switch (_difficulty) do {
    case "medium": {"02"};
    case "hard": {"03"};
    default {"01"};
};

private _buildRoot = {
    params ["_useEra", "_useDomain", "_useCategory"];
    format ["preset/compositions/%1/%2/%3", _useEra, _useDomain, _useCategory]
};

private _candidates = [];
private _primaryRoot = [_era, _resolvedDomain, _resolvedCategory] call _buildRoot;
private _fallbackRoot = ["modern", "land", _resolvedCategory] call _buildRoot;

_candidates pushBack format ["%1/%2.sqm", _primaryRoot, _key];
_candidates pushBack format ["%1/%2_composition_%3.sqm", _primaryRoot, _resolvedCategory, _suffix];
if !(_fallbackRoot isEqualTo _primaryRoot) then {
    _candidates pushBack format ["%1/%2.sqm", _fallbackRoot, _key];
    _candidates pushBack format ["%1/%2_composition_%3.sqm", _fallbackRoot, _resolvedCategory, _suffix];
};

private _resolvedPath = "";
{
    if (fileExists _x) exitWith {
        _resolvedPath = _x;
    };
} forEach _candidates;

_resolvedPath
