/*
    Author: Theeane / Gemini
    Description: Mission parameters for Operation Iron Mantle.
    Covers all presets: Blufor, Opfor, Resistance, and Civilians.
*/

// --- 1. BLUFOR PRESETS ---
class AGS_Param_Blufor {
    title = "BLUFOR Faction (Players)";
    values[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 99};
    texts[] = {
        "Vanilla NATO", "NATO Pacific", "CUP ACR (Desert)", "CUP ACR (Woodland)", 
        "CUP BAF (Desert)", "CUP BAF (Woodland)", "CUP USA (Desert)", "CUP USA (Woodland)", 
        "CUP USMC (Desert)", "GM West Germany", "LDF Contact", "RHS USAF Desert", "CUSTOM"
    };
    default = 0;
};

// --- 2. OPFOR PRESETS ---
class AGS_Param_Opfor {
    title = "OPFOR Faction (Enemy)";
    values[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 99};
    texts[] = {
        "Vanilla CSAT", "CSAT Pacific", "CUP AFRF EMR", "CUP AFRF Modern", 
        "CUP CDF", "CUP ChDKZ", "Contact", "GM East Germany", 
        "Islamic State", "RHS AFRF", "Takistan Army", "Unsung Vietnam", "CUSTOM"
    };
    default = 0;
};

// --- 3. RESISTANCE PRESETS ---
class AGS_Param_Resistance {
    title = "Resistance Faction (Independent)";
    values[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 99};
    texts[] = {
        "Vanilla AAF", "CUP NAPA", "LDF Resistance", "Middle Eastern", 
        "RACS", "RHS GREF", "Syndikat", "Vietnam CIDG", "CUSTOM"
    };
    default = 0;
};

// --- 4. CIVILIAN PRESETS ---
class AGS_Param_Civs {
    title = "Civilian Faction";
    values[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 99};
    texts[] = {
        "Arma 3 Civ", "CUP Cherno", "CUP Taki", "Contact", 
        "Eastern European", "Global Mobilization", "Middle Eastern", 
        "RDSCiv", "Tanoa", "Vietnam Unsung", "CUSTOM"
    };
    default = 0;
};

// --- 5. ECONOMY & SYSTEM ---
class AGS_Param_SupplyTimer {
    title = "Supply Delivery Interval (Minutes)";
    values[] = {5, 10, 15, 20, 30};
    texts[] = {"5 min", "10 min", "15 min", "20 min", "30 min"};
    default = 10;
};

class AGS_Param_StartSupplies {
    title = "Starting Supplies";
    values[] = {200, 400, 600, 800, 1100};
    texts[] = {"200", "400", "600", "800", "1100 (Skip Intro)"};
    default = 200;
};

class AGS_Param_DebugMode {
    title = "Debug Mode / Logs";
    values[] = {0, 1};
    texts[] = {"Off", "On"};
    default = 0;
};
