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
        class BackgroundOuter: RscPicture {
            idc = -1;
            text = "ui\terminal_bg.paa";
            x = 0.014 * safezoneW + safezoneX;
            y = 0.004 * safezoneH + safezoneY;
            w = 0.972 * safezoneW;
            h = 0.944 * safezoneH;
        };

        class MainBG: RscText {
            idc = -1;
            x = 0.160 * safezoneW + safezoneX;
            y = 0.145 * safezoneH + safezoneY;
            w = 0.660 * safezoneW;
            h = 0.640 * safezoneH;
            colorBackground[] = {0, 0, 0, 0};
        };

        class HeaderBG: RscText {
            idc = -1;
            x = 0.164 * safezoneW + safezoneX;
            y = 0.149 * safezoneH + safezoneY;
            w = 0.652 * safezoneW;
            h = 0.032 * safezoneH;
            colorBackground[] = {0.12, 0.12, 0.12, 0.88};
        };

        class StatusBG: RscText {
            idc = -1;
            x = 0.186 * safezoneW + safezoneX;
            y = 0.252 * safezoneH + safezoneY;
            w = 0.628 * safezoneW;
            h = 0.442 * safezoneH;
            colorBackground[] = {0, 0, 0, 0.20};
        };
    };

    class Controls {
        class TerminalStatus: RscStructuredText {
            idc = IDC_VEHICLE_TERMINAL_STATUS;
            text = "";
            x = 0.170 * safezoneW + safezoneX;
            y = 0.153 * safezoneH + safezoneY;
            w = 0.640 * safezoneW;
            h = 0.026 * safezoneH;
        };

        class CategoryLabel: RscText {
            idc = IDC_VEHICLE_CATEGORY_TEXT;
            text = "Vehicle Menu";
            x = 0.190 * safezoneW + safezoneX;
            y = 0.614 * safezoneH + safezoneY;
            w = 0.300 * safezoneW;
            h = 0.030 * safezoneH;
        };

        class SupplyInfo: RscText {
            idc = IDC_VEHICLE_SUPPLY_COUNT;
            text = "Supplies: 0";
            style = 1;
            x = 0.514 * safezoneW + safezoneX;
            y = 0.614 * safezoneH + safezoneY;
            w = 0.296 * safezoneW;
            h = 0.030 * safezoneH;
            colorText[] = {0, 1, 0, 1};
        };

        class BtnLightBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.186 * safezoneW + safezoneX;
            y = 0.188 * safezoneH + safezoneY;
            w = 0.108 * safezoneW;
            h = 0.066 * safezoneH;
        };
        class BtnLight: MWF_RscTerminalButton {
            text = "LIGHT";
            x = 0.194 * safezoneW + safezoneX;
            y = 0.198 * safezoneH + safezoneY;
            w = 0.092 * safezoneW;
            h = 0.046 * safezoneH;
            action = "['CATEGORY', objNull, ['LIGHT']] call MWF_fnc_terminal_vehicleMenu;";
        };
        class BtnAPCBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.298 * safezoneW + safezoneX;
            y = 0.188 * safezoneH + safezoneY;
            w = 0.108 * safezoneW;
            h = 0.066 * safezoneH;
        };
        class BtnAPC: MWF_RscTerminalButton {
            text = "APC";
            x = 0.306 * safezoneW + safezoneX;
            y = 0.198 * safezoneH + safezoneY;
            w = 0.092 * safezoneW;
            h = 0.046 * safezoneH;
            action = "['CATEGORY', objNull, ['APC']] call MWF_fnc_terminal_vehicleMenu;";
        };
        class BtnTanksBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.410 * safezoneW + safezoneX;
            y = 0.188 * safezoneH + safezoneY;
            w = 0.108 * safezoneW;
            h = 0.066 * safezoneH;
        };
        class BtnTanks: MWF_RscTerminalButton {
            text = "TANKS";
            x = 0.418 * safezoneW + safezoneX;
            y = 0.198 * safezoneH + safezoneY;
            w = 0.092 * safezoneW;
            h = 0.046 * safezoneH;
            action = "['CATEGORY', objNull, ['TANKS']] call MWF_fnc_terminal_vehicleMenu;";
        };
        class BtnHelisBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.522 * safezoneW + safezoneX;
            y = 0.188 * safezoneH + safezoneY;
            w = 0.108 * safezoneW;
            h = 0.066 * safezoneH;
        };
        class BtnHelis: MWF_RscTerminalButton {
            text = "HELIS";
            x = 0.530 * safezoneW + safezoneX;
            y = 0.198 * safezoneH + safezoneY;
            w = 0.092 * safezoneW;
            h = 0.046 * safezoneH;
            action = "['CATEGORY', objNull, ['HELIS']] call MWF_fnc_terminal_vehicleMenu;";
        };
        class BtnJetsBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.634 * safezoneW + safezoneX;
            y = 0.188 * safezoneH + safezoneY;
            w = 0.108 * safezoneW;
            h = 0.066 * safezoneH;
        };
        class BtnJets: MWF_RscTerminalButton {
            text = "JETS";
            x = 0.642 * safezoneW + safezoneX;
            y = 0.198 * safezoneH + safezoneY;
            w = 0.092 * safezoneW;
            h = 0.046 * safezoneH;
            action = "['CATEGORY', objNull, ['JETS']] call MWF_fnc_terminal_vehicleMenu;";
        };

        class ListStatus: RscText {
            idc = IDC_VEHICLE_LIST_STATUS;
            text = "Entries: 0";
            style = 1;
            x = 0.190 * safezoneW + safezoneX;
            y = 0.260 * safezoneH + safezoneY;
            w = 0.620 * safezoneW;
            h = 0.028 * safezoneH;
            colorText[] = {0.85, 0.85, 0.85, 1};
        };

        class ListBox: RscListBox {
            idc = IDC_VEHICLE_ITEM_LIST;
            x = 0.190 * safezoneW + safezoneX;
            y = 0.292 * safezoneH + safezoneY;
            w = 0.620 * safezoneW;
            h = 0.300 * safezoneH;
            onLBSelChanged = "['SHOW_SELECTION'] call MWF_fnc_terminal_vehicleMenu;";
        };

        class InfoText: RscStructuredText {
            idc = IDC_VEHICLE_INFO_TEXT;
            text = "";
            x = 0.514 * safezoneW + safezoneX;
            y = 0.612 * safezoneH + safezoneY;
            w = 0.296 * safezoneW;
            h = 0.090 * safezoneH;
        };

        class BuildBtnBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.690 * safezoneW + safezoneX;
            y = 0.708 * safezoneH + safezoneY;
            w = 0.126 * safezoneW;
            h = 0.092 * safezoneH;
        };
        class BuildBtn: MWF_RscTerminalButton {
            idc = IDC_VEHICLE_BUILD_BUTTON;
            text = "PURCHASE";
            x = 0.698 * safezoneW + safezoneX;
            y = 0.719 * safezoneH + safezoneY;
            w = 0.110 * safezoneW;
            h = 0.070 * safezoneH;
            action = "[] spawn MWF_fnc_vehicleMenuPurchase;";
        };

        class CloseBtnBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.170 * safezoneW + safezoneX;
            y = 0.708 * safezoneH + safezoneY;
            w = 0.126 * safezoneW;
            h = 0.092 * safezoneH;
        };
        class CloseBtn: MWF_RscTerminalButton {
            text = "CLOSE";
            x = 0.178 * safezoneW + safezoneX;
            y = 0.719 * safezoneH + safezoneY;
            w = 0.110 * safezoneW;
            h = 0.070 * safezoneH;
            action = "closeDialog 0;";
        };
    };
};
