/*
    Author: Theane / ChatGPT
    Function: fn_applyTutorialReward
    Project: Military War Framework

    Description:
    Applies the fixed tutorial supply-run reward.
    Tutorial should only create minimal threat pressure.
    Completing it undercover grants bonus Intel because OPFOR never connected the action back to the players.
*/

if (!isServer) exitWith {false};

params [
    ["_wasUndercover", false, [false]],
    ["_zoneId", "tutorial", [""]]
];

[100, "SUPPLIES"] call MWF_fnc_addResource;
if (_wasUndercover) then {
    [50, "INTEL"] call MWF_fnc_addResource;
} else {
    ["tutorial_supply_run", _zoneId, 1, "initial_supply_run"] call MWF_fnc_registerThreatIncident;
};

true
