/*
    Author: Theane / ChatGPT
    Function: Mission Parameters
    Project: Military War Framework

    Description:
    Defines mission parameters available in the scenario lobby.

    Persistent campaign params:
    - All faction source / preset choices
    - Param_StartSupplies
    - Param_SupplyTimer
    - Param_CivReputation
    - Param_NotorietyMultiplier
    - Param_BuildingDamageMode
    - MWF_Param_IncomeMultiplier
    - MWF_Param_MaxFOBs

    All other params remain free to change between server restarts.
*/

class Params {
    class MWF_Param_BluforSource {
        title = "BLUFOR Preset Source";
        values[] = {0, 1};
        texts[] = {"Default", "Custom"};
        default = 0;
    };

    class MWF_Param_Blufor {
        title = "BLUFOR Default Preset";
        values[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15};
        texts[] = {
            "NATO",
            "NATO Pacific",
            "NATO Woodland",
            "CUP ACR Desert",
            "CUP ACR Woodland",
            "CUP BAF Desert",
            "CUP BAF Woodland",
            "CUP USA Desert",
            "CUP USA Woodland",
            "CUP USMC Desert",
            "GM West Germany",
            "LDF Contact",
            "RHS USAF Desert",
            "RHS USAF Woodland",
            "SOG MACV",
            "Western Sahara BLUFOR Desert"
        };
        default = 0;
    };

    class MWF_Param_CustomBlufor {
        title = "BLUFOR Custom Preset";
        values[] = {1,2,3,4,5,6,7,8,9,10};
        texts[] = {
            "Custom 1",
            "Custom 2",
            "Custom 3",
            "Custom 4",
            "Custom 5",
            "Custom 6",
            "Custom 7",
            "Custom 8",
            "Custom 9",
            "Custom 10"
        };
        default = 1;
    };

    class MWF_Param_OpforSource {
        title = "OPFOR Preset Source";
        values[] = {0, 1};
        texts[] = {"Default", "Custom"};
        default = 0;
    };

    class MWF_Param_Opfor {
        title = "OPFOR Default Preset";
        values[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11};
        texts[] = {
            "CSAT",
            "CSAT Pacific",
            "CUP AFRF EMR",
            "CUP AFRF Modern",
            "CUP CDF",
            "CUP ChDKZ",
            "Contact",
            "GM East Germany",
            "Islamic State",
            "RHS AFRF",
            "Takistan Army",
            "Unsung Vietnam"
        };
        default = 0;
    };

    class MWF_Param_CustomOpfor {
        title = "OPFOR Custom Preset";
        values[] = {1,2,3,4,5,6,7,8,9,10};
        texts[] = {
            "Custom 1",
            "Custom 2",
            "Custom 3",
            "Custom 4",
            "Custom 5",
            "Custom 6",
            "Custom 7",
            "Custom 8",
            "Custom 9",
            "Custom 10"
        };
        default = 1;
    };

    class MWF_Param_ResistanceSource {
        title = "Resistance Preset Source";
        values[] = {0, 1};
        texts[] = {"Default", "Custom"};
        default = 0;
    };

    class MWF_Param_Resistance {
        title = "Resistance Default Preset";
        values[] = {0, 1, 2, 3, 4, 5, 6, 7};
        texts[] = {
            "AAF",
            "CUP NAPA",
            "LDF Resistance",
            "Middle Eastern",
            "RACS",
            "RHS GREF",
            "Syndikat",
            "Vietnam CIDG"
        };
        default = 0;
    };

    class MWF_Param_CustomResistance {
        title = "Resistance Custom Preset";
        values[] = {1,2,3,4,5,6,7,8,9,10};
        texts[] = {
            "Custom 1",
            "Custom 2",
            "Custom 3",
            "Custom 4",
            "Custom 5",
            "Custom 6",
            "Custom 7",
            "Custom 8",
            "Custom 9",
            "Custom 10"
        };
        default = 1;
    };

    class MWF_Param_CivsSource {
        title = "Civilian Preset Source";
        values[] = {0, 1};
        texts[] = {"Default", "Custom"};
        default = 0;
    };

