class CfgFunctions {
    class MWF {
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
            class deployFOB {};
            class depositIntel {};
            class executeRepack {};
            class initCommandPC {};
            class initFOB {};
            class initMobileRespawn {};
            class initiatePurchase {};
            class openBuyMenu {};
            class packFOB {};
            class refreshFOBMarkers {};
            class registerFOB {};
            class repackFOB {};
            class restoreFOBs {};
            class unregisterFOB {};
            class updateBuyCategory {};
            class upgradeBaseTier {};
        };

        class Economy {
            file = "functions\economy";
            class buyIntel {};
            class civilianIntel {};
            class initActions {};
            class searchBody {};
            class undercoverTalk {};
        };

        class Infrastructure {
            file = "functions\infrastructure";
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

        class Threat {
            file = "functions\threat";
            class buildThreatDirectives {};
            class buildThreatResponses {};
            class determineGlobalThreat {};
            class determineZoneThreat {};
            class evaluateBaseThreat {};
            class getThreatSnapshot {};
            class markThreatDirty {};
            class recalculateThreatState {};
            class registerThreatIncident {};
            class selectThreatTargets {};
            class threatManager {};
        };

        class World {
            file = "functions\world";
            class determineProgressionState {};
            class determineWorldTier {};
            class getWorldSnapshot {};
            class markWorldDirty {};
            class recalculateWorldState {};
            class worldManager {};
        };

        class Zones {
            file = "functions\zones";
            class abandonManager {};
            class applyZoneSaveData {};
            class despawnZoneAssets {};
            class generateZonesFromMap {};
            class getZoneSaveData {};
            class loadManualZones {};
            class registerZone {};
            class setZoneOwner {};
            class spawnZoneAssets {};
            class syncZoneMarker {};
            class updateZoneProgression {};
            class zoneHandler {};
        };

        class Missions {
            file = "missions";
            class generateInitialMission {};
        };
    };
};
