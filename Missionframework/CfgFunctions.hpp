/*
    Author: Theane / ChatGPT
    Function: CfgFunctions Registration
    Project: Military War Framework

    Description:
    Registers mission functions that are currently used by the framework startup and core gameplay flow.
*/

class CfgFunctions {
    class MWF {
        tag = "MWF";

        class Core {
            file = "core";
            class buildMode {};
            class economy {};
            class finalizeBuild {};
            class initGlobals {};
            class initSystems {};
            class initZones {};
            class limitZeusAssets {};
            class openBaseArchitect {};
            class openBuildZeus {};
            class scanZones {};
            class setupFOBAction {};
            class setupFOBInteractions {};
            class setupInteractions {};
            class spawnFOBComposition {};
            class startBuildPlacement {};
            class startFOBPlacement {};
            class undercoverHandler {};
            class zoneCapture {};
            class zoneManager {};
        };

        class Base {
            file = "functions\base";
            class baseManager {};
            class commanderToggleRepack {};
            class depositIntel {};
            class executeRepack {};
            class initCommandPC {};
            class initFOB {};
            class initMobileRespawn {};
            class initiatePurchase {};
            class openBuyMenu {};
            class packFOB {};
            class updateBuyCategory {};
            class upgradeBaseTier {};
        };

        class Economy {
            file = "functions\economy";
            class buyIntel {};
            class civilianIntel {};
            class economyManager {};
            class initActions {};
            class searchBody {};
            class undercoverTalk {};
        };

        class Infrastructure {
            file = "functions\infrastructure";
            class fobManager {};
            class infrastructureManager {};
            class intelManager {};
            class spawnManager {};
        };

        class Interactions {
            file = "functions\interactions";
            class initInformant {};
            class initInteractions {};
            class signalPlayer {};
        };

        class Persistence {
            file = "functions\persistence";
            class initPersistence {};
            class loadGame {};
            class saveGame {};
            class wipeSave {};
        };

        class Rebel {
            file = "functions\rebel";
            class rebelManager {};
        };

        class Reputation {
            file = "functions\reputation";
            class cityMonitor {};
            class civRep {};
        };

        class UI {
            file = "ui";
            class initUI {};
            class updateResourceUI {};
        };

        class Zones {
            file = "functions\zones";
            class abandonManager {};
            class despawnZoneAssets {};
            class spawnZoneAssets {};
            class zoneHandler {};
        };

        class Missions {
            file = "missions";
            class generateInitialMission {};
        };
    };
};
