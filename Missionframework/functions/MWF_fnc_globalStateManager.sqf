/*
    Author: OpenAI / repaired from patch
    Project: Military War Framework
    Description:
    Handles global mission state, economy initialization, safe fallback defaults,
    and disruption logic.
*/

params [["_mode", "INIT", [""]]];
private _modeUpper = toUpper _mode;

if (_modeUpper isEqualTo "INIT") exitWith {
    if (!isServer) exitWith { false };

    if (isNil "MWF_Global_Aggression") then { MWF_Global_Aggression = 1.0; };
    if (isNil "MWF_Global_PatrolDensity") then { MWF_Global_PatrolDensity = 1.0; };

    if (isNil "MWF_Economy_Supplies") then { MWF_Economy_Supplies = 1000; };
    if (isNil "MWF_res_intel") then { MWF_res_intel = 0; };

    if (isNil "MWF_CompletedMainOperations") then { MWF_CompletedMainOperations = []; };
    if (isNil "MWF_ActiveSideQuests") then { MWF_ActiveSideQuests = []; };
    if (isNil "MWF_FOB_Registry") then { missionNamespace setVariable ["MWF_FOB_Registry", [], true]; };

    if (isNil { missionNamespace getVariable "MWF_MOB_Name" }) then { missionNamespace setVariable ["MWF_MOB_Name", "Main Operating Base", true]; };
    if (isNil { missionNamespace getVariable "MWF_FOB_Truck" }) then { missionNamespace setVariable ["MWF_FOB_Truck", "B_Truck_01_box_F", true]; };
    if (isNil { missionNamespace getVariable "MWF_FOB_Box" }) then { missionNamespace setVariable ["MWF_FOB_Box", "B_Slingload_01_Cargo_F", true]; };
    if (isNil { missionNamespace getVariable "MWF_FOB_Asset_Table" }) then { missionNamespace setVariable ["MWF_FOB_Asset_Table", "Land_CampingTable_small_F", true]; };
    if (isNil { missionNamespace getVariable "MWF_FOB_Asset_Terminal" }) then { missionNamespace setVariable ["MWF_FOB_Asset_Terminal", "Land_Laptop_unfolded_F", true]; };
    if (isNil { missionNamespace getVariable "MWF_FOB_Asset_Siren" }) then { missionNamespace setVariable ["MWF_FOB_Asset_Siren", "Land_Loudspeakers_F", true]; };
    if (isNil { missionNamespace getVariable "MWF_FOB_Asset_Locker" }) then { missionNamespace setVariable ["MWF_FOB_Asset_Locker", "Prop_Locker_01_F", true]; };

    missionNamespace setVariable ["MWF_ServerInitialized", true, true];
    missionNamespace setVariable ["MWF_ServerBootStage", "CRITICAL_RELEASED", true];

    publicVariable "MWF_Global_Aggression";
    publicVariable "MWF_Global_PatrolDensity";
    publicVariable "MWF_Economy_Supplies";
    publicVariable "MWF_res_intel";

    diag_log "[MWF] Global State Manager: Initialization complete and broadcasted.";
    true
};

if (_modeUpper isEqualTo "DISRUPT") exitWith {
    [] spawn {
        MWF_Global_Aggression = 0.7;
        MWF_Global_PatrolDensity = 0.5;
        publicVariable "MWF_Global_Aggression";
        publicVariable "MWF_Global_PatrolDensity";

        uiSleep 900;

        MWF_Global_Aggression = 1.0;
        MWF_Global_PatrolDensity = 1.0;
        publicVariable "MWF_Global_Aggression";
        publicVariable "MWF_Global_PatrolDensity";
    };
    true
};

false
