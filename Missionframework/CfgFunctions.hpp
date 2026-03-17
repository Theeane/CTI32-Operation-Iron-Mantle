/*
    Author: Theane / ChatGPT
    Project: Military War Framework (MWF)

    Description:
    Central function registration for the runtime-safe MWF boot chain.
*/

class CfgFunctions {
    class MWF {
        tag = "MWF";

        class Core {
            file = "Missionframework/core";
            class zoneCapture { file = "Missionframework/core/MWF_fn_zoneCapture.sqf"; };
            class economy { file = "Missionframework/core/MWF_fn_economy.sqf"; };
            class syncEconomyState { file = "Missionframework/core/MWF_fn_syncEconomyState.sqf"; };
            class presetManager { file = "Missionframework/core/MWF_fn_presetManager.sqf"; };
            class undercoverHandler { file = "Missionframework/core/MWF_fn_undercoverHandler.sqf"; };
            class initGlobals { file = "Missionframework/core/MWF_fn_initGlobals.sqf"; };
            class openBuildZeus { file = "Missionframework/core/MWF_fn_openBuildZeus.sqf"; };
            class setupFOBAction { file = "Missionframework/core/MWF_fn_setupFOBAction.sqf"; };
            class openBaseArchitect { file = "Missionframework/core/MWF_fn_openBaseArchitect.sqf"; };
            class startFOBPlacement { file = "Missionframework/core/MWF_fn_startFOBPlacement.sqf"; };
            class initZones { file = "Missionframework/core/MWF_fn_initZones.sqf"; };
            class initSystems { file = "Missionframework/core/MWF_fn_initSystems.sqf"; };
            class buildMode { file = "Missionframework/core/MWF_fn_buildMode.sqf"; };
            class finalizeBuild { file = "Missionframework/core/MWF_fn_finalizeBuild.sqf"; };
            class limitZeusAssets { file = "Missionframework/core/MWF_fn_limitZeusAssets.sqf"; };
            class scanZones { file = "Missionframework/core/MWF_fn_scanZones.sqf"; };
            class setupFOBInteractions { file = "Missionframework/core/MWF_fn_setupFOBInteractions.sqf"; };
            class setupInteractions { file = "Missionframework/core/MWF_fn_setupInteractions.sqf"; };
            class spawnFOBComposition { file = "Missionframework/core/MWF_fn_spawnFOBComposition.sqf"; };
            class startBuildPlacement { file = "Missionframework/core/MWF_fn_startBuildPlacement.sqf"; };
            class zoneManager { file = "Missionframework/core/MWF_fn_zoneManager.sqf"; };
            class addResource { file = "Missionframework/core/MWF_fn_addResource.sqf"; };
            class showNotification { file = "Missionframework/core/MWF_fn_showNotification.sqf"; };
            class MOBComputerLogin { file = "Missionframework/core/MWF_fn_MOBComputerLogin.sqf"; };
            class setCampaignPhase { file = "Missionframework/core/MWF_fn_setCampaignPhase.sqf"; };
        };

        class Compatibility {
            file = "Missionframework/functions/compat";
            class initInteractions { file = "Missionframework/functions/compat/MWF_fn_initInteractions.sqf"; };
            class openBuildMenu { file = "Missionframework/functions/compat/MWF_fn_openBuildMenu.sqf"; };
            class cleanupCurator { file = "Missionframework/functions/compat/MWF_fn_cleanupCurator.sqf"; };
            class saveManager { file = "Missionframework/functions/compat/MWF_fn_saveManager.sqf"; };
        };

        class Misc {
            file = "Missionframework/functions";
            class addIntel { file = "Missionframework/functions/compat/MWF_fn_addIntel.sqf"; };
            class checkUndercover { file = "Missionframework/functions/MWF_fnc_checkUndercover.sqf"; };
            class globalStateManager { file = "Missionframework/functions/MWF_fnc_globalStateManager.sqf"; };
        };

        class Terminal {
            file = "Missionframework/functions/terminal";
            class terminal_main { file = "Missionframework/functions/terminal/MWF_fnc_terminal_main.sqf"; };
            class terminal_upload { file = "Missionframework/functions/terminal/MWF_fnc_terminal_upload.sqf"; };
            class terminal_disrupt { file = "Missionframework/functions/terminal/MWF_fnc_terminal_disrupt.sqf"; };
        };

        class GrandOps {
            file = "Missionframework/MainOp";
            class op_skyGuardian { file = "Missionframework/MainOp/MWF_fn_op_skyGuardian.sqf"; };
            class op_pointBlank { file = "Missionframework/MainOp/MWF_fn_op_pointBlank.sqf"; };
            class op_severedNerve { file = "Missionframework/MainOp/MWF_fn_op_severedNerve.sqf"; };
            class op_stasisStrike { file = "Missionframework/MainOp/MWF_fn_op_stasisStrike.sqf"; };
            class op_steelRain { file = "Missionframework/MainOp/MWF_fn_op_steelRain.sqf"; };
            class op_apexPredator { file = "Missionframework/MainOp/MWF_fn_op_apexPredator.sqf"; };
        };

