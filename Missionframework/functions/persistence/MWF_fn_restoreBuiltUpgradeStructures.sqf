/*
    Author: OpenAI / ChatGPT
    Function: MWF_fn_restoreBuiltUpgradeStructures
    Project: Military War Framework

    Description:
    Restores physical base-upgrade structures after presets and FOBs are loaded.
    Virtual Garages are re-registered with live interactions and inventory summaries.
*/

if (!isServer) exitWith { false };
if (missionNamespace getVariable ["MWF_BuiltUpgradeStructuresRestored", false]) exitWith { true };

private _pending = + (missionNamespace getVariable ["MWF_PendingBuiltUpgradeStructures", []]);
if (_pending isEqualTo []) exitWith {
    missionNamespace setVariable ["MWF_BuiltUpgradeRegistry", [], true];
    missionNamespace setVariable ["MWF_GarageRegistry", missionNamespace getVariable ["MWF_GarageRegistry", []], true];
    missionNamespace setVariable ["MWF_BuiltUpgradeStructuresRestored", true, true];
    true
};

private _mobLabel = missionNamespace getVariable ["MWF_MOB_Name", "MOB"];
private _garageStorage = + (missionNamespace getVariable ["MWF_GarageStoredVehicles", []]);
private _fobRegistry = missionNamespace getVariable ["MWF_FOB_Registry", []];

private _getGarageSummary = {
    params [["_baseKey", "MOB", [""]]];

    private _storageIndex = _garageStorage findIf { (_x param [0, "", [""]]) isEqualTo _baseKey };
    private _records = if (_storageIndex >= 0) then { + ((_garageStorage # _storageIndex) param [1, [], [[]]]) } else { [] };
    private _summary = [];

    {
        private _className = _x param [0, "", [""]];
        private _displayName = getText (configFile >> "CfgVehicles" >> _className >> "displayName");
        if (_displayName isEqualTo "") then { _displayName = _className; };
        private _kindText = _x param [6, "Stored", [""]];
        _summary pushBack [_displayName, _className, _kindText];
    } forEach _records;

    _summary
};

private _registry = [];
private _garageRegistry = [];
private _restored = 0;
private _skipped = 0;

{
    _x params [
        ["_upgradeId", "", [""]],
        ["_className", "", [""]],
        ["_posASL", [0, 0, 0], [[]]],
        ["_vectorDir", [0, 1, 0], [[]]],
        ["_vectorUp", [0, 0, 1], [[]]],
        ["_damage", 0, [0]],
        ["_baseKey", "MOB", [""]],
        ["_baseType", "MOB", [""]],
        ["_baseLabel", "", [""]]
    ];

    _upgradeId = toUpper _upgradeId;
    if (_baseType isEqualTo "") then {
        _baseType = if ((_baseKey find "FOB:") isEqualTo 0) then { "FOB" } else { "MOB" };
    };
    if (_baseLabel isEqualTo "") then {
        _baseLabel = if (_baseType isEqualTo "FOB" && {(_baseKey find "FOB:") isEqualTo 0}) then {
            _baseKey select [4]
        } else {
            _mobLabel
        };
    };

    if (_className isEqualTo "") then {
        _skipped = _skipped + 1;
    } else {
        private _baseValid = true;
        if (_baseType isEqualTo "FOB") then {
            _baseValid = (_fobRegistry findIf { format ["FOB:%1", _x param [2, "", [""]]] isEqualTo _baseKey }) > -1;
        };

        if (!_baseValid) then {
            _skipped = _skipped + 1;
            diag_log format ["[MWF Persistence] Skipped restoring %1 at %2 because the base was not present.", _upgradeId, _baseKey];
        } else {
            private _obj = createVehicle [_className, [0, 0, 0], [], 0, "CAN_COLLIDE"];
            if (isNull _obj) then {
                _skipped = _skipped + 1;
                diag_log format ["[MWF Persistence] Failed to restore upgrade %1 class %2.", _upgradeId, _className];
            } else {
                _obj setPosASL _posASL;
                _obj setVectorDirAndUp [_vectorDir, _vectorUp];
                _obj setDamage (_damage max 0 min 1);
                _obj setVariable ["MWF_isPhysicalBaseUpgrade", true, true];
                _obj setVariable ["MWF_UpgradeId", _upgradeId, true];
                _obj setVariable ["MWF_BaseKey", _baseKey, true];
                _obj setVariable ["MWF_BaseType", _baseType, true];
                _obj setVariable ["MWF_BaseLabel", _baseLabel, true];

                _registry = _registry select {
                    private _existingObj = _x param [1, objNull];
                    private _existingId = _x param [0, "", [""]];
                    private _existingBaseKey = _x param [3, "", [""]];
                    !isNull _existingObj && {!((_existingId isEqualTo _upgradeId) && {(_existingBaseKey isEqualTo _baseKey)})}
                };
                _registry pushBack [_upgradeId, _obj, _className, _baseKey, _baseType, _baseLabel];

                if (_upgradeId isEqualTo "GARAGE") then {
                    _obj allowDamage false;
                    _obj setVariable ["MWF_isVirtualGarage", true, true];
                    _obj setVariable ["MWF_Garage_BaseType", _baseType, true];
                    _obj setVariable ["MWF_Garage_BaseLabel", _baseLabel, true];
                    _obj setVariable ["MWF_Garage_BaseKey", _baseKey, true];
                    private _summary = [_baseKey] call _getGarageSummary;
                    _obj setVariable ["MWF_Garage_InventorySummary", _summary, true];
                    _obj setVariable ["MWF_Garage_InventoryCount", count _summary, true];

                    _garageRegistry = _garageRegistry select {
                        private _garageObj = _x param [0, objNull];
                        private _garageKey = _x param [1, "", [""]];
                        !isNull _garageObj && {!(_garageKey isEqualTo _baseKey)}
                    };
                    _garageRegistry pushBack [_obj, _baseKey, _baseLabel, _baseType];

                    [_obj] remoteExec ["MWF_fnc_setupGarageInteractions", 0, true];
                };

                _restored = _restored + 1;
            };
        };
    };
} forEach _pending;

missionNamespace setVariable ["MWF_BuiltUpgradeRegistry", _registry, true];
missionNamespace setVariable ["MWF_GarageRegistry", _garageRegistry, true];
missionNamespace setVariable ["MWF_PendingBuiltUpgradeStructures", [], true];
missionNamespace setVariable ["MWF_BuiltUpgradeStructuresRestored", true, true];

diag_log format ["[MWF Persistence] Restored %1 physical base upgrade structure(s). Skipped: %2.", _restored, _skipped];
true
