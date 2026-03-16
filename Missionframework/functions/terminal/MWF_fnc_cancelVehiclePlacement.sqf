/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_cancelVehiclePlacement
    Project: Military War Framework

    Description:
    Cancels local vehicle ghost placement without charging the player.
*/

if (!hasInterface) exitWith { false };

[] call MWF_fnc_cleanupVehiclePlacement;
systemChat "Vehicle placement cancelled.";
true
