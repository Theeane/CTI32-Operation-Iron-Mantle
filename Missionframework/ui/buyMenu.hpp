class IronMantle_BuyMenu {
    idd = 9000;
    movingEnable = false;
    enableSimulation = true;

    class ControlsBackground {
        // Main Window Background
        class MainBG: RscText {
            idc = -1;
            x = 0.25 * safezoneW + safezoneX;
            y = 0.25 * safezoneH + safezoneY;
            w = 0.5 * safezoneW;
            h = 0.5 * safezoneH;
            colorBackground[] = {0.1, 0.1, 0.1, 0.9};
        };
        // Header Bar
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
        // Tab 1: Infantry
        class BtnInf: RscActivePicture {
            text = "\a3\ui_f\data\gui\cfg\hints\infantry_ca.paa";
            x = 0.26 * safezoneW + safezoneX;
            y = 0.21 * safezoneH + safezoneY;
            w = 0.03 * safezoneW; h = 0.03 * safezoneH;
            tooltip = "Infantry";
            action = "['Infantry'] spawn CTI_fnc_updateBuyCategory;";
        };
        // Tab 2: Light Vehicles
        class BtnVeh: RscActivePicture {
            text = "\a3\ui_f\data\gui\cfg\hints\lsv_unarmed_ca.paa";
            x = 0.30 * safezoneW + safezoneX;
            y = 0.21 * safezoneH + safezoneY;
            w = 0.03 * safezoneW; h = 0.03 * safezoneH;
            tooltip = "Light Vehicles";
            action = "['LightVehicles'] spawn CTI_fnc_updateBuyCategory;";
        };
        // Tab 3: Heavy Armor
        class BtnTank: RscActivePicture {
            text = "\a3\ui_f\data\gui\cfg\hints\mbt_ca.paa";
            x = 0.34 * safezoneW + safezoneX;
            y = 0.21 * safezoneH + safezoneY;
            w = 0.03 * safezoneW; h = 0.03 * safezoneH;
            tooltip = "Heavy Armor";
            action = "['HeavyVehicles'] spawn CTI_fnc_updateBuyCategory;";
        };

        // Supply Information Display
        class SupplyInfo: RscText {
            idc = 9001;
            text = "Supplies: 0";
            style = 1; // Right align
            x = 0.60 * safezoneW + safezoneX;
            y = 0.21 * safezoneH + safezoneY;
            w = 0.14 * safezoneW; h = 0.03 * safezoneH;
            colorText[] = {0, 1, 0, 1}; // Green for money/resources
        };

        // Main Item Selection List
        class ListBox: RscListBox {
            idc = 9002;
            x = 0.26 * safezoneW + safezoneX;
            y = 0.27 * safezoneH + safezoneY;
            w = 0.48 * safezoneW;
            h = 0.40 * safezoneH;
        };

        // Purchase Button
        class BuyBtn: RscButton {
            text = "PURCHASE";
            x = 0.60 * safezoneW + safezoneX;
            y = 0.68 * safezoneH + safezoneY;
            w = 0.14 * safezoneW; h = 0.05 * safezoneH;
            colorBackground[] = {0, 0.4, 0, 1}; // Dark green
            action = "[] spawn CTI_fnc_initiatePurchase;";
        };

        // Close/Exit Button
        class CloseBtn: RscButton {
            text = "CLOSE";
            x = 0.26 * safezoneW + safezoneX;
            y = 0.68 * safezoneH + safezoneY;
            w = 0.1 * safezoneW; h = 0.05 * safezoneH;
            action = "closeDialog 0;";
        };
    };
};
