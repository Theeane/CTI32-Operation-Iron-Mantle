/*
    Author: Theane / ChatGPT
    Function: buyMenu
    Project: Military War Framework

    Description:
    Separate terminal-style vehicle purchase dialog.
*/

#define IDD_VEHICLE_MENU 9050
#define IDC_VEHICLE_SUPPLY_COUNT 9051
#define IDC_VEHICLE_ITEM_LIST 9052
#define IDC_VEHICLE_CATEGORY_TEXT 9053
#define IDC_VEHICLE_INFO_TEXT 9054
#define IDC_VEHICLE_BUILD_BUTTON 9055
#define IDC_VEHICLE_LIST_STATUS 9056
#define IDC_VEHICLE_TERMINAL_STATUS 9057
#define IDC_VEHICLE_ICON_PICTURE 9058
#define IDC_VEHICLE_BTN_LIGHT 9060
#define IDC_VEHICLE_BTN_APC 9061
#define IDC_VEHICLE_BTN_TANKS 9062
#define IDC_VEHICLE_BTN_HELIS 9063
#define IDC_VEHICLE_BTN_JETS 9064

class IronMantle_BuyMenu {
    idd = IDD_VEHICLE_MENU;
    movingEnable = false;
    enableSimulation = true;

    class Controls {
        class BackgroundOuter: RscPicture {
            idc = -1;
            text = "ui\terminal_bg.paa";
            x = 0.018 * safezoneW + safezoneX;
            y = 0.010 * safezoneH + safezoneY;
            w = 0.964 * safezoneW;
            h = 0.930 * safezoneH;
        };

        class HeaderBG: RscText {
            idc = -1;
            x = 0.160 * safezoneW + safezoneX;
            y = 0.145 * safezoneH + safezoneY;
            w = 0.660 * safezoneW;
            h = 0.032 * safezoneH;
            colorBackground[] = {0.12, 0.12, 0.12, 0.88};
        };

        class HeaderText: RscText {
            idc = IDC_VEHICLE_CATEGORY_TEXT;
            text = "Vehicle Menu";
            x = 0.170 * safezoneW + safezoneX;
            y = 0.149 * safezoneH + safezoneY;
            w = 0.330 * safezoneW;
            h = 0.026 * safezoneH;
        };

        class SupplyInfo: RscText {
            idc = IDC_VEHICLE_SUPPLY_COUNT;
            text = "Supplies: 0";
            style = 1;
            x = 0.620 * safezoneW + safezoneX;
            y = 0.149 * safezoneH + safezoneY;
            w = 0.190 * safezoneW;
            h = 0.026 * safezoneH;
            colorText[] = {0.65, 1, 0.65, 1};
        };

        class TerminalStatusBG: RscText {
            idc = -1;
            x = 0.166 * safezoneW + safezoneX;
            y = 0.183 * safezoneH + safezoneY;
            w = 0.648 * safezoneW;
            h = 0.040 * safezoneH;
            colorBackground[] = {0.08, 0.08, 0.08, 0.78};
        };

        class TerminalStatusText: RscStructuredText {
            idc = IDC_VEHICLE_TERMINAL_STATUS;
            text = "";
            x = 0.172 * safezoneW + safezoneX;
            y = 0.190 * safezoneH + safezoneY;
            w = 0.636 * safezoneW;
            h = 0.026 * safezoneH;
        };

        class BtnLightBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.170 * safezoneW + safezoneX;
            y = 0.236 * safezoneH + safezoneY;
            w = 0.106 * safezoneW;
            h = 0.070 * safezoneH;
        };
        class BtnLight: MWF_RscTerminalButton {
            idc = IDC_VEHICLE_BTN_LIGHT;
            text = "Cars";
            x = 0.178 * safezoneW + safezoneX;
            y = 0.247 * safezoneH + safezoneY;
            w = 0.090 * safezoneW;
            h = 0.048 * safezoneH;
            action = "['CATEGORY', objNull, ['LIGHT']] call MWF_fnc_terminal_vehicleMenu;";
        };

