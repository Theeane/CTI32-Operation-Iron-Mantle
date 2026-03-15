/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_markThreatDirty
    Project: Military War Framework

    Description:
    Marks the threat layer as dirty so the threat manager can recalculate safely 
    on the next cycle.
    Strict migration from original fn_markThreatDirty.sqf.
*/

if (!isServer) exitWith {false};

params [
    ["_reason", "unspecified", [""]]
];

missionNamespace setVariable ["MWF_ThreatStateDirty", true, false];
missionNamespace setVariable ["MWF_ThreatDirtyReason", _reason, false];

true
