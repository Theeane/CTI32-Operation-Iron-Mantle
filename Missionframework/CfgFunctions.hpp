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
            file = "core";
            class zoneCapture { file = "core/MWF_fn_zoneCapture.sqf"; };
            class economy { file = "core/MWF_fn_economy.sqf"; };
            class presetManager { file = "core/MWF_fn_presetManager.sqf"; };
            class undercoverHandler { file = "core/MWF_fn_undercoverHandler.sqf"; };
            class initGlobals { file = "core/MWF_fn_initGlobals.sqf"; };
            class openBuildZeus { file = "core/MWF_fn_openBuildZeus.sqf"; };
            class setupFOBAction { file = "core/MWF_fn_setupFOBAction.sqf"; };
            class openBaseArchitect { file = "core/MWF_fn_openBaseArchitect.sqf"; };
            class startFOBPlacement { file = "core/MWF_fn_startFOBPlacement.sqf"; };
            class initZones { file = "core/MWF_fn_initZones.sqf"; };
            class initSystems { file = "core/MWF_fn_initSystems.sqf"; };
            class buildMode { file = "core/MWF_fn_buildMode.sqf"; };
            class finalizeBuild { file = "core/MWF_fn_finalizeBuild.sqf"; };
            class cleanupBuildPlacement { file = "core/MWF_fn_cleanupBuildPlacement.sqf"; };
            class validateBuildPlacement { file = "core/MWF_fn_validateBuildPlacement.sqf"; };
            class limitZeusAssets { file = "core/MWF_fn_limitZeusAssets.sqf"; };
            class scanZones { file = "core/MWF_fn_scanZones.sqf"; };
            class setupFOBInteractions { file = "core/MWF_fn_setupFOBInteractions.sqf"; };
            class setupInteractions { file = "core/MWF_fn_setupInteractions.sqf"; };
            class spawnFOBComposition { file = "core/MWF_fn_spawnFOBComposition.sqf"; };
            class startBuildPlacement { file = "core/MWF_fn_startBuildPlacement.sqf"; };
            class zoneManager { file = "core/MWF_fn_zoneManager.sqf"; };
            class addResource { file = "core/MWF_fn_addResource.sqf"; };
            class showNotification { file = "core/MWF_fn_showNotification.sqf"; };
            class MOBComputerLogin { file = "core/MWF_fn_MOBComputerLogin.sqf"; };
            class setCampaignPhase { file = "core/MWF_fn_setCampaignPhase.sqf"; };
            class syncEconomyState { file = "core/MWF_fn_syncEconomyState.sqf"; };
            class enterBuildMode { file = "core/MWF_fn_enterBuildMode.sqf"; };
            class handleBuildPlacement { file = "core/MWF_fn_handleBuildPlacement.sqf"; };
            class isBuildAssetAllowed { file = "core/MWF_fn_isBuildAssetAllowed.sqf"; };
            class getBuildAssetCost { file = "core/MWF_fn_getBuildAssetCost.sqf"; };
        };

        class Compatibility {
            file = "functions/compat";
            class initInteractions { file = "functions/compat/MWF_fn_initInteractions.sqf"; };
            class openBuildMenu { file = "functions/compat/MWF_fn_openBuildMenu.sqf"; };
            class cleanupCurator { file = "functions/compat/MWF_fn_cleanupCurator.sqf"; };
            class saveManager { file = "functions/compat/MWF_fn_saveManager.sqf"; };
        };

        class Misc {
            file = "functions";
            class addIntel { file = "functions/compat/MWF_fn_addIntel.sqf"; };
            class checkUndercover { file = "functions/MWF_fnc_checkUndercover.sqf"; };
            class hasProgressionAccess { file = "functions/MWF_fn_hasProgressionAccess.sqf"; };
            class globalStateManager { file = "functions/MWF_fnc_globalStateManager.sqf"; };
            class interruptSensitiveInteraction { file = "functions/MWF_fn_interruptSensitiveInteraction.sqf"; };
        };

        class Terminal {
            file = "functions/terminal";
            class terminal_main { file = "functions/terminal/MWF_fnc_terminal_main.sqf"; };
            class terminal_upload { file = "functions/terminal/MWF_fnc_terminal_upload.sqf"; };
            class terminal_disrupt { file = "functions/terminal/MWF_fnc_terminal_disrupt.sqf"; };
            class terminal_mainOperations { file = "functions/terminal/MWF_fnc_terminal_mainOperations.sqf"; };
            class terminal_redeploy { file = "functions/terminal/MWF_fnc_terminal_redeploy.sqf"; };
            class terminal_vehicleMenu { file = "functions/terminal/MWF_fnc_terminal_vehicleMenu.sqf"; };
            class terminal_support { file = "functions/terminal/MWF_fnc_terminal_support.sqf"; };
            class spawnSupportGroup { file = "functions/terminal/MWF_fnc_spawnSupportGroup.sqf"; };
            class spawnSupportUnit { file = "functions/terminal/MWF_fnc_spawnSupportUnit.sqf"; };
            class getSupportSpawnContext { file = "functions/terminal/MWF_fnc_getSupportSpawnContext.sqf"; };
            class beginVehiclePlacement { file = "functions/terminal/MWF_fnc_beginVehiclePlacement.sqf"; };
            class confirmVehiclePlacement { file = "functions/terminal/MWF_fnc_confirmVehiclePlacement.sqf"; };
            class cancelVehiclePlacement { file = "functions/terminal/MWF_fnc_cancelVehiclePlacement.sqf"; };
            class cleanupVehiclePlacement { file = "functions/terminal/MWF_fnc_cleanupVehiclePlacement.sqf"; };
            class getVehicleCatalog { file = "functions/terminal/MWF_fnc_getVehicleCatalog.sqf"; };
            class getVehiclePlacementProfile { file = "functions/terminal/MWF_fnc_getVehiclePlacementProfile.sqf"; };
            class handleRedeployMapClick { file = "functions/terminal/MWF_fnc_handleRedeployMapClick.sqf"; };
            class updateVehicleGhost { file = "functions/terminal/MWF_fnc_updateVehicleGhost.sqf"; };
            class validateTerminalAccess { file = "functions/terminal/MWF_fnc_validateTerminalAccess.sqf"; };
            class validateVehiclePlacement { file = "functions/terminal/MWF_fnc_validateVehiclePlacement.sqf"; };
        };

        class GrandOps {
            file = "MainOp";
            class op_skyGuardian { file = "MainOp/MWF_fn_op_skyGuardian.sqf"; };
            class op_pointBlank { file = "MainOp/MWF_fn_op_pointBlank.sqf"; };
            class op_severedNerve { file = "MainOp/MWF_fn_op_severedNerve.sqf"; };
            class op_stasisStrike { file = "MainOp/MWF_fn_op_stasisStrike.sqf"; };
            class op_steelRain { file = "MainOp/MWF_fn_op_steelRain.sqf"; };
            class op_apexPredator { file = "MainOp/MWF_fn_op_apexPredator.sqf"; };
        };

        class Base {
            file = "functions/base";
            class baseManager { file = "functions/base/MWF_fn_baseManager.sqf"; };
            class commanderToggleRepack { file = "functions/base/MWF_fn_commanderToggleRepack.sqf"; };
            class deployFOB { file = "functions/base/MWF_fn_deployFOB.sqf"; };
            class depositIntel { file = "functions/base/MWF_fn_depositIntel.sqf"; };
            class executeRepack { file = "functions/base/MWF_fn_executeRepack.sqf"; };
            class initCommandPC { file = "functions/base/MWF_fn_initCommandPC.sqf"; };
            class initFOB { file = "functions/base/MWF_fn_initFOB.sqf"; };
            class initMobileRespawn { file = "functions/base/MWF_fn_initMobileRespawn.sqf"; };
            class vehicleIntelTransfer { file = "functions/base/MWF_fn_vehicleIntelTransfer.sqf"; };
            class spawnInitialFOBAsset { file = "functions/base/MWF_fn_spawnInitialFOBAsset.sqf"; };
            class initiatePurchase { file = "functions/base/MWF_fn_initiatePurchase.sqf"; };
            class openBuyMenu { file = "functions/base/MWF_fn_openBuyMenu.sqf"; };
            class packFOB { file = "functions/base/MWF_fn_packFOB.sqf"; };
            class refreshFOBMarkers { file = "functions/base/MWF_fn_refreshFOBMarkers.sqf"; };
            class registerFOB { file = "functions/base/MWF_fn_registerFOB.sqf"; };
            class repackFOB { file = "functions/base/MWF_fn_repackFOB.sqf"; };
            class restoreFOBs { file = "functions/base/MWF_fn_restoreFOBs.sqf"; };
            class garageSystem { file = "functions/base/MWF_fn_garageSystem.sqf"; };
            class setupGarageInteractions { file = "functions/base/MWF_fn_setupGarageInteractions.sqf"; };
            class unregisterFOB { file = "functions/base/MWF_fn_unregisterFOB.sqf"; };
            class updateBuyCategory { file = "functions/base/MWF_fn_updateBuyCategory.sqf"; };
            class upgradeBaseTier { file = "functions/base/MWF_fn_upgradeBaseTier.sqf"; };
        };

        class Zones {
            file = "functions/zones";
            class abandonManager { file = "functions/zones/MWF_fn_abandonManager.sqf"; };
            class applyZoneSaveData { file = "functions/zones/MWF_fn_applyZoneSaveData.sqf"; };
            class despawnZoneAssets { file = "functions/zones/MWF_fn_despawnZoneAssets.sqf"; };
            class generateZonesFromMap { file = "functions/zones/MWF_fn_generateZonesFromMap.sqf"; };
            class getZoneSaveData { file = "functions/zones/MWF_fn_getZoneSaveData.sqf"; };
            class loadManualZones { file = "functions/zones/MWF_fn_loadManualZones.sqf"; };
            class registerZone { file = "functions/zones/MWF_fn_registerZone.sqf"; };
            class setZoneOwner { file = "functions/zones/MWF_fn_setZoneOwner.sqf"; };
            class spawnZoneAssets { file = "functions/zones/MWF_fn_spawnZoneAssets.sqf"; };
            class syncZoneMarker { file = "functions/zones/MWF_fn_syncZoneMarker.sqf"; };
            class updateZoneProgression { file = "functions/zones/MWF_fn_updateZoneProgression.sqf"; };
            class zoneHandler { file = "functions/zones/MWF_fn_zoneHandler.sqf"; };
        };

        class Progression {
            file = "functions/progression";
            class applyMissionImpact { file = "functions/progression/MWF_fn_applyMissionImpact.sqf"; };
            class finalizeMainOperation { file = "functions/progression/MWF_fn_finalizeMainOperation.sqf"; };
            class getMainOperationRegistry { file = "functions/progression/MWF_fn_getMainOperationRegistry.sqf"; };
            class getMainOperationState { file = "functions/progression/MWF_fn_getMainOperationState.sqf"; };
            class getMissionImpactProfile { file = "functions/progression/MWF_fn_getMissionImpactProfile.sqf"; };
            class mainOperationRuntime { file = "functions/progression/MWF_fn_mainOperationRuntime.sqf"; };
            class mainOperationBackend { file = "functions/progression/MWF_fn_mainOperationBackend.sqf"; };
        };

        class Economy {
            file = "functions/economy";
            class buyIntel { file = "functions/economy/MWF_fn_buyIntel.sqf"; };
            class civilianIntel { file = "functions/economy/MWF_fn_civilianIntel.sqf"; };
            class initActions { file = "functions/economy/MWF_fn_initActions.sqf"; };
            class searchBody { file = "functions/economy/MWF_fn_searchBody.sqf"; };
            class undercoverTalk { file = "functions/economy/MWF_fn_undercoverTalk.sqf"; };
        };

        class Missions {
            file = "missions";
            class openMissionBoard { file = "missions/MWF_fn_openMissionBoard.sqf"; };
            class activateMissionBoardSlot { file = "missions/MWF_fn_activateMissionBoardSlot.sqf"; };
            class buildGrandOperationPlacements { file = "missions/MWF_fn_buildGrandOperationPlacements.sqf"; };
            class buildMissionSessionPlacements { file = "missions/MWF_fn_buildMissionSessionPlacements.sqf"; };
            class discoverMissionTemplates { file = "missions/MWF_fn_discoverMissionTemplates.sqf"; };
            class completeSideMission { file = "missions/MWF_fn_completeSideMission.sqf"; };
            class executeMissionTemplate { file = "missions/MWF_fn_executeMissionTemplate.sqf"; };
            class generateInitialMission { file = "missions/MWF_fn_generateInitialMission.sqf"; };
            class getSideMissionRewardProfile { file = "missions/MWF_fn_getSideMissionRewardProfile.sqf"; };
            class initMissionSystem { file = "missions/MWF_fn_initMissionSystem.sqf"; };
            class refreshMissionBoard { file = "missions/MWF_fn_refreshMissionBoard.sqf"; };
            class applyTutorialReward { file = "missions/MWF_fn_applyTutorialReward.sqf"; };
            class sideMissionRuntime { file = "missions/MWF_fn_sideMissionRuntime.sqf"; };
        };

        class UI {
            file = "ui";
            class initUI { file = "ui/MWF_fn_initUI.sqf"; };
            class updateResourceUI { file = "ui/MWF_fn_updateResourceUI.sqf"; };
            class dataHub { file = "ui/datahub/MWF_fn_dataHub.sqf"; };
            class collectDataMapEntries { file = "ui/datahub/MWF_fn_collectDataMapEntries.sqf"; };
            class collectRespawnPoints { file = "ui/datahub/MWF_fn_collectRespawnPoints.sqf"; };
            class refreshDataMap { file = "ui/datahub/MWF_fn_refreshDataMap.sqf"; };
            class uiGoBack { file = "ui/datahub/MWF_fnc_uiGoBack.sqf"; };
        };

        class Loadout {
            file = "functions/loadout";
            class applyRespawnLoadout { file = "functions/loadout/MWF_fn_applyRespawnLoadout.sqf"; };
            class buildLoadoutCaches { file = "functions/loadout/MWF_fn_buildLoadoutCaches.sqf"; };
            class initLoadoutSystem { file = "functions/loadout/MWF_fn_initLoadoutSystem.sqf"; };
            class openLoadoutArsenal { file = "functions/loadout/MWF_fn_openLoadoutArsenal.sqf"; };
            class registerLoadoutZone { file = "functions/loadout/MWF_fn_registerLoadoutZone.sqf"; };
            class saveRespawnLoadout { file = "functions/loadout/MWF_fn_saveRespawnLoadout.sqf"; };
            class unregisterLoadoutZone { file = "functions/loadout/MWF_fn_unregisterLoadoutZone.sqf"; };
        };

        class World {
            file = "functions/world";
            class determineProgressionState { file = "functions/world/MWF_fn_determineProgressionState.sqf"; };
            class determineWorldTier { file = "functions/world/MWF_fn_determineWorldTier.sqf"; };
            class getWorldSnapshot { file = "functions/world/MWF_fn_getWorldSnapshot.sqf"; };
            class markWorldDirty { file = "functions/world/MWF_fn_markWorldDirty.sqf"; };
            class recalculateWorldState { file = "functions/world/MWF_fn_recalculateWorldState.sqf"; };
            class worldManager { file = "functions/world/MWF_fn_worldManager.sqf"; };
        };

        class Threat {
            file = "functions/threat";
            class buildThreatDirectives { file = "functions/threat/MWF_fn_buildThreatDirectives.sqf"; };
            class buildThreatResponses { file = "functions/threat/MWF_fn_buildThreatResponses.sqf"; };
            class determineGlobalThreat { file = "functions/threat/MWF_fn_determineGlobalThreat.sqf"; };
            class determineZoneThreat { file = "functions/threat/MWF_fn_determineZoneThreat.sqf"; };
            class evaluateBaseThreat { file = "functions/threat/MWF_fn_evaluateBaseThreat.sqf"; };
            class getThreatSnapshot { file = "functions/threat/MWF_fn_getThreatSnapshot.sqf"; };
            class markThreatDirty { file = "functions/threat/MWF_fn_markThreatDirty.sqf"; };
            class recalculateThreatState { file = "functions/threat/MWF_fn_recalculateThreatState.sqf"; };
            class registerThreatIncident { file = "functions/threat/MWF_fn_registerThreatIncident.sqf"; };
            class selectThreatTargets { file = "functions/threat/MWF_fn_selectThreatTargets.sqf"; };
            class threatManager { file = "functions/threat/MWF_fn_threatManager.sqf"; };
        };

        class Persistence {
            file = "functions/persistence";
            class initPersistence { file = "functions/persistence/MWF_fn_initPersistence.sqf"; };
            class loadGame { file = "functions/persistence/MWF_fn_loadGame.sqf"; };
            class saveGame { file = "functions/persistence/MWF_fn_saveGame.sqf"; };
            class wipeSave { file = "functions/persistence/MWF_fn_wipeSave.sqf"; };
            class initCampaignAnalytics { file = "functions/persistence/MWF_fn_initCampaignAnalytics.sqf"; };
            class recordCampaignEvent { file = "functions/persistence/MWF_fn_recordCampaignEvent.sqf"; };
            class registerAuthenticatedPlayer { file = "functions/persistence/MWF_fn_registerAuthenticatedPlayer.sqf"; };
            class restoreSession { file = "functions/persistence/MWF_fn_restoreSession.sqf"; };
            class restoreBuiltUpgradeStructures { file = "functions/persistence/MWF_fn_restoreBuiltUpgradeStructures.sqf"; };
            class sanitizeComposition { file = "functions/persistence/MWF_fn_sanitizeComposition.sqf"; };
            class showEndSummary { file = "functions/persistence/MWF_fn_showEndSummary.sqf"; };
        };

        class Presets {
            file = "functions/presets";
            class initPresets { file = "functions/presets/MWF_fn_initPresets.sqf"; };
            class resolveCompositionPath { file = "functions/presets/MWF_fn_resolveCompositionPath.sqf"; };
        };

        class Scaling {
            file = "functions/scaling";
            class getScalingProfile { file = "functions/scaling/MWF_fn_getScalingProfile.sqf"; };
            class getAISpawnAllowance { file = "functions/scaling/MWF_fn_getAISpawnAllowance.sqf"; };
            class scaleSpawnCount { file = "functions/scaling/MWF_fn_scaleSpawnCount.sqf"; };
        };

        class Infrastructure {
            file = "functions/infrastructure";
            class infrastructureManager { file = "functions/infrastructure/MWF_fn_infrastructureManager.sqf"; };
            class intelManager { file = "functions/infrastructure/MWF_fn_intelManager.sqf"; };
            class infrastructureMarkerManager { file = "functions/infrastructure/MWF_fn_infrastructureMarkerManager.sqf"; };
            class spawnManager { file = "functions/infrastructure/MWF_fn_spawnManager.sqf"; };
        };

        class Rebel {
            file = "functions/rebel";
            class rebelManager { file = "functions/rebel/MWF_fn_rebelManager.sqf"; };
            class rebelLeaderSystem { file = "functions/rebel/MWF_fn_rebelLeaderSystem.sqf"; };
            class rebelLeaderDialogue { file = "functions/rebel/MWF_fn_rebelLeaderDialogue.sqf"; };
            class fobAttackSystem { file = "functions/rebel/MWF_fn_fobAttackSystem.sqf"; };
            class fobRepairInteraction { file = "functions/rebel/MWF_fn_fobRepairInteraction.sqf"; };
            class fobDespawnSystem { file = "functions/rebel/MWF_fn_fobDespawnSystem.sqf"; };
        };

        class Reputation {
            file = "functions/reputation";
            class cityMonitor { file = "functions/reputation/MWF_fn_cityMonitor.sqf"; };
            class civRep { file = "functions/reputation/MWF_fn_civRep.sqf"; };
            class civRepSupport { file = "functions/reputation/MWF_fn_civRepSupport.sqf"; };
            class civRepInformant { file = "functions/reputation/MWF_fn_civRepInformant.sqf"; };
            class handleCivilianCasualty { file = "functions/reputation/MWF_fn_handleCivilianCasualty.sqf"; };
        };


        class Audio {
            file = "functions/endgame";
            class playSharedMusic { file = "functions/endgame/MWF_fn_playSharedMusic.sqf"; };
            class playConfiguredMusicLocal { file = "functions/endgame/MWF_fn_playConfiguredMusicLocal.sqf"; };
        };

        class Endgame {
            file = "functions/endgame";
            class applyLeaderAppearance { file = "functions/endgame/MWF_fn_applyLeaderAppearance.sqf"; };
            class showEndingScreen { file = "functions/endgame/MWF_fn_showEndingScreen.sqf"; };
            class endgameManager { file = "functions/endgame/MWF_fn_endgameManager.sqf"; };
        };

        class Interactions {
            file = "functions/interactions";
            class signalPlayer { file = "functions/interactions/MWF_fn_signalPlayer.sqf"; };
        };
    };
};
