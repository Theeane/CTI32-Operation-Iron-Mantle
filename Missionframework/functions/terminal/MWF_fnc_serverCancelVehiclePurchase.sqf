params [
    ["_buyer", objNull, [objNull]],
    ["_requestId", "", [""]],
    ["_reason", "", [""]]
];

if (!isServer) exitWith { false };

private _ownerId = if (isNull _buyer) then { remoteExecutedOwner } else { owner _buyer };
private _buyerName = if (isNull _buyer) then { format ["owner_%1", _ownerId] } else { name _buyer };
private _sessionKey = format ["MWF_PendingVehiclePurchase_%1", _ownerId];

private _dbg = {
    params ["_message", ["_notifyBuyer", false, [false]]];
    private _line = format ["[MWF VEHICLE DBG][CANCEL][owner:%1][buyer:%2][req:%3] %4", _ownerId, _buyerName, _requestId, _message];
    diag_log _line;
    missionNamespace setVariable ["MWF_VehiclePurchase_LastDebug", _line, true];
    if (_notifyBuyer) then {
        [_line] remoteExecCall ["systemChat", _ownerId];
    };
};

[format ["received cancel request reason=%1", _reason], true] call _dbg;

private _session = missionNamespace getVariable [_sessionKey, []];
if ((count _session) < 3) exitWith {
    ["no pending session found", true] call _dbg;
    false
};

private _storedRequestId = _session param [0, "", [""]];
if (_requestId isNotEqualTo "" && {_storedRequestId isNotEqualTo _requestId}) exitWith {
    [format ["request mismatch stored=%1", _storedRequestId], true] call _dbg;
    false
};

private _reservedCost = _session param [2, 0, [0]];
missionNamespace setVariable [_sessionKey, nil, false];

private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
private _intel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];
private _notoriety = missionNamespace getVariable ["MWF_res_notoriety", 0];
private _newSupplies = _supplies + _reservedCost;

[format ["before refund supplies=%1 reservedCost=%2 newSupplies=%3", _supplies, _reservedCost, _newSupplies], true] call _dbg;

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
[format ["after refund supplies=%1", _suppliesAfter], true] call _dbg;

true
