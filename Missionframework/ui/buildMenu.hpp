/*
    Author: Theane (AGS Project)
    Description: UI for the Logistics / Vehicle Build Menu.
    Language: English
*/

class AGS_BuildMenu {
    idd = 9000;
    movingEnable = false;
    
    class Controls {
        // Main Background
        class Background: IGUIBack {
            idc = 2000;
            x = 0.35 * safezoneW + safezoneX;
            y = 0.25 * safezoneH + safezoneY;
            w = 0.3 * safezoneW;
            h = 0.5 * safezoneH;
            colorBackground[] = {0.1, 0.1, 0.1, 0.8};
        };

        // Title Bar
        class Title: RscText {
            idc = 2001;
            text = "LOGISTICS & VEHICLE PROCUREMENT";
            x = 0.35 * safezoneW + safezoneX;
            y = 0.22 * safezoneH + safezoneY;
            w = 0.3 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = {0.2, 0.5, 0.2, 1}; // Green theme for logistics
        };

        // The List of Vehicles/Crates
        class ItemList: RscListBox {
            idc = 2100;
            x = 0.36 * safezoneW + safezoneX;
            y = 0.27 * safezoneH + safezoneY;
            w = 0.28 * safezoneW;
            h = 0.4 * safezoneH;
            sizeEx = 0.035;
        };

        // Confirm Button
        class BuildButton: RscButton {
            idc = 2200;
            text = "ORDER ASSET";
            x = 0.45 * safezoneW + safezoneX;
            y = 0.68 * safezoneH + safezoneY;
            w = 0.1 * safezoneW;
            h = 0.05 * safezoneH;
            action = "[] spawn AGS_fnc_requestPaidBuild;";
        };
    };
};
