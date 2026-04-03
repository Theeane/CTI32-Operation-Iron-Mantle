/*
    Author: Theane / ChatGPT
    Function: MWF_fn_finalizeBuild
    Project: Military War Framework

    Description:
    Finalizes a server-side build request, validating the placement before
    charging supplies and spawning the shared object.
*/

if (!isServer) exitWith {};

params [
    ["_className", "", [""]],
    ["_pos", [0, 0, 0], [[]], 3],
    ["_dir", 0, [0]],
    ["_priceHint", 0, [0]],
    ["_builder", objNull, [objNull]]
];

private _notifyBuilder = {
    params ["_text"];
    if (!isNull _builder) then {
        [_text] remoteExec ["systemChat", owner _builder];
    };
};

if (_className isEqualTo "") exitWith {};
if ((count _pos) < 2) exitWith {};
if (surfaceIsWater [_pos # 0, _pos # 1]) exitWith {
    ["Build failed: structure must be placed on land."] call _notifyBuilder;
};

private _diameter = sizeOf _className;
if (_diameter <= 0) then { _diameter = 6; };
private _safetyRadius = ((_diameter * 0.55) max 3.5) min 16;
private _near = nearestObjects [_pos, ["Building", "House", "LandVehicle", "Air", "Ship", "CAManBase"], _safetyRadius + 6, true];
private _blocking = objNull;
{
    if (!isNull _x && {_x != _builder}) then {
        private _otherRadius = if (_x isKindOf "CAManBase") then { 1.2 } else { ((((sizeOf (typeOf _x)) max 2) * 0.45) + 0.75) max 1.5 };
        if ((_x distance2D _pos) < ((_safetyRadius * 0.75) + _otherRadius)) exitWith { _blocking = _x; };
    };
} forEach _near;
if (!isNull _blocking) exitWith {
    [format ["Build failed: placement blocked by %1.", typeOf _blocking]] call _notifyBuilder;
};

private _check = [_className] call MWF_fnc_isBuildAssetAllowed;
if !(_check # 0) exitWith { [(_check # 1)] call _notifyBuilder; };

private _mainBase = missionNamespace getVariable ["MWF_MainBase", missionNamespace getVariable ["MWF_MOB", objNull]];
private _mainBasePos = if (!isNull _mainBase) then { getPosATL _mainBase } else { getMarkerPos "respawn_west" };

private _heliClass = missionNamespace getVariable ["MWF_Heli_Tower_Class", ""];
private _jetClass = missionNamespace getVariable ["MWF_Jet_Control_Class", ""];
private _garageClass = missionNamespace getVariable ["MWF_Virtual_Garage", ""];
private _isHeliUpgrade = (_heliClass isNotEqualTo "") && {_className isEqualTo _heliClass};
private _isJetUpgrade = (_jetClass isNotEqualTo "") && {_className isEqualTo _jetClass};
private _isGarageUpgrade = (_garageClass isNotEqualTo "") && {_className isEqualTo _garageClass};

if (_isHeliUpgrade && {!( ["HELI"] call MWF_fnc_hasProgressionAccess )}) exitWith { ["Helicopter Uplink is locked. Complete Sky Guardian first."] call _notifyBuilder; };
if (_isJetUpgrade && {!( ["JETS"] call MWF_fnc_hasProgressionAccess )}) exitWith { ["Aircraft Control is locked. Complete Point Blank first."] call _notifyBuilder; };

private _resolveGarageBase = {
    params ["_garagePos"];
    if (!isNull _mainBase && {_garagePos distance2D _mainBasePos <= 120}) exitWith { [true, "MOB", "MOB", missionNamespace getVariable ["MWF_MOB_Name", "MOB"], _mainBase, _mainBasePos] };
    private _fobRegistry = missionNamespace getVariable ["MWF_FOB_Registry", []];
    private _bestRecord = [];
    private _bestDist = 1e10;
    {
        private _terminal = _x param [1, objNull];
        private _name = _x param [2, "FOB", [""]];
        if (!isNull _terminal) then {
            private _dist = _garagePos distance2D _terminal;
            if (_dist <= 120 && {_dist < _bestDist}) then {
                _bestRecord = [true, "FOB", format ["FOB:%1", _name], _name, _terminal, getPosATL _terminal];
                _bestDist = _dist;
            };
        };
    } forEach _fobRegistry;
    if (_bestRecord isEqualTo []) then { [false, "", "", "", objNull, [0, 0, 0]] } else { _bestRecord };
};

if ((_isHeliUpgrade || _isJetUpgrade) && {(_pos distance2D _mainBasePos) > 120}) exitWith { ["This upgrade structure can only be built at the MOB."] call _notifyBuilder; };
if (_isHeliUpgrade && {({ typeOf _x isEqualTo _heliClass } count (nearestObjects [_mainBasePos, [_heliClass], 120])) > 0}) exitWith { ["Helicopter Uplink is already built at the MOB."] call _notifyBuilder; };
if (_isJetUpgrade && {({ typeOf _x isEqualTo _jetClass } count (nearestObjects [_mainBasePos, [_jetClass], 120])) > 0}) exitWith { ["Aircraft Control is already built at the MOB."] call _notifyBuilder; };

private _garageBaseInfo = [false, "", "", "", objNull, [0, 0, 0]];
private _garageRejectReason = "";
if (_isGarageUpgrade) then {
    _garageBaseInfo = [_pos] call _resolveGarageBase;
    if !(_garageBaseInfo param [0, false]) then {
        _garageRejectReason = "Virtual Garage can only be built at the MOB or an active FOB.";
    } else {
        private _baseType = _garageBaseInfo param [1, "MOB"];
        private _baseKey = _garageBaseInfo param [2, "MOB"];
        private _baseLabel = _garageBaseInfo param [3, "Garage"];
        private _baseObj = _garageBaseInfo param [4, objNull];
        if (_baseType isEqualTo "FOB") then {
            if (isNull _baseObj) then {
                _garageRejectReason = format ["%1 garage unavailable: terminal missing.", _baseLabel];
            } else {
                if (_baseObj getVariable ["MWF_FOB_IsDamaged", false]) then {
                    _garageRejectReason = format ["%1 garage unavailable: FOB damaged/offline.", _baseLabel];
                } else {
                    if (_baseObj getVariable ["MWF_isUnderAttack", false]) then {
                        _garageRejectReason = format ["%1 garage unavailable: FOB under attack.", _baseLabel];
                    };
                };
            };
        };

        if (_garageRejectReason isEqualTo "") then {
            private _garageRegistry = missionNamespace getVariable ["MWF_GarageRegistry", []];
            private _alreadyRegistered = (_garageRegistry findIf {
                private _garageObj = _x param [0, objNull];
                !isNull _garageObj && {(_garageObj getVariable ["MWF_isVirtualGarage", false])} && {(_garageObj getVariable ["MWF_Garage_BaseKey", ""]) isEqualTo _baseKey}
            }) > -1;
            if (_alreadyRegistered) then { _garageRejectReason = format ["Virtual Garage is already built at %1.", _baseLabel]; };
        };
    };
};
if (_garageRejectReason isNotEqualTo "") exitWith { [_garageRejectReason] call _notifyBuilder; };

private _resolvedPrice = if (_isGarageUpgrade) then { missionNamespace getVariable ["MWF_Economy_Cost_MOB_Garage", 300] } else { [_className] call MWF_fnc_getBuildAssetCost };
if (_resolvedPrice < 0) then { _resolvedPrice = 0; };

private _current = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
if (_current < _resolvedPrice) exitWith {
    private _displayName = getText (configFile >> "CfgVehicles" >> _className >> "displayName");
    if (_displayName isEqualTo "") then { _displayName = _className; };
    [format ["Insufficient supplies to build %1. Required: %2", _displayName, _resolvedPrice]] call _notifyBuilder;
};

private _newValue = (_current - _resolvedPrice) max 0;
private _intel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];
private _notoriety = missionNamespace getVariable ["MWF_res_notoriety", 0];
[_newValue, _intel, _notoriety] call MWF_fnc_syncEconomyState;

private _vehicle = createVehicle [_className, _pos, [], 0, "CAN_COLLIDE"];
_vehicle setDir _dir;
_vehicle setPosATL _pos;

if (_className isEqualTo "B_Slingload_01_Cargo_F") then { [_vehicle] remoteExec ["MWF_fnc_setupFOBAction", 0, true]; };

private _upgradeId = if (_isGarageUpgrade) then { "GARAGE" } else { if (_isHeliUpgrade) then { "HELI" } else { if (_isJetUpgrade) then { "JET" } else { "" } } };
private _upgradeBaseKey = "MOB";
private _upgradeBaseType = "MOB";
private _upgradeBaseLabel = missionNamespace getVariable ["MWF_MOB_Name", "MOB"];
if (_isGarageUpgrade) then {
    _upgradeBaseType = _garageBaseInfo param [1, "MOB"];
    _upgradeBaseKey = _garageBaseInfo param [2, "MOB"];
    _upgradeBaseLabel = _garageBaseInfo param [3, _upgradeBaseLabel];
};

if (_upgradeId isNotEqualTo "") then {
    _vehicle setVariable ["MWF_isPhysicalBaseUpgrade", true, true];
    _vehicle setVariable ["MWF_UpgradeId", _upgradeId, true];
    _vehicle setVariable ["MWF_BaseKey", _upgradeBaseKey, true];
    _vehicle setVariable ["MWF_BaseType", _upgradeBaseType, true];
    _vehicle setVariable ["MWF_BaseLabel", _upgradeBaseLabel, true];
    private _builtRegistry = +(missionNamespace getVariable ["MWF_BuiltUpgradeRegistry", []]);
    _builtRegistry = _builtRegistry select { private _existingObj = _x param [1, objNull]; !isNull _existingObj && {_existingObj != _vehicle} };
    _builtRegistry pushBack [_upgradeId, _vehicle, _className, _upgradeBaseKey, _upgradeBaseType, _upgradeBaseLabel];
    missionNamespace setVariable ["MWF_BuiltUpgradeRegistry", _builtRegistry, true];
};

if (_isGarageUpgrade) then {
    _vehicle setVariable ["MWF_isVirtualGarage", true, true];
    _vehicle allowDamage false;
    ["REGISTER_BUILD", _vehicle, _builder, 0] call MWF_fnc_garageSystem;
    [["BASE UPGRADE ONLINE", "Virtual Garage constructed. Use the garage object on foot within 5 meters."], "success"] remoteExec ["MWF_fnc_showNotification", 0];
};
if (_isHeliUpgrade) then { [["BASE UPGRADE ONLINE", "Helicopter uplink constructed. Helicopters are now available in the vehicle menu."], "success"] remoteExec ["MWF_fnc_showNotification", 0]; };
if (_isJetUpgrade) then { [["BASE UPGRADE ONLINE", "Aircraft control constructed. Planes are now available in the vehicle menu."], "success"] remoteExec ["MWF_fnc_showNotification", 0]; };
if (!isNull _builder) then { [format ["Asset deployed: -%1 Supplies", _resolvedPrice]] remoteExec ["systemChat", owner _builder]; };
diag_log format ["[MWF Build] %1 spawned at %2 for %3 supplies (client hint %4).", _className, _pos, _resolvedPrice, _priceHint];
