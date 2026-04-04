params [
    ["_buyer", objNull, [objNull]],
    ["_requestId", "", [""]],
    ["_reason", "", [""]]
];

if (!isServer) exitWith { false };

private _ownerId = if (isNull _buyer) then { remoteExecutedOwner } else { owner _buyer };
private _sessionKey = format ["MWF_PendingVehiclePurchase_%1", _ownerId];
private _session = missionNamespace getVariable [_sessionKey, []];
if ((count _session) < 3) exitWith { false };

private _storedRequestId = _session param [0, "", [""]];
if (_requestId isNotEqualTo "" && {_storedRequestId isNotEqualTo _requestId}) exitWith { false };

private _reservedCost = _session param [2, 0, [0]];
missionNamespace setVariable [_sessionKey, nil, false];

private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
private _intel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];
private _notoriety = missionNamespace getVariable ["MWF_res_notoriety", 0];
private _newSupplies = _supplies + _reservedCost;

if (!isNil "MWF_fnc_syncEconomyState") then {
    [_newSupplies, _intel, _notoriety] call MWF_fnc_syncEconomyState;
} else {
    missionNamespace setVariable ["MWF_Economy_Supplies", _newSupplies, true];
    missionNamespace setVariable ["MWF_Supplies", _newSupplies, true];
    missionNamespace setVariable ["MWF_Supply", _newSupplies, true];
    missionNamespace setVariable ["MWF_Currency", _newSupplies + _intel, true];
    remoteExec ["MWF_fnc_updateResourceUI", -2];
};

true
