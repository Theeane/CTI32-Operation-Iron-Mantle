class CfgFunctions
{
    class MWF
    {
        tag = "MWF";

        class Core
        {
            file = "Missionframework/core";

            class zoneCapture {};
            class economy {};
            class presetManager {};
            class undercoverHandler {};
            class initGlobals {};
            class openBuildZeus {};
            class setupFOBAction {};
            class openBaseArchitect {};
            class startFOBPlacement {};
            class initZones {};
            class initSystems {};
            class buildMode {};
            class finalizeBuild {};
            class limitZeusAssets {};
            class scanZones {};
            class setupFOBInteractions {};
            class setupInteractions {};
            class spawnFOBComposition {};
            class startBuildPlacement {};
            class zoneManager {};
        };

        class Base
        {
            file = "Missionframework/functions/base";

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

        class Zones
        {
            file = "Missionframework/functions/zones";

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

        class Economy
        {
            file = "Missionframework/functions/economy";

            class buyIntel {};
            class civilianIntel {};
            class initActions {};
            class searchBody {};
            class undercoverTalk {};
        };

        class Missions
        {
            file = "Missionframework/missions";

            class openMissionBoard {};
            class activateMissionBoardSlot {};
            class buildGrandOperationPlacements {};
            class buildMissionSessionPlacements {};
            class discoverMissionTemplates {};
            class executeMissionTemplate {};
            class generateInitialMission {};
        };

        class UI
        {
            file = "Missionframework/ui";

            class initUI {};
            class updateResourceUI {};
        };

        class World
        {
            file = "Missionframework/functions/world";

            class determineProgressionState {};
            class determineWorldTier {};
            class getWorldSnapshot {};
            class markWorldDirty {};
            class recalculateWorldState {};
            class worldManager {};
        };

        class Threat
        {
            file = "Missionframework/functions/threat";

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

        class Persistence
        {
            file = "Missionframework/functions/persistence";

            class initPersistence {};
            class loadGame {};
            class saveGame {};
            class wipeSave {};
        };

        class Presets
        {
            file = "Missionframework/functions/presets";

            class initPresets {};
        };
    };
};