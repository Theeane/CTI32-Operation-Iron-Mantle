/*
    Author: Theane (AGS Project)
    Description: Dynamic HUD with base-only Notoriety display.
*/

class AGS_ResourceBar {
    idd = 9000;
    duration = 1e+011;
    onLoad = "uiNamespace setVariable ['AGS_ctrl_resBar', _this select 0]";

    class Controls {
        // --- RESOURCE PANEL (Always visible) ---
        class ResourceGroup: RscControlsGroup {
            idc = 9000;
            x = safeZoneX + safeZoneW - 0.25; 
            y = safeZoneY + (safeZoneH * 0.45);
            w = 0.23; h = 0.04;
            class Controls {
                class Background: RscText { idc = 9005; x = 0; y = 0; w = 0.23; h = 0.04; colorBackground[] = {0,0,0,0.5}; };
                class SuppliesText: RscText { idc = 9001; text = "SUP: 0"; x = 0.01; y = 0.005; w = 0.1; h = 0.03; sizeEx = 0.035; };
                class IntelText: RscText { idc = 9002; text = "INT: 0"; x = 0.12; y = 0.005; w = 0.1; h = 0.03; sizeEx = 0.035; colorText[] = {0.2,0.6,1,1}; };
            };
        };

        // --- NOTORIETY PANEL (Visible only in FOB/MOB) ---
        class NotorietyGroup: RscControlsGroup {
            idc = 9200; // Unikt ID för att dölja/visa
            x = safeZoneX + safeZoneW - 0.25; 
            y = safeZoneY + (safeZoneH * 0.45) + 0.045; // Precis under resursbaren
            w = 0.23; h = 0.04;
            class Controls {
                class Background: RscText { idc = -1; x = 0; y = 0; w = 0.23; h = 0.04; colorBackground[] = {0,0,0,0.5}; };
                class HeatText: RscText { idc = 9003; text = "HEAT: 0%"; x = 0.01; y = 0.005; w = 0.2; h = 0.03; sizeEx = 0.035; colorText[] = {1,0.2,0.2,1}; };
            };
        };

        // --- THE EYE (Always visible) ---
        class EyeGroup: RscControlsGroup {
            idc = 9100;
            x = safeZoneX + safeZoneW - 0.15; 
            y = safeZoneY + (safeZoneH * 0.55); 
            w = 0.06; h = 0.06;
            class Controls {
                class UndercoverEye: RscPicture { idc = 9004; text = "media\icons\eye_green.paa"; x = 0; y = 0; w = 0.06; h = 0.06; };
            };
        };
    };
};
