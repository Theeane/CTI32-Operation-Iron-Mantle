class CfgFunctions {
    class MWF {
        tag = "MWF";

        class Core {
            file = "functions"; 
            

	    class hasProgressionAccess          { file = "MWF_fn_hasProgressionAccess.sqf"; };
            class interruptSensitiveInteraction { file = "MWF_fn_interruptSensitiveInteraction.sqf"; };
            class checkUndercover               { file = "MWF_fnc_checkUndercover.sqf"; }; // Denna saknades i din bild!
            class globalStateManager            { file = "MWF_fnc_globalStateManager.sqf"; };
            class onQuestComplete               { file = "MWF_fnc_onQuestComplete.sqf"; };
            class spawnModifier                 { file = "MWF_fnc_spawnModifier.sqf"; };
        };


        class UI {
            file = "ui";

            class initUI                  { file = "ui\MWF_fn_initUI.sqf"; };
            class updateResourceUI        { file = "ui\MWF_fn_updateResourceUI.sqf"; };
            class dataHub                 { file = "ui\datahub\MWF_fn_dataHub.sqf"; };
            class refreshDataMap          { file = "ui\datahub\MWF_fn_refreshDataMap.sqf"; };
            class collectDataMapEntries   { file = "ui\datahub\MWF_fn_collectDataMapEntries.sqf"; };
            class collectRespawnPoints    { file = "ui\datahub\MWF_fn_collectRespawnPoints.sqf"; };
            class uiGoBack                { file = "ui\datahub\MWF_fnc_uiGoBack.sqf"; };
            class openGuide               { file = "ui\guide\MWF_fn_openGuide.sqf"; };
        };

        // --- MODULAR SUBSYSTEMS ---
        #include "core\CfgFunctions.hpp"
        #include "missions\CfgFunctions.hpp"
        #include "functions\base\CfgFunctions.hpp"
        #include "functions\cinematics\CfgFunctions.hpp"
        #include "functions\client\CfgFunctions.hpp"
        #include "functions\compat\CfgFunctions.hpp"
        #include "functions\economy\CfgFunctions.hpp"
        #include "functions\endgame\CfgFunctions.hpp"
        #include "functions\infrastructure\CfgFunctions.hpp"
        #include "functions\interactions\CfgFunctions.hpp"
        #include "functions\loadout\CfgFunctions.hpp"
        #include "functions\persistence\CfgFunctions.hpp"
        #include "functions\presets\CfgFunctions.hpp"
        #include "functions\progression\CfgFunctions.hpp"
        #include "functions\rebel\CfgFunctions.hpp"
        #include "functions\reputation\CfgFunctions.hpp"
        #include "functions\scaling\CfgFunctions.hpp"
        #include "functions\terminal\CfgFunctions.hpp"
        #include "functions\threat\CfgFunctions.hpp"
        #include "functions\world\CfgFunctions.hpp"
        #include "functions\zones\CfgFunctions.hpp"
    };
};