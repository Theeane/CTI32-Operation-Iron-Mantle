class IronMantle_BuyMenu {
    idd = 9000;
    movingEnable = false;
    enableSimulation = true;

    class ControlsBackground {
        // Huvudfönster - Mörkgrå
        class MainBG: RscText {
            idc = -1;
            x = 0.25 * safezoneW + safezoneX;
            y = 0.25 * safezoneH + safezoneY;
            w = 0.5 * safezoneW;
            h = 0.5 * safezoneH;
            colorBackground[] = {0.1, 0.1, 0.1, 0.9};
        };
        // Header bar
        class HeaderBG: RscText {
            idc = -1;
            x = 0.25 * safezoneW + safezoneX;
            y = 0.2 * safezoneH + safezoneY;
            w = 0.5 * safezoneW;
            h = 0.05 * safezoneH;
            colorBackground[] = {0.2, 0.2, 0.2, 1};
        };
    };

    class Controls {
        // Flik 1: Infanteri
        class BtnInf: RscActivePicture {
            text = "\a3\ui_f\data\gui\cfg\hints\infantry_ca.paa";
            x = 0.26 * safezoneW + safezoneX;
            y = 0.21 * safezoneH + safezoneY;
            w = 0.03 * safezoneW; h = 0.03 * safezoneH;
            tooltip = "Infanteri";
            action = "['Infantry'] spawn CTI_fnc_updateBuyCategory;";
        };
        // Flik 2: Bilar
        class BtnVeh: RscActivePicture {
            text = "\a3\ui_f\data\gui\cfg\hints\lsv_unarmed_ca.paa";
            x = 0.30 * safezoneW + safezoneX;
            y = 0.21 * safezoneH + safezoneY;
            w = 0.03 * safezoneW; h = 0.03 * safezoneH;
            tooltip = "Fordon";
            action = "['LightVehicles'] spawn CTI_fnc_updateBuyCategory;";
        };

        // Supply info
        class SupplyInfo: RscText {
            idc = 9001;
            text = "Supplies: 0";
            style = 1; // Right align
            x = 0.60 * safezoneW + safezoneX;
            y = 0.21 * safezoneH + safezoneY;
            w = 0.14 * safezoneW; h = 0.03 * safezoneH;
            colorText[] = {0, 1, 0, 1};
        };

        // Listan med saker (Baserat på din bild)
        class ListBox: RscListBox {
            idc = 9002;
            x = 0.26 * safezoneW + safezoneX;
            y = 0.27 * safezoneH + safezoneY;
            w = 0.48 * safezoneW;
            h = 0.40 * safezoneH;
        };

        // Köpknapp
        class BuyBtn: RscButton {
            text = "KÖP";
            x = 0.60 * safezoneW + safezoneX;
            y = 0.68 * safezoneH + safezoneY;
            w = 0.14 * safezoneW; h = 0.05 * safezoneH;
            colorBackground[] = {0, 0.5, 0, 1};
            action = "[] spawn CTI_fnc_initiatePurchase;";
        };

        // Stängknapp
        class CloseBtn: RscButton {
            text = "STÄNG";
            x = 0.26 * safezoneW + safezoneX;
            y = 0.68 * safezoneH + safezoneY;
            w = 0.1 * safezoneW; h = 0.05 * safezoneH;
            action = "closeDialog 0;";
        };
    };
};
