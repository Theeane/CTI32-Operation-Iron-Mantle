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

if (_className isEqualTo "") exitWith {};

private _notifyBuilder = {
    params ["_text"];
    if (!isNull _builder) then {
        [_text] remoteExec ["systemChat", owner _builder];
    };
};

private _check = [_className] call MWF_fnc_isBuildAssetAllowed;
if !(_check # 0) exitWith {
    [(_check # 1)] call _notifyBuilder;
};

private _mainBase = missionNamespace getVariable ["MWF_MainBase", missionNamespace getVariable ["MWF_MOB", objNull]];
private _mainBasePos = if (!isNull _mainBase) then { getPosATL _mainBase } else { getMarkerPos "respawn_west" };

private _heliClass = missionNamespace getVariable ["MWF_Heli_Tower_Class", ""];
private _jetClass = missionNamespace getVariable ["MWF_Jet_Control_Class", ""];
private _garageClass = missionNamespace getVariable ["MWF_Virtual_Garage", ""];
private _isHeliUpgrade = (_heliClass isNotEqualTo "") && {_className isEqualTo _heliClass};
private _isJetUpgrade = (_jetClass isNotEqualTo "") && {_className isEqualTo _jetClass};
private _isGarageUpgrade = (_garageClass isNotEqualTo "") && {_className isEqualTo _garageClass};

if (_isHeliUpgrade && {!(missionNamespace getVariable ["MWF_Unlock_Heli", false])}) exitWith {
    ["Helicopter Uplink is locked. Complete Sky Guardian first."] call _notifyBuilder;
};

if (_isJetUpgrade && {!(missionNamespace getVariable ["MWF_Unlock_Jets", false])}) exitWith {
    ["Aircraft Control is locked. Complete Point Blank first."] call _notifyBuilder;
};

private _resolveGarageBase = {
    params ["_garagePos"];
    if (!isNull _mainBase && {_garagePos distance2D _mainBasePos <= 120}) exitWith {
        [true, "MOB", "MOB", missionNamespace getVariable ["MWF_MOB_Name", "MOB"], _mainBase, _mainBasePos]
    };

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

    if (_bestRecord isEqualTo []) then {
        [false, "", "", "", objNull, [0, 0, 0]]
    } else {
        _bestRecord
    }
};

if ((_isHeliUpgrade || _isJetUpgrade) && {(_pos distance2D _mainBasePos) > 120}) exitWith {
    ["This upgrade structure can only be built at the MOB."] call _notifyBuilder;
};

if (_isHeliUpgrade && {({ typeOf _x isEqualTo _heliClass } count (nearestObjects [_mainBasePos, [_heliClass], 120])) > 0}) exitWith {
    ["Helicopter Uplink is already built at the MOB."] call _notifyBuilder;
};

if (_isJetUpgrade && {({ typeOf _x isEqualTo _jetClass } count (nearestObjects [_mainBasePos, [_jetClass], 120])) > 0}) exitWith {
    ["Aircraft Control is already built at the MOB."] call _notifyBuilder;
};

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
        private _basePos = _garageBaseInfo param [5, _mainBasePos];

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
                !isNull _garageObj &&
                {(_garageObj getVariable ["MWF_isVirtualGarage", false])} &&
                {(_garageObj getVariable ["MWF_Garage_BaseKey", ""]) isEqualTo _baseKey}
            }) > -1;

            if (_alreadyRegistered) then {
                _garageRejectReason = format ["Virtual Garage is already built at %1.", _baseLabel];
            };
        };
    };
};

if (_garageRejectReason isNotEqualTo "") exitWith {
    [_garageRejectReason] call _notifyBuilder;
};

private _resolvedPrice = if (_isGarageUpgrade) then {
    missionNamespace getVariable ["MWF_Economy_Cost_MOB_Garage", 300]
} else {
    [_className] call MWF_fnc_getBuildAssetCost
};

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

if (_className isEqualTo "B_Slingload_01_Cargo_F") then {
    [_vehicle] remoteExec ["MWF_fnc_setupFOBAction", 0, true];
};

if (_isGarageUpgrade) then {
    _vehicle setVariable ["MWF_isVirtualGarage", true, true];
    _vehicle allowDamage false;
    ["REGISTER_BUILD", _vehicle, _builder, 0] call MWF_fnc_garageSystem;
    [["BASE UPGRADE ONLINE", "Virtual Garage constructed. Use the garage object on foot within 5 meters."], "success"] remoteExec ["MWF_fnc_showNotification", 0];
};

if (_isHeliUpgrade) then {
    [["BASE UPGRADE ONLINE", "Helicopter uplink constructed. Helicopters are now available in the vehicle menu."], "success"] remoteExec ["MWF_fnc_showNotification", 0];
};

if (_isJetUpgrade) then {
    [["BASE UPGRADE ONLINE", "Aircraft control constructed. Planes are now available in the vehicle menu."], "success"] remoteExec ["MWF_fnc_showNotification", 0];
};

if (!isNull _builder) then {
    [format ["Asset deployed: -%1 Supplies", _resolvedPrice]] remoteExec ["systemChat", owner _builder];
};

diag_log format ["[MWF Build] %1 spawned at %2 for %3 supplies (client hint %4).", _className, _pos, _resolvedPrice, _priceHint];
