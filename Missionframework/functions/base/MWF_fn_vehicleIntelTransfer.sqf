/*
    Author: OpenAI / ChatGPT
    Function: MWF_fnc_vehicleIntelTransfer
    Project: Military War Framework

    Description:
    Server-authoritative temporary-intel storage handler for MRU vehicles.
    Vehicles only cache temporary intel; nothing is banked or rolled here.

    Modes:
    - STORE    : move the caller's carried intel into the MRU cache
    - WITHDRAW : move the MRU cache back onto the caller
*/

params [
    ["_mode", "STORE", [""]],
    ["_vehicle", objNull, [objNull]],
    ["_caller", objNull, [objNull]]
];

if (!isServer) exitWith {
    [_mode, _vehicle, _caller] remoteExecCall ["MWF_fnc_vehicleIntelTransfer", 2];
    false
};

if (isNull _vehicle || {isNull _caller}) exitWith { false };
if !(alive _caller) exitWith { false };
if !(alive _vehicle) exitWith { false };
if !(_vehicle getVariable ["MWF_isMobileRespawn", false]) exitWith { false };
if ((_caller distance _vehicle) > 8) exitWith {
    [["TEMP INTEL", "You must be next to the Mobile Respawn Unit to transfer intel."], "warning"] remoteExecCall ["MWF_fnc_showNotification", owner _caller];
    false
};
if !(vehicle _caller isEqualTo _caller) exitWith {
    [["TEMP INTEL", "Exit the vehicle before transferring temporary intel."], "warning"] remoteExecCall ["MWF_fnc_showNotification", owner _caller];
    false
};

private _modeUpper = toUpper _mode;
private _displayName = _vehicle getVariable ["MWF_MRU_DisplayName", "Mobile Respawn Unit"];
private _storedIntel = _vehicle getVariable ["MWF_StoredIntelValue", 0];
private _carriedIntel = _caller getVariable ["MWF_carriedIntelValue", 0];

switch (_modeUpper) do {
    case "STORE": {
        if (_carriedIntel <= 0) exitWith {
            [["TEMP INTEL", "You are not carrying any temporary intel to store."], "warning"] remoteExecCall ["MWF_fnc_showNotification", owner _caller];
            false
        };

        _vehicle setVariable ["MWF_StoredIntelValue", _storedIntel + _carriedIntel, true];
        _caller setVariable ["MWF_carriedIntelValue", 0, true];
        _caller setVariable ["MWF_carryingIntel", false, true];

        [
            [
                "TEMP INTEL STORED",
                format ["Stored %1 temporary intel in %2. Vehicle cache: %3.", _carriedIntel, _displayName, _vehicle getVariable ["MWF_StoredIntelValue", 0]]
            ],
            "info"
        ] remoteExecCall ["MWF_fnc_showNotification", owner _caller];

        true
    };

    case "WITHDRAW": {
        if (_storedIntel <= 0) exitWith {
            [["TEMP INTEL", format ["%1 is not holding any temporary intel.", _displayName]], "warning"] remoteExecCall ["MWF_fnc_showNotification", owner _caller];
            false
        };

        _caller setVariable ["MWF_carriedIntelValue", _carriedIntel + _storedIntel, true];
        _caller setVariable ["MWF_carryingIntel", ((_carriedIntel + _storedIntel) > 0), true];
        _vehicle setVariable ["MWF_StoredIntelValue", 0, true];

        [
            [
                "TEMP INTEL RETRIEVED",
                format ["Recovered %1 temporary intel from %2. You are now carrying %3.", _storedIntel, _displayName, _caller getVariable ["MWF_carriedIntelValue", 0]]
            ],
            "info"
        ] remoteExecCall ["MWF_fnc_showNotification", owner _caller];

        true
    };

    default { false };
};
