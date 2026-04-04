if (!hasInterface) exitWith { false };

params [
    ["_requestId", "", [""]],
    ["_success", false, [false]],
    ["_reservedCost", 0, [0]],
    ["_message", "", [""]]
];

missionNamespace setVariable ["MWF_VehiclePurchaseBegin_Result", [_requestId, _success, _reservedCost, _message]];

private _line = format ["[MWF VEHICLE DBG][CLIENT_BEGIN][req:%1] success=%2 reservedCost=%3 message=%4", _requestId, _success, _reservedCost, _message];
diag_log _line;
missionNamespace setVariable ["MWF_VehiclePurchase_LastClientDebug", _line];

if (_message isNotEqualTo "") then {
    systemChat _message;
};

if (_success) then {
    systemChat format ["[MWF DBG] Purchase reserved. Cost=%1", _reservedCost];
};

true
