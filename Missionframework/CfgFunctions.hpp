/*
    Author: Theeane / Gemini
    Description: Function definitions for the AGS Mission Framework.
    Language: English
*/

class CfgFunctions {
    class AGS {
        tag = "AGS";

        class Core {
            file = "Missionframework\core";
            class initGlobals {};
            class initSystems {};
            class economy {};
            class scanZones {};
            class zoneCapture {};
            class zoneManager {};
            class setupInteractions {};
            class setupFOBAction {};
            class spawnFOBComposition {};
            class startFOBPlacement {};
            class startBuildPlacement {};
            class finalizeBuild {};
            class openBaseArchitect {};
            class limitZeusAssets {};
            class persistence {};
            class undercoverHandler {};
            class buildMode {};
        };

        // --- NEW: BASE & LOGISTICS ---
        class Base {
            file = "Missionframework\functions\base";
            class initFOB {};
            class packFOB {};
            class executeRepack {};
            class commanderToggleRepack {};
            class initCommandPC {};
            class updateBuyCategory {};  // Logic for the Buy Menu list
            class initiatePurchase {};   // Logic for buying units/vehicles
        };

        class UI {
            file = "Missionframework\ui";
            class initUI {};
            class updateResourceUI {};
            class openBuildMenu {};
            class openBuyMenu {};        // Opens our new Grey/English menu
            class openCommandMap {};     // The Commander's overview map
        };

        class Missions {
            file = "Missionframework\missions";
            class generateInitialMission {};
        };
    };
};
