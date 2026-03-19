/*
    Author: OpenAI / ChatGPT
    Function: fn_getMissionImpactProfile
    Project: Military War Framework

    Description:
    Returns a deterministic impact profile for side missions and main operations.
    Side missions use fixed values by category/difficulty.
    Main operations use fixed strategic profiles with explicit support for:
    - tier reduction
    - tier block / grace period
    - main-op threat progression suppression
    - fallback reward conversion
*/

params [
    ["_kind", "side", [""]],
    ["_id", "", ["",0]],
    ["_difficulty", "", [""]]
];

_kind = toLower _kind;
private _key = toLower str _id;
private _diff = toLower _difficulty;

private _profile = createHashMapFromArray [
    ["kind", _kind],
    ["id", _key],
    ["threatDelta", 0],
    ["tierDelta", 0],
    ["supplies", 0],
    ["intel", 0],
    ["fallbackSupplies", 200],
    ["fallbackIntel", 100],
    ["blockTierProgressSeconds", 0],
    ["blockMainOpThreatSeconds", 0],
    ["loudRequired", true],
    ["note", ""]
];

if (_kind isEqualTo "side") exitWith {
    private _category = _key;
    private _threatDelta = 0;
    private _tierDelta = 0;
    private _supplies = 0;
    private _intel = 0;

    switch (_category) do {
        case "disrupt": {
            switch (_diff) do {
                case "easy":   { _threatDelta = 8;  _tierDelta = 5;  _supplies = 80;  _intel = 20; };
                case "medium": { _threatDelta = 12; _tierDelta = 8;  _supplies = 120; _intel = 35; };
                case "hard":   { _threatDelta = 18; _tierDelta = 12; _supplies = 180; _intel = 50; };
                default          { _threatDelta = 10; _tierDelta = 6;  _supplies = 100; _intel = 25; };
            };
        };
        case "supply": {
            switch (_diff) do {
                case "easy":   { _threatDelta = 5;  _tierDelta = 4;  _supplies = 120; _intel = 10; };
                case "medium": { _threatDelta = 8;  _tierDelta = 7;  _supplies = 170; _intel = 20; };
                case "hard":   { _threatDelta = 12; _tierDelta = 10; _supplies = 240; _intel = 30; };
                default          { _threatDelta = 7;  _tierDelta = 5;  _supplies = 140; _intel = 15; };
            };
        };
        case "intel": {
            switch (_diff) do {
                case "easy":   { _threatDelta = 4;  _tierDelta = 3;  _supplies = 50;  _intel = 60; };
                case "medium": { _threatDelta = 7;  _tierDelta = 6;  _supplies = 80;  _intel = 100; };
                case "hard":   { _threatDelta = 10; _tierDelta = 9;  _supplies = 120; _intel = 150; };
                default          { _threatDelta = 5;  _tierDelta = 4;  _supplies = 60;  _intel = 75; };
            };
        };
        default {
            _threatDelta = 6;
            _tierDelta = 4;
            _supplies = 100;
            _intel = 25;
        };
    };

    _profile set ["threatDelta", _threatDelta];
    _profile set ["tierDelta", _tierDelta];
    _profile set ["supplies", _supplies];
    _profile set ["intel", _intel];
    _profile set ["fallbackSupplies", _supplies];
    _profile set ["fallbackIntel", _intel];
    _profile
};

if (_kind isEqualTo "main") exitWith {
    switch (_key) do {
        case "sky_guardian": {
            _profile set ["threatDelta", 18];
            _profile set ["tierDelta", 22];
            _profile set ["fallbackSupplies", 300];
            _profile set ["fallbackIntel", 125];
            _profile set ["note", "Air superiority operation."];
        };
        case "point_blank": {
            _profile set ["threatDelta", 22];
            _profile set ["tierDelta", 28];
            _profile set ["fallbackSupplies", 325];
            _profile set ["fallbackIntel", 150];
            _profile set ["note", "Missile complex strike."];
        };
        case "severed_nerve": {
            _profile set ["threatDelta", 0];
            _profile set ["tierDelta", -100];
            _profile set ["fallbackSupplies", 300];
            _profile set ["fallbackIntel", 150];
            _profile set ["note", "Regional de-escalation operation."];
        };
        case "stasis_strike": {
            _profile set ["threatDelta", 0];
            _profile set ["tierDelta", 0];
            _profile set ["blockTierProgressSeconds", 3600];
            _profile set ["blockMainOpThreatSeconds", 3600];
            _profile set ["fallbackSupplies", 250];
            _profile set ["fallbackIntel", 125];
            _profile set ["note", "Temporarily freezes enemy strategic escalation."];
        };
        case "steel_rain": {
            _profile set ["threatDelta", 20];
            _profile set ["tierDelta", 24];
            _profile set ["fallbackSupplies", 325];
            _profile set ["fallbackIntel", 125];
            _profile set ["note", "Heavy support disruption."];
        };
        case "apex_predator": {
            _profile set ["threatDelta", 28];
            _profile set ["tierDelta", 34];
            _profile set ["fallbackSupplies", 400];
            _profile set ["fallbackIntel", 175];
            _profile set ["note", "Late-war peak escalation."];
        };
        default {
            _profile set ["threatDelta", 15];
            _profile set ["tierDelta", 18];
            _profile set ["fallbackSupplies", 250];
            _profile set ["fallbackIntel", 100];
        };
    };

    _profile
};

_profile
