class CfgFunctions {
    class AGS {
        tag = "AGS";
        class Core {
            file = "Missionframework\core";
            class initGlobals { recompile = 1; };
            class scanZones { recompile = 1; };
            class economy { recompile = 1; };
            class zoneCapture { recompile = 1; };
            class notorietyResponse { recompile = 1; };
            class setupInteractions { recompile = 1; };
            class notorietyDecay { recompile = 1; }; // Om vi separerar den
        };
        class UI {
            file = "Missionframework\ui";
            class initUI { recompile = 1; };
            class updateResourceUI { recompile = 1; };
        };
        class Missions {
            file = "Missionframework\missions";
            class generateInitialMission { recompile = 1; };
        };
    };
};
