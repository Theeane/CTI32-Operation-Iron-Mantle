class CfgFunctions {
    class AGS {
        tag = "AGS";
        
        class Core {
            file = "Missionframework\core";
            class initGlobals {};
            class scanZones {};
            class economy {};
            class zoneCapture {};
            class setupInteractions {};
            class setupFOBInteractions {}; // For the FOB terminal
            class setupFOBAction {};       // For the FOB container
            class startFOBPlacement {};    // The Ghost Preview
            class spawnFOBComposition {};  // The Global Spawning
            class openBaseArchitect {};    // Zeus Mode
        };

        class UI {
            file = "Missionframework\ui";
            class initUI {};
            class updateResourceUI {};
            class openBuildMenu {};        // The Build Menu UI
        };

        class Missions {
            file = "Missionframework\missions";
            class generateInitialMission {};
        };
    };
};
