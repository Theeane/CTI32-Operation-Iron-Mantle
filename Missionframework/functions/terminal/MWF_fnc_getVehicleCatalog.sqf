/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_getVehicleCatalog
    Project: Military War Framework

    Description:
    Reads all purchasable vehicle data from the active BLUFOR preset.
    Preset order is preserved exactly as written in the active preset.
    Unlock/build gating remains separate from preset ordering so the terminal UX stays predictable.

    Returns:
    [
        ["LIGHT", [[_className, _cost, _minTier, _displayName, _category, _lockReason], ...]],
        ["APC",   [...]],
        ["TANKS", [...]],
        ["HELIS", [...]],
        ["JETS",  [...]],
        ["__META__", [
            ["totalEntries", _count],
            ["emptyCategories", [...]],
            ["invalidEntries", _count]
        ]]
    ]
*/

private _definitions = [
    ["LIGHT", "MWF_Preset_Light"],
    ["APC", "MWF_Preset_APC"],
    ["TANKS", "MWF_Preset_Tanks"],
    ["HELIS", "MWF_Preset_Helis"],
    ["JETS", "MWF_Preset_Jets"]
];

private _mobRef = missionNamespace getVariable ["MWF_MainBase", missionNamespace getVariable ["MWF_MOB", objNull]];
private _mobPos = if (!isNull _mobRef) then { getPosATL _mobRef } else { getMarkerPos "respawn_west" };
private _heliTowerClass = missionNamespace getVariable ["MWF_Heli_Tower_Class", ""];
private _jetControlClass = missionNamespace getVariable ["MWF_Jet_Control_Class", ""];
private _heliBuilt = (_heliTowerClass isNotEqualTo "") && {({ typeOf _x isEqualTo _heliTowerClass } count (nearestObjects [_mobPos, [_heliTowerClass], 120])) > 0};
private _jetBuilt = (_jetControlClass isNotEqualTo "") && {({ typeOf _x isEqualTo _jetControlClass } count (nearestObjects [_mobPos, [_jetControlClass], 120])) > 0};
private _heliUnlocked = missionNamespace getVariable ["MWF_Unlock_Heli", false];
private _jetUnlocked = missionNamespace getVariable ["MWF_Unlock_Jets", false];
private _armorUnlocked = missionNamespace getVariable ["MWF_Unlock_Armor", false];
private _heliDiscount = missionNamespace getVariable ["MWF_Perk_HeliDiscount", 1];

private _catalog = [];
private _totalEntries = 0;
private _emptyCategories = [];
private _invalidEntries = 0;

{
    _x params ["_category", "_varName"];

    private _source = missionNamespace getVariable [_varName, []];
    private _entries = [];
    private _categoryLockReason = switch (_category) do {
        case "APC";
        case "TANKS": {
            if (_armorUnlocked) then { "" } else { "Armor is now available to purchase in the vehicle menu only after the Steel Rain operation is complete." };
        };
        case "HELIS": {
            if (!_heliUnlocked) then {
                "Requires main operation: Sky Guardian."
            } else {
                if (!_heliBuilt) then {
                    "Helicopter access is unlocked. Use Base Building at the MOB to place the helicopter uplink first."
                } else {
                    ""
                };
            };
        };
        case "JETS": {
            if (!_jetUnlocked) then {
                "Requires main operation: Point Blank."
            } else {
                if (!_jetBuilt) then {
                    "Aircraft access is unlocked. Use Base Building at the MOB to place the aircraft control building first."
                } else {
                    ""
                };
            };
        };
        default { "" };
    };

    {
        if (_x isEqualType [] && {(count _x) >= 3}) then {
            private _className = _x param [0, "", [""]];
            private _baseCost = _x param [1, 0, [0]];
            private _cost = _baseCost;
            private _minTier = _x param [2, 1, [0]];

            if (_className isEqualTo "") then {
                _invalidEntries = _invalidEntries + 1;
            } else {
                if ((_category isEqualTo "HELIS") && {_heliDiscount isEqualType 0}) then {
                    _cost = ceil ((_baseCost max 0) * (_heliDiscount max 0.1));
                };

                private _displayName = getText (configFile >> "CfgVehicles" >> _className >> "displayName");
                if (_displayName isEqualTo "") then { _displayName = _className; };

                _entries pushBack [_className, _cost, _minTier, _displayName, _category, _categoryLockReason];
            };
        } else {
            _invalidEntries = _invalidEntries + 1;
        };
    } forEach _source;

    if (_entries isEqualTo []) then {
        _emptyCategories pushBack _category;
    };

    _totalEntries = _totalEntries + (count _entries);
    _catalog pushBack [_category, _entries];
} forEach _definitions;

_catalog pushBack ["__META__", [
    ["totalEntries", _totalEntries],
    ["emptyCategories", _emptyCategories],
    ["invalidEntries", _invalidEntries]
]];

_catalog
