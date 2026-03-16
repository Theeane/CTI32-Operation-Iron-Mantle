/*
    Legacy compatibility purchase helper.
    Redirects old Supply/Intel references to the authoritative missionNamespace economy.
*/

params [
    ["_cost", 0, [0]],
    ["_currencyType", "Supply", [""]]
];

private _normalized = toUpper _currencyType;

switch (_normalized) do {
    case "SUPPLY";
    case "SUPPLIES": {
        private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
        if (_supplies >= _cost) then {
            _supplies = _supplies - _cost;
            missionNamespace setVariable ["MWF_Economy_Supplies", _supplies, true];
            missionNamespace setVariable ["MWF_Supplies", _supplies, true];
            missionNamespace setVariable ["MWF_Supply", _supplies, true];
            missionNamespace setVariable ["MWF_Currency", _supplies + (missionNamespace getVariable ["MWF_res_intel", 0]), true];
            true
        } else {
            false
        };
    };

    case "INTEL": {
        private _intel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];
        if (_intel >= _cost) then {
            _intel = _intel - _cost;
            missionNamespace setVariable ["MWF_res_intel", _intel, true];
            missionNamespace setVariable ["MWF_Intel", _intel, true];
            missionNamespace setVariable ["MWF_Currency", (missionNamespace getVariable ["MWF_Economy_Supplies", 0]) + _intel, true];
            true
        } else {
            false
        };
    };

    default {
        false
    };
};
