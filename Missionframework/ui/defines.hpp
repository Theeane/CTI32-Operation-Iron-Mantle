/*
    Author: Theane / Gemini
    Project: Military War Framework
    Description: Terminal UI Layout based on Untitled1.png
*/

class MWF_Terminal_Dialog {
    idd = 9000;
    movingEnable = false;
    enableSimulation = true;

    // --- BAKGRUNDSLAGER ---
    class ControlsBackground {
        // Huvudramen för terminalen
        class MainBackground: RscPicture {
            idc = -1;
            text = "Missionframework\ui\terminal_bg.paa";
            x = 0.05 * safezoneW + safezoneX;
            y = 0.05 * safezoneH + safezoneY;
            w = 0.9 * safezoneW;
            h = 0.9 * safezoneH;
        };

        // En mörk toning för kartytan i mitten
        class MapAreaBackground: RscText {
            idc = -1;
            colorBackground[] = {0, 0, 0, 0.3};
            x = 0.15 * safezoneW + safezoneX;
            y = 0.22 * safezoneH + safezoneY;
            w = 0.7 * safezoneW;
            h = 0.56 * safezoneH;
        };
    };

    // --- INTERAKTIVA KONTROLLER ---
    class Controls {
        // --- STATUS BAR (Toppen av terminalen) ---
        class StatusInfo: RscText {
            idc = 9200;
            text = "SUPPLIES: 0 | INTEL: 0 | THREAT: 0%";
            style = 0x02; // Center
            colorText[] = {0.7, 0.9, 0.7, 1}; // Grönaktig militär text
            x = 0.35 * safezoneW + safezoneX;
            y = 0.07 * safezoneH + safezoneY;
            w = 0.3 * safezoneW;
            h = 0.04 * safezoneH;
        };

        // --- TOPPARADEN (Logistik & Strategi) ---
        class Btn_Vehicles: RscStandardButton {
            idc = 9101; 
            text = "VEHICLES";
            x = 0.14 * safezoneW + safezoneX; 
            y = 0.13 * safezoneH + safezoneY;
            w = 0.12 * safezoneW; 
            h = 0.06 * safezoneH;
            onButtonClick = "hint 'Accessing Vehicle Logistics...';";
        };

        class Btn_Base: RscStandardButton {
            idc = 9102; 
            text = "BASE";
            x = 0.28 * safezoneW + safezoneX; 
            y = 0.13 * safezoneH + safezoneY;
            w = 0.12 * safezoneW; 
            h = 0.06 * safezoneH;
            onButtonClick = "hint 'Accessing Base Operations...';";
        };

        class Btn_Support: RscStandardButton {
            idc = 9103; 
            text = "SUPPORT";
            x = 0.42 * safezoneW + safezoneX; 
            y = 0.13 * safezoneH + safezoneY;
            w = 0.12 * safezoneW; 
            h = 0.06 * safezoneH;
            onButtonClick = "hint 'Requesting Tactical Support...';";
        };

        class Btn_Upgrades: RscStandardButton {
            idc = 9104; 
            text = "UPGRADES";
            x = 0.56 * safezoneW + safezoneX; 
            y = 0.13 * safezoneH + safezoneY;
            w = 0.12 * safezoneW; 
            h = 0.06 * safezoneH;
            onButtonClick = "hint 'Technological Upgrades...';";
        };

        class Btn_Intel: RscStandardButton {
            idc = 9105; 
            text = "INTEL";
            x = 0.70 * safezoneW + safezoneX; 
            y = 0.13 * safezoneH + safezoneY;
            w = 0.12 * safezoneW; 
            h = 0.06 * safezoneH;
            onButtonClick = "hint 'Analyzing Intelligence...';";
        };

        // --- MITTEN (KARTAN) ---
        // Vi använder RscListBox som platshållare tills vi kopplar riktig karta
        class MapPlaceholder: RscText {
            idc = 9999;
            text = "STRATEGIC MAP OVERLAY";
            style = 0x02 + 0x10; // Center + Border
            x = 0.15 * safezoneW + safezoneX;
            y = 0.22 * safezoneH + safezoneY;
            w = 0.7 * safezoneW;
            h = 0.56 * safezoneH;
        };

        // --- BOTTENRADEN (Uppdrag & Förflyttning) ---
        class Btn_Missions: RscStandardButton {
            idc = 9106; 
            text = "MISSIONS";
            x = 0.14 * safezoneW + safezoneX; 
            y = 0.82 * safezoneH + safezoneY;
            w = 0.16 * safezoneW; 
            h = 0.07 * safezoneH;
            onButtonClick = "hint 'Opening Mission Board...';";
        };

        class Btn_Redeploy: RscStandardButton {
            idc = 9107; 
            text = "REDEPLOY";
            x = 0.66 * safezoneW + safezoneX; 
            y = 0.82 * safezoneH + safezoneY;
            w = 0.16 * safezoneW; 
            h = 0.07 * safezoneH;
            onButtonClick = "hint 'Initiating Redeploy Sequence...';";
        };

        // Stäng-knapp (Liten knapp i hörnet)
        class Btn_Close: RscButton {
            text = "X";
            x = 0.91 * safezoneW + safezoneX;
            y = 0.06 * safezoneH + safezoneY;
            w = 0.02 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = {0.5, 0, 0, 0.8};
            onButtonClick = "closeDialog 0;";
        };
    };
};