        class Base {
            file = "Missionframework/functions/base";
            class baseManager { file = "Missionframework/functions/base/MWF_fn_baseManager.sqf"; };
            class commanderToggleRepack { file = "Missionframework/functions/base/MWF_fn_commanderToggleRepack.sqf"; };
            class deployFOB { file = "Missionframework/functions/base/MWF_fn_deployFOB.sqf"; };
            class depositIntel { file = "Missionframework/functions/base/MWF_fn_depositIntel.sqf"; };
            class executeRepack { file = "Missionframework/functions/base/MWF_fn_executeRepack.sqf"; };
            class initCommandPC { file = "Missionframework/functions/base/MWF_fn_initCommandPC.sqf"; };
            class initFOB { file = "Missionframework/functions/base/MWF_fn_initFOB.sqf"; };
            class initMobileRespawn { file = "Missionframework/functions/base/MWF_fn_initMobileRespawn.sqf"; };
            class spawnInitialFOBAsset { file = "Missionframework/functions/base/MWF_fn_spawnInitialFOBAsset.sqf"; };
            class initiatePurchase { file = "Missionframework/functions/base/MWF_fn_initiatePurchase.sqf"; };
            class openBuyMenu { file = "Missionframework/functions/base/MWF_fn_openBuyMenu.sqf"; };
            class packFOB { file = "Missionframework/functions/base/MWF_fn_packFOB.sqf"; };
            class refreshFOBMarkers { file = "Missionframework/functions/base/MWF_fn_refreshFOBMarkers.sqf"; };
            class registerFOB { file = "Missionframework/functions/base/MWF_fn_registerFOB.sqf"; };
            class repackFOB { file = "Missionframework/functions/base/MWF_fn_repackFOB.sqf"; };
            class restoreFOBs { file = "Missionframework/functions/base/MWF_fn_restoreFOBs.sqf"; };
            class unregisterFOB { file = "Missionframework/functions/base/MWF_fn_unregisterFOB.sqf"; };
            class updateBuyCategory { file = "Missionframework/functions/base/MWF_fn_updateBuyCategory.sqf"; };
            class upgradeBaseTier { file = "Missionframework/functions/base/MWF_fn_upgradeBaseTier.sqf"; };
        };

        class Zones {
            file = "Missionframework/functions/zones";
            class abandonManager { file = "Missionframework/functions/zones/MWF_fn_abandonManager.sqf"; };
            class applyZoneSaveData { file = "Missionframework/functions/zones/MWF_fn_applyZoneSaveData.sqf"; };
            class despawnZoneAssets { file = "Missionframework/functions/zones/MWF_fn_despawnZoneAssets.sqf"; };
            class generateZonesFromMap { file = "Missionframework/functions/zones/MWF_fn_generateZonesFromMap.sqf"; };
            class getZoneSaveData { file = "Missionframework/functions/zones/MWF_fn_getZoneSaveData.sqf"; };
            class loadManualZones { file = "Missionframework/functions/zones/MWF_fn_loadManualZones.sqf"; };
            class registerZone { file = "Missionframework/functions/zones/MWF_fn_registerZone.sqf"; };
            class setZoneOwner { file = "Missionframework/functions/zones/MWF_fn_setZoneOwner.sqf"; };
            class spawnZoneAssets { file = "Missionframework/functions/zones/MWF_fn_spawnZoneAssets.sqf"; };
            class syncZoneMarker { file = "Missionframework/functions/zones/MWF_fn_syncZoneMarker.sqf"; };
            class updateZoneProgression { file = "Missionframework/functions/zones/MWF_fn_updateZoneProgression.sqf"; };
            class zoneHandler { file = "Missionframework/functions/zones/MWF_fn_zoneHandler.sqf"; };
        };

        class Economy {
            file = "Missionframework/functions/economy";
            class buyIntel { file = "Missionframework/functions/economy/MWF_fn_buyIntel.sqf"; };
            class civilianIntel { file = "Missionframework/functions/economy/MWF_fn_civilianIntel.sqf"; };
            class initActions { file = "Missionframework/functions/economy/MWF_fn_initActions.sqf"; };
            class searchBody { file = "Missionframework/functions/economy/MWF_fn_searchBody.sqf"; };
            class undercoverTalk { file = "Missionframework/functions/economy/MWF_fn_undercoverTalk.sqf"; };
        };

        class Missions {
            file = "Missionframework/missions";
            class openMissionBoard { file = "Missionframework/missions/MWF_fn_openMissionBoard.sqf"; };
            class activateMissionBoardSlot { file = "Missionframework/missions/MWF_fn_activateMissionBoardSlot.sqf"; };
            class buildGrandOperationPlacements { file = "Missionframework/missions/MWF_fn_buildGrandOperationPlacements.sqf"; };
            class buildMissionSessionPlacements { file = "Missionframework/missions/MWF_fn_buildMissionSessionPlacements.sqf"; };
            class discoverMissionTemplates { file = "Missionframework/missions/MWF_fn_discoverMissionTemplates.sqf"; };
            class executeMissionTemplate { file = "Missionframework/missions/MWF_fn_executeMissionTemplate.sqf"; };
            class generateInitialMission { file = "Missionframework/missions/MWF_fn_generateInitialMission.sqf"; };
            class initMissionSystem { file = "Missionframework/missions/MWF_fn_initMissionSystem.sqf"; };
            class refreshMissionBoard { file = "Missionframework/missions/MWF_fn_refreshMissionBoard.sqf"; };
        };

