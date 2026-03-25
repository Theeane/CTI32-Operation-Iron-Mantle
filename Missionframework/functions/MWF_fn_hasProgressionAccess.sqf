/*
    Author: OpenAI / ChatGPT
    Function: MWF_fn_hasProgressionAccess
    Project: Military War Framework

    Description:
    Resolves whether a main-operation-gated progression unlock should be treated as available.
    In debug mode, progression gates are bypassed for testing, but the real unlock variables remain
    untouched so completing the related main operation still produces the normal unlock feedback.

    Params:
    0: STRING - unlock key (HELI, JETS, ARMOR, TIER5)

    Returns:
    BOOL - true if the unlock is really earned or temporarily available through debug mode
*/

params [
    ["_unlockKey", "", [""]]
];

private _key = toUpper _unlockKey;
if (_key isEqualTo "") exitWith { false };

private _realUnlocked = switch (_key) do {
    case "HELI": { missionNamespace getVariable ["MWF_Unlock_Heli", false] };
    case "JETS": { missionNamespace getVariable ["MWF_Unlock_Jets", false] };
    case "ARMOR": { missionNamespace getVariable ["MWF_Unlock_Armor", false] };
    case "TIER5": { missionNamespace getVariable ["MWF_Unlock_Tier5", false] };
    default { false };
};

if (_realUnlocked) exitWith { true };

(missionNamespace getVariable ["MWF_DebugMode", false]) && { _key in ["HELI", "JETS", "ARMOR", "TIER5"] }
