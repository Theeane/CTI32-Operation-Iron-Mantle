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
            class setupFOBInteractions {};
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
            class openBuildZeus {}; // Kept if you chose the Admin option
        };

        class UI {
            file = "Missionframework\ui";
            class initUI {};
            class updateResourceUI {};
            class openBuildMenu {};
        };

        class Missions {
            file = "Missionframework\missions";
            class generateInitialMission {};
        };
    };
};
