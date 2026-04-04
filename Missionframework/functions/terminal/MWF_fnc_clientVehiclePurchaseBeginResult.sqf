if (!hasInterface) exitWith { false };

params [
    ["_requestId", "", [""]],
    ["_success", false, [false]],
    ["_reservedCost", 0, [0]],
    ["_message", "", [""]]
];

missionNamespace setVariable ["MWF_VehiclePurchaseBegin_Result", [_requestId, _success, _reservedCost, _message]];

if (_message isNotEqualTo "") then {
    systemChat _message;
};

true
