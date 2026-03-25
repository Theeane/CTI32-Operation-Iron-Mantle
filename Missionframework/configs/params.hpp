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
    - MWF_Param_ThreatGainMultiplier
    - MWF_Param_ThreatDecayMultiplier
    - MWF_Param_WorldTierMultiplier
    - MWF_Param_EndgameMapControl
    - Param_BuildingDamageMode
    - MWF_Param_IncomeMultiplier
    - MWF_Param_MaxFOBs

    All other params remain free to change between server restarts.
*/

class Params {
    class MWF_Param_BluforSource {
        title = "[PERSISTENT] BLUFOR Preset Source";
        values[] = {0, 1};
        texts[] = {"Default", "Custom"};
        default = 0;
    };

    class MWF_Param_Blufor {
        title = "[PERSISTENT] BLUFOR Default Preset";
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
        title = "[PERSISTENT] BLUFOR Custom Preset";
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
        title = "[PERSISTENT] OPFOR Preset Source";
        values[] = {0, 1};
        texts[] = {"Default", "Custom"};
        default = 0;
    };

    class MWF_Param_Opfor {
        title = "[PERSISTENT] OPFOR Default Preset";
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
        title = "[PERSISTENT] OPFOR Custom Preset";
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
        title = "[PERSISTENT] Resistance Preset Source";
        values[] = {0, 1};
        texts[] = {"Default", "Custom"};
        default = 0;
    };

    class MWF_Param_Resistance {
        title = "[PERSISTENT] Resistance Default Preset";
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
        title = "[PERSISTENT] Resistance Custom Preset";
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
        title = "[PERSISTENT] Civilian Preset Source";
        values[] = {0, 1};
        texts[] = {"Default", "Custom"};
        default = 0;
    };

    class MWF_Param_Civs {
        title = "[PERSISTENT] Civilian Default Preset";
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
        title = "[PERSISTENT] Civilian Custom Preset";
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



    class MWF_Param_CompositionType {
        title = "[PERSISTENT] Composition Type";
        values[] = {0, 1, 2, 3};
        texts[] = {
            "Modern",
            "Vietnam",
            "World War 2",
            "Global Mobilization"
        };
        default = 0;
    };

    class MWF_Param_StartSupplies {
        title = "[PERSISTENT] Starting Supplies";
        values[] = {200, 400, 600, 800, 1100};
        texts[] = {"200", "400", "600", "800", "1100"};
        default = 200;
    };

    class MWF_Param_SupplyTimer {
        title = "[PERSISTENT] Supply Delivery Interval";
        values[] = {5, 10, 15, 20, 30};
        texts[] = {"5 min", "10 min", "15 min", "20 min", "30 min"};
        default = 10;
    };

    class MWF_Param_IncomeMultiplier {
        title = "[PERSISTENT] Income Multiplier";
        values[] = {0, 1, 2};
        texts[] = {"Low (0.5x)", "Normal (1.0x)", "High (2.0x)"};
        default = 1;
    };

    class MWF_Param_MaxFOBs {
        title = "[PERSISTENT] Max FOBs";
        values[] = {3, 5, 7, 10};
        texts[] = {"3", "5", "7", "10"};
        default = 5;
    };

    class MWF_Param_InitialFOBType {
        title = "[SESSION ONLY] Initial FOB Asset";
        values[] = {0, 1};
        texts[] = {"Truck", "Box"};
        default = 0;
    };

    class MWF_Param_TimeMultiplier {
        title = "[SESSION ONLY] Time Acceleration";
        values[] = {1, 2, 4, 6, 8, 12, 24};
        texts[] = {"1x", "2x", "4x", "6x", "8x", "12x", "24x"};
        default = 1;
    };

    class MWF_Param_SpawnDistance {
        title = "[SESSION ONLY] AI Spawn Distance";
        values[] = {800, 1000, 1200, 1500, 1800};
        texts[] = {"800 m", "1000 m", "1200 m", "1500 m", "1800 m"};
        default = 1200;
    };

    class MWF_Param_PlayerScalingBracket {
        title = "[SESSION ONLY] Player Scaling";
        values[] = {0, 1, 2, 3};
        texts[] = {
            "1-8 Players (Small Group)",
            "9-16 Players (Medium Group)",
            "17-24 Players (Large Group)",
            "25-32 Players (Full Scale)"
        };
        default = 1;
    };

    class MWF_Param_UnitCap {
        title = "[SESSION ONLY] Dynamic Unit Cap";
        values[] = {50, 80, 100, 120, 150};
        texts[] = {
            "50 (Best Performance)",
            "80 (Light AI Load)",
            "100 (Normal AI Load)",
            "120 (Heavy AI Load)",
            "150 (Very Heavy AI Load - HC Recommended)"
        };
        default = 100;
    };

    class MWF_Param_CivReputation {
        title = "[PERSISTENT] Starting Civilian Reputation";
        values[] = {-50, 0, 25, 50};
        texts[] = {"Hostile", "Neutral", "Friendly", "Respected"};
        default = 0;
    };

    class MWF_Param_ThreatGainMultiplier {
        title = "[PERSISTENT] Threat Tick Up";
        values[] = {0.5, 1, 1.5, 2};
        texts[] = {
            "0.5x - Threat rises slower from combat, captures and missions",
            "1.0x - Standard threat gain",
            "1.5x - Threat rises faster",
            "2.0x - Threat rises much faster"
        };
        default = 1;
    };

    class MWF_Param_ThreatDecayMultiplier {
        title = "[PERSISTENT] Threat Tick Down";
        values[] = {0.5, 1, 1.5, 2};
        texts[] = {
            "0.5x - Threat falls slower over time",
            "1.0x - Standard threat decay",
            "1.5x - Threat falls faster",
            "2.0x - Threat falls much faster"
        };
        default = 1;
    };

    class MWF_Param_WorldTierMultiplier {
        title = "[PERSISTENT] Enemy World Tier Multiplier";
        values[] = {0.5, 1, 1.5, 2};
        texts[] = {
            "0.5x - Weaker OPFOR / rebel content",
            "1.0x - Standard enemy tier",
            "1.5x - Stronger OPFOR / rebel content",
            "2.0x - Much stronger OPFOR / rebel content"
        };
        default = 1;
    };

    class MWF_Param_EndgameMapControl {
        title = "[PERSISTENT] Endgame Map Completion Requirement";
        values[] = {55, 75, 95};
        texts[] = {
            "55% (Early endgame)",
            "75% (Standard)",
            "95% (Late endgame)"
        };
        default = 75;
    };

    class MWF_Param_SaveInterval {
        title = "[SESSION ONLY] Auto Save Interval";
        values[] = {5, 10, 15, 30, 60};
        texts[] = {"5 min", "10 min", "15 min", "30 min", "60 min"};
        default = 15;
    };

    class MWF_Param_BuildingDamageMode {
        title = "[PERSISTENT] Building Damage Mode";
        values[] = {0, 1};
        texts[] = {"Persistent", "Reset on Restart"};
        default = 0;
    };

    class MWF_Param_WipeSave {
        title = "[SESSION ONLY] Wipe Save Data";
        values[] = {0, 1};
        texts[] = {"No", "Yes"};
        default = 0;
    };

    class MWF_Param_ConfirmWipe {
        title = "[SESSION ONLY] Confirm Save Wipe";
        values[] = {0, 1};
        texts[] = {"No", "Yes"};
        default = 0;
    };

    class MWF_Param_DebugMode {
        title = "[SESSION ONLY] Debug Mode";
        values[] = {0, 1};
        texts[] = {"Disabled", "Enabled"};
        default = 0;
    };
};
