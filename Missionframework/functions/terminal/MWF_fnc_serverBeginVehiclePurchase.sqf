params [
    ["_buyer", objNull, [objNull]],
    ["_requestId", "", [""]],
    ["_className", "", [""]],
    ["_cost", 0, [0]],
    ["_minTier", 1, [0]],
    ["_requiredUnlock", "", [""]],
    ["_isTier5", false, [false]]
];

if (!isServer) exitWith { false };
if (_requestId isEqualTo "" || {_className isEqualTo ""}) exitWith { false };

private _ownerId = if (isNull _buyer) then { remoteExecutedOwner } else { owner _buyer };
private _sessionKey = format ["MWF_PendingVehiclePurchase_%1", _ownerId];
private _buyerName = if (isNull _buyer) then { format ["owner_%1", _ownerId] } else { name _buyer };

private _dbg = {
    params ["_message", ["_notifyBuyer", false, [false]]];
    private _line = format ["[MWF VEHICLE DBG][BEGIN][owner:%1][buyer:%2][req:%3][class:%4] %5", _ownerId, _buyerName, _requestId, _className, _message];
    diag_log _line;
    missionNamespace setVariable ["MWF_VehiclePurchase_LastDebug", _line, true];
    if (_notifyBuyer && {missionNamespace getVariable ["MWF_DebugMode", false]}) then {
        [_line] remoteExecCall ["systemChat", _ownerId];
    };
};

private _sendResult = {
    params ["_success", "_reservedCost", "_message"];
    [_requestId, _success, _reservedCost, _message] remoteExecCall ["MWF_fnc_clientVehiclePurchaseBeginResult", _ownerId];
};

["received begin request", true] call _dbg;

private _existing = missionNamespace getVariable [_sessionKey, []];
if ((count _existing) > 0) exitWith {
    [format ["blocked: pending session already exists %1", _existing], true] call _dbg;
    [false, 0, "Vehicle purchase blocked. Cancel current placement first."] call _sendResult;
    false
};

private _currentTier = missionNamespace getVariable ["MWF_CurrentTier", 1];
private _mainBase = missionNamespace getVariable ["MWF_MainBase", missionNamespace getVariable ["MWF_MOB", objNull]];
private _mobPos = if (!isNull _mainBase) then { getPosATL _mainBase } else { getMarkerPos "respawn_west" };
private _hasRequiredUpgradeStructure = {
    params [["_requiredUnlockLocal", "", [""]]];
    private _structureClass = switch (toUpper _requiredUnlockLocal) do {
        case "HELI": { missionNamespace getVariable ["MWF_Heli_Tower_Class", ""] };
        case "JETS": { missionNamespace getVariable ["MWF_Jet_Control_Class", ""] };
        default { "" };
    };
    if (_structureClass isEqualTo "") exitWith { false };
    ({ typeOf _x isEqualTo _structureClass } count (nearestObjects [_mobPos, [_structureClass], 120])) > 0
};

private _unlockSatisfied = switch (toUpper _requiredUnlock) do {
    case "HELI": { ["HELI"] call MWF_fnc_hasProgressionAccess };
    case "JETS": { ["JETS"] call MWF_fnc_hasProgressionAccess };
    case "ARMOR": { ["ARMOR"] call MWF_fnc_hasProgressionAccess };
    default { true };
};
if !(_unlockSatisfied) exitWith {
    ["failed unlock gate", true] call _dbg;
    [false, 0, format ["Vehicle purchase failed. %1 unlock required.", if (_requiredUnlock isEqualTo "") then {"category"} else {_requiredUnlock}]] call _sendResult;
    false
};

if (_isTier5 && { !(["TIER5"] call MWF_fnc_hasProgressionAccess) }) exitWith {
    ["failed tier5 gate", true] call _dbg;
    [false, 0, "Vehicle purchase failed. Complete Apex Predator first."] call _sendResult;
    false
};

if ((toUpper _requiredUnlock) in ["HELI", "JETS"] && { !([_requiredUnlock] call _hasRequiredUpgradeStructure) }) exitWith {
    [format ["failed structure gate requiredUnlock=%1", _requiredUnlock], true] call _dbg;
    [false, 0, format ["Vehicle purchase failed. Build the %1 structure at the MOB first.", if ((toUpper _requiredUnlock) isEqualTo "HELI") then {"Helicopter Uplink"} else {"Aircraft Control"}]] call _sendResult;
    false
};

if (_currentTier < _minTier) exitWith {
    [format ["failed tier gate currentTier=%1 required=%2", _currentTier, _minTier], true] call _dbg;
    [false, 0, format ["Vehicle purchase failed. Tier %1 required.", _minTier]] call _sendResult;
    false
};

private _reservedCost = _cost;
if ((toUpper _requiredUnlock) isEqualTo "HELI") then {
    private _discount = missionNamespace getVariable ["MWF_Perk_HeliDiscount", 1];
    if (_discount < 1) then {
        _reservedCost = round ((_reservedCost * _discount) max 1);
    };
};

private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
if (_supplies < _reservedCost) exitWith {
    [format ["failed economy gate suppliesBefore=%1 reservedCost=%2", _supplies, _reservedCost], true] call _dbg;
    [false, 0, format ["Vehicle purchase failed. Need %1 supplies.", _reservedCost]] call _sendResult;
    false
};

private _intel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];
private _notoriety = missionNamespace getVariable ["MWF_res_notoriety", 0];
private _newSupplies = (_supplies - _reservedCost) max 0;

[format ["before debit supplies=%1 intel=%2 notoriety=%3 cost=%4 newSupplies=%5", _supplies, _intel, _notoriety, _reservedCost, _newSupplies], true] call _dbg;

if (!isNil "MWF_fnc_syncEconomyState") then {
    [_newSupplies, _intel, _notoriety] call MWF_fnc_syncEconomyState;
} else {
    missionNamespace setVariable ["MWF_Economy_Supplies", _newSupplies, true];
    missionNamespace setVariable ["MWF_Supplies", _newSupplies, true];
    missionNamespace setVariable ["MWF_Supply", _newSupplies, true];
    missionNamespace setVariable ["MWF_Currency", _newSupplies + _intel, true];
    remoteExec ["MWF_fnc_updateResourceUI", -2];
};

private _suppliesAfter = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", -999]];
[format ["after debit supplies=%1", _suppliesAfter], true] call _dbg;

missionNamespace setVariable [_sessionKey, [_requestId, _className, _reservedCost, _minTier, _requiredUnlock, _isTier5, serverTime], false];
[format ["session stored key=%1", _sessionKey], true] call _dbg;
[true, _reservedCost, ""] call _sendResult;
true
