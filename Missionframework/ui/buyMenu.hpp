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
#define IDC_VEHICLE_LIST_STATUS 9056
#define IDC_VEHICLE_TERMINAL_STATUS 9057

class IronMantle_BuyMenu {
    idd = IDD_VEHICLE_MENU;
    movingEnable = false;
    enableSimulation = true;

    class ControlsBackground {
        class MainBG: RscText {
            idc = -1;
            x = 0.15 * safezoneW + safezoneX;
            y = 0.15 * safezoneH + safezoneY;
            w = 0.70 * safezoneW;
            h = 0.63 * safezoneH;
            colorBackground[] = {0.08, 0.08, 0.08, 0.94};
        };

        class HeaderBG: RscText {
            idc = -1;
            x = 0.15 * safezoneW + safezoneX;
            y = 0.10 * safezoneH + safezoneY;
            w = 0.70 * safezoneW;
            h = 0.045 * safezoneH;
            colorBackground[] = {0.16, 0.16, 0.16, 1};
        };

        class StatusBG: RscText {
            idc = -1;
            x = 0.17 * safezoneW + safezoneX;
            y = 0.165 * safezoneH + safezoneY;
            w = 0.66 * safezoneW;
            h = 0.055 * safezoneH;
            colorBackground[] = {0.12, 0.12, 0.12, 0.85};
        };
    };

    class Controls {
        class TerminalStatus: RscStructuredText {
            idc = IDC_VEHICLE_TERMINAL_STATUS;
            text = "";
            x = 0.18 * safezoneW + safezoneX;
            y = 0.172 * safezoneH + safezoneY;
            w = 0.64 * safezoneW;
            h = 0.045 * safezoneH;
        };

        class CategoryLabel: RscText {
            idc = IDC_VEHICLE_CATEGORY_TEXT;
            text = "Vehicle Menu";
            x = 0.18 * safezoneW + safezoneX;
            y = 0.112 * safezoneH + safezoneY;
            w = 0.30 * safezoneW;
            h = 0.03 * safezoneH;
        };

        class SupplyInfo: RscText {
            idc = IDC_VEHICLE_SUPPLY_COUNT;
            text = "Supplies: 0";
            style = 1;
            x = 0.60 * safezoneW + safezoneX;
            y = 0.112 * safezoneH + safezoneY;
            w = 0.23 * safezoneW;
            h = 0.03 * safezoneH;
            colorText[] = {0, 1, 0, 1};
        };

        class BtnLight: RscButton {
            text = "LIGHT";
            x = 0.18 * safezoneW + safezoneX;
            y = 0.235 * safezoneH + safezoneY;
            w = 0.078 * safezoneW;
            h = 0.04 * safezoneH;
            action = "['CATEGORY', objNull, ['LIGHT']] call MWF_fnc_terminal_vehicleMenu;";
        };
        class BtnAPC: RscButton {
            text = "APC";
            x = 0.262 * safezoneW + safezoneX;
            y = 0.235 * safezoneH + safezoneY;
            w = 0.078 * safezoneW;
            h = 0.04 * safezoneH;
            action = "['CATEGORY', objNull, ['APC']] call MWF_fnc_terminal_vehicleMenu;";
        };
        class BtnTanks: RscButton {
            text = "TANKS";
            x = 0.344 * safezoneW + safezoneX;
            y = 0.235 * safezoneH + safezoneY;
            w = 0.078 * safezoneW;
            h = 0.04 * safezoneH;
            action = "['CATEGORY', objNull, ['TANKS']] call MWF_fnc_terminal_vehicleMenu;";
        };
        class BtnHelis: RscButton {
            text = "HELIS";
            x = 0.426 * safezoneW + safezoneX;
            y = 0.235 * safezoneH + safezoneY;
            w = 0.078 * safezoneW;
            h = 0.04 * safezoneH;
            action = "['CATEGORY', objNull, ['HELIS']] call MWF_fnc_terminal_vehicleMenu;";
        };
        class BtnJets: RscButton {
            text = "JETS";
            x = 0.508 * safezoneW + safezoneX;
            y = 0.235 * safezoneH + safezoneY;
            w = 0.078 * safezoneW;
            h = 0.04 * safezoneH;
            action = "['CATEGORY', objNull, ['JETS']] call MWF_fnc_terminal_vehicleMenu;";
        };

        class ListStatus: RscText {
            idc = IDC_VEHICLE_LIST_STATUS;
            text = "Entries: 0";
            style = 1;
            x = 0.18 * safezoneW + safezoneX;
            y = 0.282 * safezoneH + safezoneY;
            w = 0.40 * safezoneW;
            h = 0.024 * safezoneH;
            colorText[] = {0.85, 0.85, 0.85, 1};
        };

        class ListBox: RscListBox {
            idc = IDC_VEHICLE_ITEM_LIST;
            x = 0.18 * safezoneW + safezoneX;
            y = 0.308 * safezoneH + safezoneY;
            w = 0.40 * safezoneW;
            h = 0.39 * safezoneH;
            onLBSelChanged = "['SHOW_SELECTION'] call MWF_fnc_terminal_vehicleMenu;";
        };

        class InfoText: RscStructuredText {
            idc = IDC_VEHICLE_INFO_TEXT;
            text = "";
            x = 0.60 * safezoneW + safezoneX;
            y = 0.308 * safezoneH + safezoneY;
            w = 0.22 * safezoneW;
            h = 0.31 * safezoneH;
        };

        class BuildBtn: RscButton {
            idc = IDC_VEHICLE_BUILD_BUTTON;
            text = "BUILD";
            x = 0.60 * safezoneW + safezoneX;
            y = 0.648 * safezoneH + safezoneY;
            w = 0.22 * safezoneW;
            h = 0.05 * safezoneH;
            colorBackground[] = {0, 0.35, 0, 1};
            action = "['PURCHASE'] call MWF_fnc_terminal_vehicleMenu;";
        };

        class CloseBtn: RscButton {
            text = "CLOSE";
            x = 0.18 * safezoneW + safezoneX;
            y = 0.72 * safezoneH + safezoneY;
            w = 0.12 * safezoneW;
            h = 0.045 * safezoneH;
            action = "closeDialog 0;";
        };
    };
};
