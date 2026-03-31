/*
    Author: Theane / ChatGPT
    Function: buyMenu
    Project: Military War Framework

    Description:
    Preset-driven vehicle menu frontend for the ghost-build purchase flow.
    Rebuilt to match the terminal shell style.
*/

#define IDD_VEHICLE_MENU 9050
#define IDC_VEHICLE_SUPPLY_COUNT 9051
#define IDC_VEHICLE_ITEM_LIST 9052
#define IDC_VEHICLE_CATEGORY_TEXT 9053
#define IDC_VEHICLE_INFO_TEXT 9054
#define IDC_VEHICLE_BUILD_BUTTON 9055
#define IDC_VEHICLE_LIST_STATUS 9056
#define IDC_VEHICLE_TERMINAL_STATUS 9057
#define IDC_VEHICLE_PREVIEW_PIC 9058

class IronMantle_BuyMenu {
    idd = IDD_VEHICLE_MENU;
    movingEnable = false;
    enableSimulation = true;

    class Controls {
        class BackgroundOuter: RscPicture {
            idc = -1;
            text = "ui\terminal_bg.paa";
            x = 0.014 * safezoneW + safezoneX;
            y = 0.004 * safezoneH + safezoneY;
            w = 0.972 * safezoneW;
            h = 0.944 * safezoneH;
        };

        class BackgroundInner: RscText {
            idc = -1;
            x = 0.160 * safezoneW + safezoneX;
            y = 0.145 * safezoneH + safezoneY;
            w = 0.660 * safezoneW;
            h = 0.640 * safezoneH;
            colorBackground[] = {0,0,0,0};
        };

        class TerminalStatusBG: RscText {
            idc = -1;
            x = 0.164 * safezoneW + safezoneX;
            y = 0.149 * safezoneH + safezoneY;
            w = 0.652 * safezoneW;
            h = 0.032 * safezoneH;
            colorBackground[] = {0.12,0.12,0.12,0.88};
        };

        class TerminalStatus: RscStructuredText {
            idc = IDC_VEHICLE_TERMINAL_STATUS;
            text = "";
            x = 0.170 * safezoneW + safezoneX;
            y = 0.153 * safezoneH + safezoneY;
            w = 0.640 * safezoneW;
            h = 0.026 * safezoneH;
        };

        class HeaderTitle: RscText {
            idc = IDC_VEHICLE_CATEGORY_TEXT;
            text = "Vehicle Menu | Cars";
            x = 0.170 * safezoneW + safezoneX;
            y = 0.112 * safezoneH + safezoneY;
            w = 0.320 * safezoneW;
            h = 0.028 * safezoneH;
            colorText[] = {1,1,1,1};
            shadow = 0;
        };

        class SupplyInfo: RscText {
            idc = IDC_VEHICLE_SUPPLY_COUNT;
            text = "Supplies: 0";
            style = 1;
            x = 0.640 * safezoneW + safezoneX;
            y = 0.112 * safezoneH + safezoneY;
            w = 0.170 * safezoneW;
            h = 0.028 * safezoneH;
            colorText[] = {0,1,0,1};
            shadow = 0;
        };

        class BtnLightBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.176 * safezoneW + safezoneX;
            y = 0.196 * safezoneH + safezoneY;
            w = 0.102 * safezoneW;
            h = 0.072 * safezoneH;
        };
        class BtnLight: MWF_RscTerminalButton {
            text = "Cars";
            x = 0.186 * safezoneW + safezoneX;
            y = 0.205 * safezoneH + safezoneY;
            w = 0.082 * safezoneW;
            h = 0.054 * safezoneH;
            action = "['CATEGORY', objNull, ['LIGHT']] call MWF_fnc_terminal_vehicleMenu;";
        };