        class UI {
            file = "Missionframework/ui";
            class initUI { file = "Missionframework/ui/MWF_fn_initUI.sqf"; };
            class updateResourceUI { file = "Missionframework/ui/MWF_fn_updateResourceUI.sqf"; };
        };

        class World {
            file = "Missionframework/functions/world";
            class determineProgressionState { file = "Missionframework/functions/world/MWF_fn_determineProgressionState.sqf"; };
            class determineWorldTier { file = "Missionframework/functions/world/MWF_fn_determineWorldTier.sqf"; };
            class getWorldSnapshot { file = "Missionframework/functions/world/MWF_fn_getWorldSnapshot.sqf"; };
            class markWorldDirty { file = "Missionframework/functions/world/MWF_fn_markWorldDirty.sqf"; };
            class recalculateWorldState { file = "Missionframework/functions/world/MWF_fn_recalculateWorldState.sqf"; };
            class worldManager { file = "Missionframework/functions/world/MWF_fn_worldManager.sqf"; };
        };

        class Threat {
            file = "Missionframework/functions/threat";
            class buildThreatDirectives { file = "Missionframework/functions/threat/MWF_fn_buildThreatDirectives.sqf"; };
            class buildThreatResponses { file = "Missionframework/functions/threat/MWF_fn_buildThreatResponses.sqf"; };
            class determineGlobalThreat { file = "Missionframework/functions/threat/MWF_fn_determineGlobalThreat.sqf"; };
            class determineZoneThreat { file = "Missionframework/functions/threat/MWF_fn_determineZoneThreat.sqf"; };
            class evaluateBaseThreat { file = "Missionframework/functions/threat/MWF_fn_evaluateBaseThreat.sqf"; };
            class getThreatSnapshot { file = "Missionframework/functions/threat/MWF_fn_getThreatSnapshot.sqf"; };
            class markThreatDirty { file = "Missionframework/functions/threat/MWF_fn_markThreatDirty.sqf"; };
            class recalculateThreatState { file = "Missionframework/functions/threat/MWF_fn_recalculateThreatState.sqf"; };
            class registerThreatIncident { file = "Missionframework/functions/threat/MWF_fn_registerThreatIncident.sqf"; };
            class selectThreatTargets { file = "Missionframework/functions/threat/MWF_fn_selectThreatTargets.sqf"; };
            class threatManager { file = "Missionframework/functions/threat/MWF_fn_threatManager.sqf"; };
        };

        class Persistence {
            file = "Missionframework/functions/persistence";
            class initPersistence { file = "Missionframework/functions/persistence/MWF_fn_initPersistence.sqf"; };
            class initCampaignAnalytics { file = "Missionframework/functions/persistence/MWF_fn_initCampaignAnalytics.sqf"; };
            class loadGame { file = "Missionframework/functions/persistence/MWF_fn_loadGame.sqf"; };
            class recordCampaignEvent { file = "Missionframework/functions/persistence/MWF_fn_recordCampaignEvent.sqf"; };
            class restoreSession { file = "Missionframework/functions/persistence/MWF_fn_restoreSession.sqf"; };
            class saveGame { file = "Missionframework/functions/persistence/MWF_fn_saveGame.sqf"; };
            class wipeSave { file = "Missionframework/functions/persistence/MWF_fn_wipeSave.sqf"; };
        };

        class Presets {
            file = "Missionframework/functions/presets";
            class initPresets { file = "Missionframework/functions/presets/MWF_fn_initPresets.sqf"; };
        };

        class Infrastructure {
            file = "Missionframework/functions/infrastructure";
            class infrastructureManager { file = "Missionframework/functions/infrastructure/MWF_fn_infrastructureManager.sqf"; };
            class intelManager { file = "Missionframework/functions/infrastructure/MWF_fn_intelManager.sqf"; };
            class spawnManager { file = "Missionframework/functions/infrastructure/MWF_fn_spawnManager.sqf"; };
        };

        class Rebel {
            file = "Missionframework/functions/rebel";
            class rebelManager { file = "Missionframework/functions/rebel/MWF_fn_rebelManager.sqf"; };
        };

        class Reputation {
            file = "Missionframework/functions/reputation";
            class cityMonitor { file = "Missionframework/functions/reputation/MWF_fn_cityMonitor.sqf"; };
            class civRep { file = "Missionframework/functions/reputation/MWF_fn_civRep.sqf"; };
        };

        class Interactions {
            file = "Missionframework/functions/interactions";
            class signalPlayer { file = "Missionframework/functions/interactions/MWF_fn_signalPlayer.sqf"; };
        };
    };
};
