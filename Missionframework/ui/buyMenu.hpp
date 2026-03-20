/*
    Author: Theane / ChatGPT
    Function: buyMenu
    Project: Military War Framework

    Description:
    Preset-driven vehicle menu frontend for the ghost-build purchase flow.
*/

#define IDD_VEHICLE_MENU 9050
#define IDC_VEHICLE_SUPPLY_COUNT 9051
#define IDC_VEHICLE_ITEM_LIST 9052
#define IDC_VEHICLE_CATEGORY_TEXT 9053
#define IDC_VEHICLE_INFO_TEXT 9054
#define IDC_VEHICLE_BUILD_BUTTON 9055

class IronMantle_BuyMenu {
    idd = IDD_VEHICLE_MENU;
    movingEnable = false;
    enableSimulation = true;

    class ControlsBackground {
        class MainBG: RscText {
            idc = -1;
            x = 0.18 * safezoneW + safezoneX;
            y = 0.16 * safezoneH + safezoneY;
            w = 0.64 * safezoneW;
            h = 0.60 * safezoneH;
            colorBackground[] = {0.08, 0.08, 0.08, 0.94};
        };

        class HeaderBG: RscText {
            idc = -1;
            x = 0.18 * safezoneW + safezoneX;
            y = 0.12 * safezoneH + safezoneY;
            w = 0.64 * safezoneW;
            h = 0.05 * safezoneH;
            colorBackground[] = {0.16, 0.16, 0.16, 1};
        };
    };

    class Controls {
        class CategoryLabel: RscText {
            idc = IDC_VEHICLE_CATEGORY_TEXT;
            text = "Vehicle Menu";
            x = 0.20 * safezoneW + safezoneX;
            y = 0.125 * safezoneH + safezoneY;
            w = 0.24 * safezoneW;
            h = 0.035 * safezoneH;
        };

        class SupplyInfo: RscText {
            idc = IDC_VEHICLE_SUPPLY_COUNT;
            text = "Supplies: 0";
            style = 1;
            x = 0.58 * safezoneW + safezoneX;
            y = 0.125 * safezoneH + safezoneY;
            w = 0.22 * safezoneW;
            h = 0.035 * safezoneH;
            colorText[] = {0, 1, 0, 1};
        };

        class BtnLight: RscButton {
            text = "LIGHT";
            x = 0.20 * safezoneW + safezoneX;
            y = 0.19 * safezoneH + safezoneY;
            w = 0.075 * safezoneW;
            h = 0.04 * safezoneH;
            action = "['CATEGORY', objNull, ['LIGHT']] call MWF_fnc_terminal_vehicleMenu;";
        };
        class BtnAPC: RscButton {
            text = "APC";
            x = 0.28 * safezoneW + safezoneX;
            y = 0.19 * safezoneH + safezoneY;
            w = 0.075 * safezoneW;
            h = 0.04 * safezoneH;
            action = "['CATEGORY', objNull, ['APC']] call MWF_fnc_terminal_vehicleMenu;";
        };
        class BtnTanks: RscButton {
            text = "TANKS";
            x = 0.36 * safezoneW + safezoneX;
            y = 0.19 * safezoneH + safezoneY;
            w = 0.075 * safezoneW;
            h = 0.04 * safezoneH;
            action = "['CATEGORY', objNull, ['TANKS']] call MWF_fnc_terminal_vehicleMenu;";
        };
        class BtnHelis: RscButton {
            text = "HELIS";
            x = 0.44 * safezoneW + safezoneX;
            y = 0.19 * safezoneH + safezoneY;
            w = 0.075 * safezoneW;
            h = 0.04 * safezoneH;
            action = "['CATEGORY', objNull, ['HELIS']] call MWF_fnc_terminal_vehicleMenu;";
        };
        class BtnJets: RscButton {
            text = "JETS";
            x = 0.52 * safezoneW + safezoneX;
            y = 0.19 * safezoneH + safezoneY;
            w = 0.075 * safezoneW;
            h = 0.04 * safezoneH;
            action = "['CATEGORY', objNull, ['JETS']] call MWF_fnc_terminal_vehicleMenu;";
        };

        class ListBox: RscListBox {
            idc = IDC_VEHICLE_ITEM_LIST;
            x = 0.20 * safezoneW + safezoneX;
            y = 0.25 * safezoneH + safezoneY;
            w = 0.38 * safezoneW;
            h = 0.42 * safezoneH;
            onLBSelChanged = "['SHOW_SELECTION'] call MWF_fnc_terminal_vehicleMenu;";
        };

        class InfoText: RscStructuredText {
            idc = IDC_VEHICLE_INFO_TEXT;
            text = "";
            x = 0.60 * safezoneW + safezoneX;
            y = 0.25 * safezoneH + safezoneY;
            w = 0.18 * safezoneW;
            h = 0.34 * safezoneH;
        };

        class BuildBtn: RscButton {
            idc = IDC_VEHICLE_BUILD_BUTTON;
            text = "BUILD";
            x = 0.60 * safezoneW + safezoneX;
            y = 0.62 * safezoneH + safezoneY;
            w = 0.18 * safezoneW;
            h = 0.05 * safezoneH;
            colorBackground[] = {0, 0.35, 0, 1};
            action = "['PURCHASE'] call MWF_fnc_terminal_vehicleMenu;";
        };

        class CloseBtn: RscButton {
            text = "CLOSE";
            x = 0.20 * safezoneW + safezoneX;
            y = 0.69 * safezoneH + safezoneY;
            w = 0.12 * safezoneW;
            h = 0.05 * safezoneH;
            action = "closeDialog 0;";
        };
    };
};