    class MWF_Param_Civs {
        title = "Civilian Default Preset";
        values[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
        texts[] = {
            "Arma 3 Civilians",
            "CUP Chernarus Civilians",
            "CUP Takistan Civilians",
            "Contact Civilians",
            "Eastern European",
            "Global Mobilization",
            "Middle Eastern",
            "RDS Civilians",
            "Tanoa Civilians",
            "Vietnam Unsung"
        };
        default = 0;
    };

    class MWF_Param_CustomCivs {
        title = "Civilian Custom Preset";
        values[] = {1,2,3,4,5,6,7,8,9,10};
        texts[] = {
            "Custom 1",
            "Custom 2",
            "Custom 3",
            "Custom 4",
            "Custom 5",
            "Custom 6",
            "Custom 7",
            "Custom 8",
            "Custom 9",
            "Custom 10"
        };
        default = 1;
    };

    class MWF_Param_StartSupplies {
        title = "Starting Supplies";
        values[] = {200, 400, 600, 800, 1100};
        texts[] = {"200", "400", "600", "800", "1100"};
        default = 200;
    };

    class MWF_Param_SupplyTimer {
        title = "Supply Delivery Interval";
        values[] = {5, 10, 15, 20, 30};
        texts[] = {"5 min", "10 min", "15 min", "20 min", "30 min"};
        default = 10;
    };

    class MWF_Param_IncomeMultiplier {
        title = "Income Multiplier";
        values[] = {0, 1, 2};
        texts[] = {"Low (0.5x)", "Normal (1.0x)", "High (2.0x)"};
        default = 1;
    };

    class MWF_Param_MaxFOBs {
        title = "Max FOBs";
        values[] = {3, 5, 7, 10};
        texts[] = {"3", "5", "7", "10"};
        default = 5;
    };

    class MWF_Param_SideMissionTemplateLimit {
        title = "Side Mission Template Pool";
        values[] = {9, 18, 24, 36, 48, 72, 99};
        texts[] = {"9", "18", "24", "36", "48", "72", "99"};
        default = 24;
    };

    class MWF_Param_InitialFOBType {
        title = "Initial FOB Asset";
        values[] = {0, 1};
        texts[] = {"Truck", "Box"};
        default = 0;
    };

    class MWF_Param_TimeMultiplier {
        title = "Time Acceleration";
        values[] = {1, 2, 4, 6, 8, 12, 24};
        texts[] = {"1x", "2x", "4x", "6x", "8x", "12x", "24x"};
        default = 1;
    };

    class MWF_Param_SpawnDistance {
        title = "AI Spawn Distance";
        values[] = {800, 1000, 1200, 1500, 1800};
        texts[] = {"800 m", "1000 m", "1200 m", "1500 m", "1800 m"};
        default = 1200;
    };

    class MWF_Param_UnitCap {
        title = "Dynamic Unit Cap";
        values[] = {50, 80, 100, 120, 150};
        texts[] = {"50", "80", "100", "120", "150"};
        default = 100;
    };

    class MWF_Param_CivReputation {
        title = "Starting Civilian Reputation";
        values[] = {-50, 0, 25, 50};
        texts[] = {"Hostile", "Neutral", "Friendly", "Respected"};
        default = 0;
    };

    class MWF_Param_NotorietyMultiplier {
        title = "Heat Decay per Tick";
        values[] = {1, 2, 3, 5};
        texts[] = {"1", "2", "3", "5"};
        default = 1;
    };

    class MWF_Param_SaveInterval {
        title = "Auto Save Interval";
        values[] = {5, 10, 15, 30, 60};
        texts[] = {"5 min", "10 min", "15 min", "30 min", "60 min"};
        default = 15;
    };

    class MWF_Param_BuildingDamageMode {
        title = "Building Damage Mode";
        values[] = {0, 1};
        texts[] = {"Persistent", "Reset on Restart"};
        default = 0;
    };

    class MWF_Param_WipeSave {
        title = "Wipe Save Data";
        values[] = {0, 1};
        texts[] = {"No", "Yes"};
        default = 0;
    };

    class MWF_Param_ConfirmWipe {
        title = "Confirm Save Wipe";
        values[] = {0, 1};
        texts[] = {"No", "Yes"};
        default = 0;
    };

    class MWF_Param_DebugMode {
        title = "Debug Mode";
        values[] = {0, 1};
        texts[] = {"Disabled", "Enabled"};
        default = 0;
    };
};
