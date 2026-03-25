/*
    Author: Theane / ChatGPT
    Function: buildMenu
    Project: Military War Framework

    Description:
    Legacy compatibility buy/build menu shell.
    Keeps old dialog routes functional by reusing the current buy-menu control IDs
    and purchase callbacks instead of pointing at removed legacy handlers.
*/

#define IDD_BUILD_MENU 9060
#define IDC_SUPPLY_COUNT 9001
#define IDC_ITEM_LIST 9002

class MWF_BuildMenu {
    idd = IDD_BUILD_MENU;
    movingEnable = false;
    enableSimulation = true;
    onLoad = "['LightVehicles'] spawn MWF_fnc_updateBuyCategory;";

    class ControlsBackground {
        class Background: GUIBack {
            idc = -1;
            x = 0.35 * safezoneW + safezoneX;
            y = 0.25 * safezoneH + safezoneY;
            w = 0.3 * safezoneW;
            h = 0.5 * safezoneH;
            colorBackground[] = {0.1, 0.1, 0.1, 0.8};
        };

        class TitleBar: RscText {
            idc = -1;
            text = "LOGISTICS & VEHICLE PROCUREMENT";
            x = 0.35 * safezoneW + safezoneX;
            y = 0.22 * safezoneH + safezoneY;
            w = 0.3 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = {0.2, 0.5, 0.2, 1};
        };
    };

    class Controls {
        class BtnInfantry: RscButton {
            idc = -1;
            text = "INF";
            x = 0.36 * safezoneW + safezoneX;
            y = 0.235 * safezoneH + safezoneY;
            w = 0.045 * safezoneW;
            h = 0.03 * safezoneH;
            action = "['Infantry'] spawn MWF_fnc_updateBuyCategory;";
        };

        class BtnLightVehicles: RscButton {
            idc = -1;
            text = "LIGHT";
            x = 0.41 * safezoneW + safezoneX;
            y = 0.235 * safezoneH + safezoneY;
            w = 0.06 * safezoneW;
            h = 0.03 * safezoneH;
            action = "['LightVehicles'] spawn MWF_fnc_updateBuyCategory;";
        };

        class BtnHeavyVehicles: RscButton {
            idc = -1;
            text = "HEAVY";
            x = 0.475 * safezoneW + safezoneX;
            y = 0.235 * safezoneH + safezoneY;
            w = 0.06 * safezoneW;
            h = 0.03 * safezoneH;
            action = "['HeavyVehicles'] spawn MWF_fnc_updateBuyCategory;";
        };

        class SupplyInfo: RscText {
            idc = IDC_SUPPLY_COUNT;
            text = "Supplies: 0";
            style = 1;
            x = 0.54 * safezoneW + safezoneX;
            y = 0.235 * safezoneH + safezoneY;
            w = 0.1 * safezoneW;
            h = 0.03 * safezoneH;
            colorText[] = {0, 1, 0, 1};
        };

        class ItemList: RscListBox {
            idc = IDC_ITEM_LIST;
            x = 0.36 * safezoneW + safezoneX;
            y = 0.27 * safezoneH + safezoneY;
            w = 0.28 * safezoneW;
            h = 0.4 * safezoneH;
            sizeEx = 0.035;
        };

        class BuildButton: RscButton {
            idc = 2200;
            text = "ORDER ASSET";
            x = 0.45 * safezoneW + safezoneX;
            y = 0.68 * safezoneH + safezoneY;
            w = 0.1 * safezoneW;
            h = 0.05 * safezoneH;
            action = "[] spawn MWF_fnc_initiatePurchase;";
        };

        class CloseButton: RscButton {
            idc = -1;
            text = "CLOSE";
            x = 0.36 * safezoneW + safezoneX;
            y = 0.68 * safezoneH + safezoneY;
            w = 0.08 * safezoneW;
            h = 0.05 * safezoneH;
            action = "closeDialog 0;";
        };
    };
};
