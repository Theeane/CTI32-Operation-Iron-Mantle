class Params {
    // --- 1. FACTION SELECTION ---
    class AGS_Param_Blufor {
        title = "BLUFOR Faction (Players)";
        values[] = {0, 1, 99};
        texts[] = {"Vanilla NATO", "RHS US Army", "CUSTOM (Edit custom_factions.sqf)"};
        default = 0;
    };
    class AGS_Param_Opfor {
        title = "OPFOR Faction (Enemy)";
        values[] = {0, 1, 99};
        texts[] = {"Vanilla CSAT", "RHS Russia MSV", "CUSTOM (Edit custom_factions.sqf)"};
        default = 0;
    };
    class AGS_Param_Civs {
        title = "Civilian / Rebel Faction";
        values[] = {0, 1, 99};
        texts[] = {"Vanilla", "RHS", "CUSTOM"};
        default = 0;
    };

    // --- 2. ECONOMY & START ---
    class AGS_Param_StartSupplies {
        title = "Starting Supplies";
        // 200 to 800 (200 increments), and 1100 to skip intro quests
        values[] = {200, 400, 600, 800, 1100};
        texts[] = {"200 (Default)", "400", "600", "800 (Max)", "1100 (Skip Intro)"};
        default = 200;
    };

    // --- 3. VICTORY CONDITIONS ---
    class AGS_Param_VictoryThreshold {
        title = "Victory Condition (Zones Captured)";
        values[] = {50, 75, 100};
        texts[] = {"50% Control", "75% Control (Recommended)", "100% Total Control"};
        default = 75;
    };
    class AGS_Param_HVTObjective {
        title = "HVT Assassination (The Red Beret)";
        values[] = {0, 1};
        texts[] = {"Off", "On (Final Mission)"};
        default = 1;
    };

    // --- 4. GAMEPLAY & LOGISTICS ---
    class AGS_Param_GameMode {
        title = "Game Mode";
        values[] = {0, 1};
        texts[] = {"Standard (Undercover)", "Military (No Undercover)"};
        default = 0;
    };
    class AGS_Param_ZeusAccess {
        title = "Zeus / Command Access";
        values[] = {0, 1, 2};
        texts[] = {
            "Standard (Logistics for everyone)", 
            "Commander (Blufor-only Spawn Menu)", 
            "Full Access (Admin/Game Master)"
        };
        default = 0;
    };
    class AGS_Param_MobileRespawn {
        title = "Mobile Respawn Vehicles";
        values[] = {0, 1};
        texts[] = {"Disabled", "Enabled"};
        default = 1;
    };

    // --- 5. ENVIRONMENT ---
    class AGS_Param_TimeMultiplier {
        title = "Time Acceleration (Day)";
        values[] = {1, 2, 4, 6};
        texts[] = {"1x (Real time)", "2x", "4x", "6x"};
        default = 2;
    };
    class AGS_Param_NightAcceleration {
        title = "Night Time Speed";
        values[] = {1, 4, 8, 12};
        texts[] = {"Same as Day", "4x Faster", "8x Faster", "12x (Short Nights)"};
        default = 4;
    };

    // --- 6. SYSTEM & PERSISTENCE ---
    class AGS_Param_SaveInterval {
        title = "Auto-Save Interval (CBA)";
        values[] = {0, 300, 900, 1800};
        texts[] = {"Disabled", "5 min", "15 min", "30 min"};
        default = 900;
    };
    class AGS_Param_WipeSave {
        title = "WIPE SAVE DATA";
        values[] = {0, 1};
        texts[] = {"No (Keep Progress)", "YES (Delete All Progress)"};
        default = 0;
    };
    class AGS_Param_ConfirmWipe {
        title = "CONFIRM WIPE (Safety)";
        values[] = {0, 1};
        texts[] = {"No Confirmation", "CONFIRMED"};
        default = 0;
    };
    class AGS_Param_DebugMode {
        title = "Debug Mode / Logs";
        values[] = {0, 1};
        texts[] = {"Off", "On (Show Script Messages)"};
        default = 0;
    };
};