        class BtnAPCBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.294 * safezoneW + safezoneX;
            y = 0.196 * safezoneH + safezoneY;
            w = 0.102 * safezoneW;
            h = 0.072 * safezoneH;
        };
        class BtnAPC: MWF_RscTerminalButton {
            text = "APC";
            x = 0.304 * safezoneW + safezoneX;
            y = 0.205 * safezoneH + safezoneY;
            w = 0.082 * safezoneW;
            h = 0.054 * safezoneH;
            action = "['CATEGORY', objNull, ['APC']] call MWF_fnc_terminal_vehicleMenu;";
        };

        class BtnTanksBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.412 * safezoneW + safezoneX;
            y = 0.196 * safezoneH + safezoneY;
            w = 0.102 * safezoneW;
            h = 0.072 * safezoneH;
        };
        class BtnTanks: MWF_RscTerminalButton {
            text = "Tanks";
            x = 0.422 * safezoneW + safezoneX;
            y = 0.205 * safezoneH + safezoneY;
            w = 0.082 * safezoneW;
            h = 0.054 * safezoneH;
            action = "['CATEGORY', objNull, ['TANKS']] call MWF_fnc_terminal_vehicleMenu;";
        };

        class BtnHelisBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.530 * safezoneW + safezoneX;
            y = 0.196 * safezoneH + safezoneY;
            w = 0.102 * safezoneW;
            h = 0.072 * safezoneH;
        };
        class BtnHelis: MWF_RscTerminalButton {
            text = "Helis";
            x = 0.540 * safezoneW + safezoneX;
            y = 0.205 * safezoneH + safezoneY;
            w = 0.082 * safezoneW;
            h = 0.054 * safezoneH;
            action = "['CATEGORY', objNull, ['HELIS']] call MWF_fnc_terminal_vehicleMenu;";
        };

        class BtnJetsBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.648 * safezoneW + safezoneX;
            y = 0.196 * safezoneH + safezoneY;
            w = 0.102 * safezoneW;
            h = 0.072 * safezoneH;
        };
        class BtnJets: MWF_RscTerminalButton {
            text = "Jets";
            x = 0.658 * safezoneW + safezoneX;
            y = 0.205 * safezoneH + safezoneY;
            w = 0.082 * safezoneW;
            h = 0.054 * safezoneH;
            action = "['CATEGORY', objNull, ['JETS']] call MWF_fnc_terminal_vehicleMenu;";
        };

        class ListFrame: RscText {
            idc = -1;
            x = 0.188 * safezoneW + safezoneX;
            y = 0.280 * safezoneH + safezoneY;
            w = 0.390 * safezoneW;
            h = 0.340 * safezoneH;
            colorBackground[] = {0,0,0,0.18};
        };

        class ListStatus: RscText {
            idc = IDC_VEHICLE_LIST_STATUS;
            text = "Entries in LIGHT: 0";
            style = 1;
            x = 0.482 * safezoneW + safezoneX;
            y = 0.272 * safezoneH + safezoneY;
            w = 0.320 * safezoneW;
            h = 0.024 * safezoneH;
            colorText[] = {1,1,1,1};
            shadow = 0;
        };

        class ListBox: RscListBox {
            idc = IDC_VEHICLE_ITEM_LIST;
            x = 0.190 * safezoneW + safezoneX;
            y = 0.284 * safezoneH + safezoneY;
            w = 0.386 * safezoneW;
            h = 0.335 * safezoneH;
            onLBSelChanged = "['SHOW_SELECTION'] call MWF_fnc_terminal_vehicleMenu;";
        };

        class PreviewPicture: RscPicture {
            idc = IDC_VEHICLE_PREVIEW_PIC;
            text = "";
            x = 0.610 * safezoneW + safezoneX;
            y = 0.340 * safezoneH + safezoneY;
            w = 0.070 * safezoneW;
            h = 0.110 * safezoneH;
        };

        class InfoText: RscStructuredText {
            idc = IDC_VEHICLE_INFO_TEXT;
            text = "";
            x = 0.685 * safezoneW + safezoneX;
            y = 0.320 * safezoneH + safezoneY;
            w = 0.120 * safezoneW;
            h = 0.255 * safezoneH;
        };

        class BtnBackBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.186 * safezoneW + safezoneX;
            y = 0.682 * safezoneH + safezoneY;
            w = 0.112 * safezoneW;
            h = 0.084 * safezoneH;
        };
        class CloseBtn: MWF_RscTerminalButton {
            text = "Back";
            x = 0.198 * safezoneW + safezoneX;
            y = 0.692 * safezoneH + safezoneY;
            w = 0.088 * safezoneW;
            h = 0.060 * safezoneH;
            action = "closeDialog 0;";
        };

        class BtnPurchaseBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.684 * safezoneW + safezoneX;
            y = 0.682 * safezoneH + safezoneY;
            w = 0.112 * safezoneW;
            h = 0.084 * safezoneH;
        };
        class BuildBtn: MWF_RscTerminalButton {
            idc = IDC_VEHICLE_BUILD_BUTTON;
            text = "Purchase";
            x = 0.696 * safezoneW + safezoneX;
            y = 0.692 * safezoneH + safezoneY;
            w = 0.088 * safezoneW;
            h = 0.060 * safezoneH;
            action = "[] call MWF_fnc_vehicleMenuPurchase;";
        };
    };
};
