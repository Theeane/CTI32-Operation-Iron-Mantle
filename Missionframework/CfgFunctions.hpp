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
            class initZones {};          // NY: Startar upp zonerna vid mission start
            class economy {};            // UPPDATERAD: Hanterar inkomst & synk med butik
            class scanZones {};
            class zoneCapture {};        // UPPDATERAD: Ger bonus vid capture
            class zoneManager {};
            class persistence {};
            class undercoverHandler {};
            class setupInteractions {};
            class limitZeusAssets {};
        };

        // --- BASE, BUILDING & LOGISTICS ---
        class Base {
            file = "Missionframework\functions\base";
            class initFOB {};
            class packFOB {};
            class executeRepack {};
            class commanderToggleRepack {};
            class initCommandPC {};      // UPPDATERAD: Inkluderar nu Buy Menu & Strategic Maps
            class updateBuyCategory {};  // NY: Logik för att fylla listan i butiken
            class initiatePurchase {};   // NY: Köp-knappen med Spawn Pad-logik
            class setupFOBAction {};
            class spawnFOBComposition {};
            class startFOBPlacement {};
            class startBuildPlacement {};
            class finalizeBuild {};
            class openBaseArchitect {};
            class buildMode {};
        };

        class UI {
            file = "Missionframework\ui";
            class initUI {};
            class updateResourceUI {};   // NY: Loopen som uppdaterar din HUD/Resource Bar
            class openBuildMenu {};
            class openBuyMenu {};        // NY: Öppnar din nya gråa butiks-meny
            class openCommandMap {};
            class openOpsMap {};         // NY: För din strategiska karta
        };

        class Missions {
            file = "Missionframework\missions";
            class generateInitialMission {};
        };
    };
};
