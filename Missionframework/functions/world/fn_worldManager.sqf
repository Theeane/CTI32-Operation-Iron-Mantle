/*
    Author: Theane / ChatGPT
    Function: fn_worldManager
    Project: Military War Framework

    Description:
    Initializes and maintains the world progression layer.
    This system sits above zones and exposes stable outputs for threat and mission systems.
*/

if (!isServer) exitWith {};
if (missionNamespace getVariable ["MWF_WorldManagerStarted", false]) exitWith {};

missionNamespace setVariable ["MWF_WorldManagerStarted", true, true];
missionNamespace setVariable ["MWF_WorldSystemReady", false, true];

[] spawn {
    waitUntil {
        uiSleep 1;
        missionNamespace getVariable ["MWF_ZoneSystemReady", false]
    };

    [] call MWF_fnc_recalculateWorldState;
    missionNamespace setVariable ["MWF_WorldSystemReady", true, true];

    while {true} do {
        uiSleep 30;
        [] call MWF_fnc_recalculateWorldState;
    };
};
