/*
    Author: Theeane / Gemini
    Description: Full Mission Parameters for Operation Iron Mantle.
    Reflects the finalized BLUFOR preset list as of 2026-03-12.
*/

class Params {
    // --- 1. BLUFOR PRESETS (Players) ---
    class AGS_Param_Blufor {
        title = "BLUFOR Faction (Players)";
        values[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 99};
        texts[] = {
            "NATO (MTP - Full DLC Support)",        // 0
            "NATO Pacific (Apex)",                  // 1
            "NATO Woodland (Contact)",              // 2
            "BW Mod (Desert)",                      // 3
            "BW Mod (Woodland)",                    // 4
            "CUP BAF (Desert)",                     // 5
            "CUP BAF (Woodland)",                   // 6
            "CUP USMC (Desert)",                    // 7
            "CUP USMC (Woodland)",                  // 8
            "GM West Germany",                      // 9
            "LDF Contact",                          // 10
            "RHS USAF Desert",                      // 11
            "RHS USAF Woodland",                    // 12
            "SOG MACV (SOG PF + Unsung)",           // 13
            "USMC Desert (RHS)",                    // 14
            "Western Sahara BLUFOR (Desert)",       // 15
            "CUSTOM (Template)"                     // 99
        };
        default = 0;
    };

    // --- 2. OPFOR PRESETS (Enemy) ---
    class AGS_Param_Opfor {
        title = "OPFOR Faction (Enemy)";
        values[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 99};
        texts[] = {
            "Vanilla CSAT",                         // 0
            "CSAT Pacific",                         // 1
            "CUP AFRF EMR",                         // 2
            "CUP AFRF Modern",                      // 3
            "CUP CDF",                              // 4
            "CUP ChDKZ",                            // 5
            "Contact (EAF)",                        // 6
            "GM East Germany",                      // 7
            "Islamic State",                        // 8
            "RHS AFRF",                             // 9
            "Takistan Army",                        // 10
            "Unsung Vietnam",                       // 11
            "CUSTOM"                                // 99
        };
        default = 0;
    };

    // --- 3. ECONOMY & LOGISTICS ---
    class AGS_Param_SupplyTimer {
        title = "Supply Delivery Interval (Minutes)";
        values[] = {5, 10, 15, 20, 30};
        texts[] = {"5 min", "10 min", "15 min", "20 min", "30 min"};
        default = 10;
    };

    class AGS_Param_StartSupplies {
        title = "Starting Supplies (Digital S)";
        values[] = {200, 400, 600, 800, 1100};
        texts[] = {"200", "400", "600", "800", "1100 (Skip Intro)"};
        default = 200;
    };

    // --- 4. TIME & WEATHER ---
    class AGS_Param_DayDuration {
        title = "Day Time Duration";
        values[] = {0.5, 1, 2, 4, 6, 8, 12};
        texts[] = {"0.5h", "1h", "2h", "4h", "6h", "8h", "12h"};
        default = 4;
    };

    class AGS_Param_TimeMultiplier {
        title = "Time Acceleration";
        values[] = {1, 2, 4, 6, 8, 12, 24};
        texts[] = {"1x", "2x", "4x", "6x", "8x", "12x", "24x"};
        default = 1;
    };

    // --- 5. AI & UNIT MANAGEMENT ---
    class AGS_Param_UnitCap {
        title = "Dynamic Unit Cap (Per Side)";
        values[] = {50, 80, 100, 120, 150};
        texts[] = {"50 (Low Perf)", "80", "100 (Recommended)", "120", "150 (High Perf)"};
        default = 100;
    };

    class AGS_Param_CivReputation {
        title = "Starting Civilian Reputation";
        values[] = {-50, 0, 25, 50};
        texts[] = {"Hostile (-50)", "Neutral (0)", "Friendly (25)", "Respected (50)"};
        default = 0;
    };

    // --- 6. TECHNICAL & DEBUG ---
    class AGS_Param_DebugMode {
        title = "Debug Mode / 'The Clean Slate' Logic";
        values[] = {0, 1};
        texts[] = {"Disabled", "Enabled (Active Logs)"};
        default = 0;
    };

    class AGS_Param_SaveInterval {
        title = "Auto-Save Interval (Minutes)";
        values[] = {5, 10, 15, 30, 60};
        texts[] = {"5 min", "10 min", "15 min", "30 min", "60 min"};
        default = 15;
    };
};
