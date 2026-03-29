/*
    Author: Theane / ChatGPT / OpenAI
    Function: resourceBar
    Project: Military War Framework

    Description:
    Defines the UI layout for the resource bar.
*/

class MWF_ResourceBar {
    idd = 9010;
    duration = 1e+011;
    onLoad = "uiNamespace setVariable ['MWF_ctrl_resBar', _this select 0];";

    class Controls {
        class ResourceGroup: RscControlsGroup {
            idc = 9000;
            x = safeZoneX + safeZoneW - 0.16;
            y = safeZoneY + (safeZoneH * 0.43);
            w = 0.14;
            h = 0.19;
            class Controls {
                class Background: RscText {
                    idc = 9005;
                    x = 0;
                    y = 0;
                    w = 0.14;
                    h = 0.19;
                    colorBackground[] = {0,0,0,0.35};
                };
                class ResourceText: RscStructuredText {
                    idc = 9001;
                    text = "";
                    x = 0.008;
                    y = 0.006;
                    w = 0.124;
                    h = 0.178;
                    size = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 34) * 1)";
                    class Attributes {
                        font = "RobotoCondensed";
                        color = "#FFFFFF";
                        colorLink = "#D09B43";
                        align = "left";
                        shadow = 1;
                    };
                };
            };
        };

        class NotorietyGroup: RscControlsGroup {
            idc = 9200;
            x = safeZoneX + safeZoneW - 0.16;
            y = safeZoneY + (safeZoneH * 0.43);
            w = 0;
            h = 0;
            class Controls {};
        };

        class EyeGroup: RscControlsGroup {
            idc = 9100;
            x = safeZoneX + safeZoneW - 0.16;
            y = safeZoneY + (safeZoneH * 0.43);
            w = 0;
            h = 0;
            class Controls {
                class UndercoverEye: RscPicture {
                    idc = 9004;
                    text = "";
                    x = 0;
                    y = 0;
                    w = 0;
                    h = 0;
                };
            };
        };
    };
};
