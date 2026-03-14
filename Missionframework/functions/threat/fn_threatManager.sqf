/*
    Author: Theane / ChatGPT
    Function: fn_threatManager
    Project: Military War Framework

    Description:
    Initializes and maintains the threat layer above world progression.
*/

if (!isServer) exitWith {};
if (missionNamespace getVariable ["MWF_ThreatManagerStarted", false]) exitWith {};

missionNamespace setVariable ["MWF_ThreatManagerStarted", true, true];
missionNamespace setVariable ["MWF_ThreatSystemReady", false, true];

[] spawn {
    waitUntil {
        uiSleep 1;
        missionNamespace getVariable ["MWF_WorldSystemReady", false]
    };

    [] call MWF_fnc_recalculateThreatState;
    missionNamespace setVariable ["MWF_ThreatSystemReady", true, true];

    while {true} do {
        uiSleep 30;
        [] call MWF_fnc_recalculateThreatState;
    };
};
