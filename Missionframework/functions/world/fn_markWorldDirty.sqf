/*
    Author: Theane / ChatGPT
    Function: fn_markWorldDirty
    Project: Military War Framework

    Description:
    Marks the world progression layer as dirty so the world manager can
    recalculate safely on the next cycle.
*/

if (!isServer) exitWith {false};

params [
    ["_reason", "unspecified", [""]]
];

missionNamespace setVariable ["MWF_WorldStateDirty", true, false];
missionNamespace setVariable ["MWF_WorldDirtyReason", _reason, false];

true