        class BtnAPCBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.282 * safezoneW + safezoneX;
            y = 0.236 * safezoneH + safezoneY;
            w = 0.106 * safezoneW;
            h = 0.070 * safezoneH;
        };
        class BtnAPC: MWF_RscTerminalButton {
            idc = IDC_VEHICLE_BTN_APC;
            text = "APC";
            x = 0.290 * safezoneW + safezoneX;
            y = 0.247 * safezoneH + safezoneY;
            w = 0.090 * safezoneW;
            h = 0.048 * safezoneH;
            action = "['CATEGORY', objNull, ['APC']] call MWF_fnc_terminal_vehicleMenu;";
        };

        class BtnTanksBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.394 * safezoneW + safezoneX;
            y = 0.236 * safezoneH + safezoneY;
            w = 0.106 * safezoneW;
            h = 0.070 * safezoneH;
        };
        class BtnTanks: MWF_RscTerminalButton {
            idc = IDC_VEHICLE_BTN_TANKS;
            text = "Tanks";
            x = 0.402 * safezoneW + safezoneX;
            y = 0.247 * safezoneH + safezoneY;
            w = 0.090 * safezoneW;
            h = 0.048 * safezoneH;
            action = "['CATEGORY', objNull, ['TANKS']] call MWF_fnc_terminal_vehicleMenu;";
        };

        class BtnHelisBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.506 * safezoneW + safezoneX;
            y = 0.236 * safezoneH + safezoneY;
            w = 0.106 * safezoneW;
            h = 0.070 * safezoneH;
        };
        class BtnHelis: MWF_RscTerminalButton {
            idc = IDC_VEHICLE_BTN_HELIS;
            text = "Helis";
            x = 0.514 * safezoneW + safezoneX;
            y = 0.247 * safezoneH + safezoneY;
            w = 0.090 * safezoneW;
            h = 0.048 * safezoneH;
            action = "['CATEGORY', objNull, ['HELIS']] call MWF_fnc_terminal_vehicleMenu;";
        };

        class BtnJetsBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.618 * safezoneW + safezoneX;
            y = 0.236 * safezoneH + safezoneY;
            w = 0.106 * safezoneW;
            h = 0.070 * safezoneH;
        };
        class BtnJets: MWF_RscTerminalButton {
            idc = IDC_VEHICLE_BTN_JETS;
            text = "Jets";
            x = 0.626 * safezoneW + safezoneX;
            y = 0.247 * safezoneH + safezoneY;
            w = 0.090 * safezoneW;
            h = 0.048 * safezoneH;
            action = "['CATEGORY', objNull, ['JETS']] call MWF_fnc_terminal_vehicleMenu;";
        };

        class ListBG: RscText {
            idc = -1;
            x = 0.168 * safezoneW + safezoneX;
            y = 0.315 * safezoneH + safezoneY;
            w = 0.360 * safezoneW;
            h = 0.430 * safezoneH;
            colorBackground[] = {0.03, 0.03, 0.03, 0.82};
        };

        class InfoBG: RscText {
            idc = -1;
            x = 0.538 * safezoneW + safezoneX;
            y = 0.315 * safezoneH + safezoneY;
            w = 0.276 * safezoneW;
            h = 0.430 * safezoneH;
            colorBackground[] = {0.03, 0.03, 0.03, 0.70};
        };

        class ListStatus: RscText {
            idc = IDC_VEHICLE_LIST_STATUS;
            text = "Entries: 0";
            x = 0.176 * safezoneW + safezoneX;
            y = 0.286 * safezoneH + safezoneY;
            w = 0.340 * safezoneW;
            h = 0.020 * safezoneH;
            colorText[] = {0.82, 0.82, 0.82, 1};
        };

        class ListBox: RscListBox {
            idc = IDC_VEHICLE_ITEM_LIST;
            x = 0.176 * safezoneW + safezoneX;
            y = 0.322 * safezoneH + safezoneY;
            w = 0.344 * safezoneW;
            h = 0.410 * safezoneH;
            rowHeight = 0.040 * safezoneH;
            colorBackground[] = {0, 0, 0, 0.20};
            colorSelectBackground[] = {0.82, 0.82, 0.82, 0.18};
            colorSelectBackground2[] = {0.82, 0.82, 0.82, 0.18};
            onLBSelChanged = "['SHOW_SELECTION'] call MWF_fnc_terminal_vehicleMenu;";
        };

        class InfoIcon: RscPicture {
            idc = IDC_VEHICLE_ICON_PICTURE;
            text = "";
            x = 0.560 * safezoneW + safezoneX;
            y = 0.338 * safezoneH + safezoneY;
            w = 0.060 * safezoneW;
            h = 0.070 * safezoneH;
        };

        class InfoText: RscStructuredText {
            idc = IDC_VEHICLE_INFO_TEXT;
            text = "";
            x = 0.630 * safezoneW + safezoneX;
            y = 0.334 * safezoneH + safezoneY;
            w = 0.170 * safezoneW;
            h = 0.360 * safezoneH;
        };

        class BtnBackBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.170 * safezoneW + safezoneX;
            y = 0.748 * safezoneH + safezoneY;
            w = 0.126 * safezoneW;
            h = 0.080 * safezoneH;
        };
        class CloseBtn: MWF_RscTerminalButton {
            text = "Back";
            x = 0.178 * safezoneW + safezoneX;
            y = 0.759 * safezoneH + safezoneY;
            w = 0.110 * safezoneW;
            h = 0.058 * safezoneH;
            action = "closeDialog 0;";
        };

        class BtnPurchaseBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.688 * safezoneW + safezoneX;
            y = 0.748 * safezoneH + safezoneY;
            w = 0.126 * safezoneW;
            h = 0.080 * safezoneH;
        };
        class BuildBtn: MWF_RscTerminalButton {
            idc = IDC_VEHICLE_BUILD_BUTTON;
            text = "Purchase";
            x = 0.696 * safezoneW + safezoneX;
            y = 0.759 * safezoneH + safezoneY;
            w = 0.110 * safezoneW;
            h = 0.058 * safezoneH;
            action = "['PURCHASE'] call MWF_fnc_terminal_vehicleMenu;";
        };
    };
};
