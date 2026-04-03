// dialogs.hpp
class MWF_Terminal_Dialog {
    idd = 9000;
    movingEnable = false;

    class ControlsBackground {
        class MainBackground: RscPicture {
            // HÄR ÄR DEN NYA SÖKVÄGEN
            text = "ui\terminal_bg.paa";
            x = 0.05 * safezoneW + safezoneX;
            y = 0.05 * safezoneH + safezoneY;
            w = 0.9 * safezoneW;
            h = 0.9 * safezoneH;
        };
    };

    class Controls {
        // --- TOPPARADEN (5 KNAPPAR) ---
        // Y-axeln är låst på 0.15 för total symmetri
        class Btn_Vehicles: RscStandardButton {
            idc = 9101; text = "VEHICLES";
            x = 0.13 * safezoneW + safezoneX; y = 0.15 * safezoneH + safezoneY;
            w = 0.12 * safezoneW; h = 0.06 * safezoneH;
            onButtonClick = "closeDialog 0; ['OPEN', objNull] call MWF_fnc_terminal_vehicleMenu;";
        };
        class Btn_Base: RscStandardButton {
            idc = 9102; text = "BASE";
            x = 0.27 * safezoneW + safezoneX; y = 0.15 * safezoneH + safezoneY;
            w = 0.12 * safezoneW; h = 0.06 * safezoneH;
            onButtonClick = "closeDialog 0; [objNull] spawn MWF_fnc_enterBuildMode;";
        };
        class Btn_Support: RscStandardButton {
            idc = 9103; text = "SUPPORT";
            x = 0.41 * safezoneW + safezoneX; y = 0.15 * safezoneH + safezoneY;
            w = 0.12 * safezoneW; h = 0.06 * safezoneH;
            onButtonClick = "closeDialog 0; ['OPEN', 'SUPPORT'] call MWF_fnc_dataHub;";
        };
        class Btn_Upgrades: RscStandardButton {
            idc = 9104; text = "UPGRADES";
            x = 0.55 * safezoneW + safezoneX; y = 0.15 * safezoneH + safezoneY;
            w = 0.12 * safezoneW; h = 0.06 * safezoneH;
            onButtonClick = "closeDialog 0; ['OPEN', 'UPGRADES'] call MWF_fnc_dataHub;";
        };
        class Btn_Intel: RscStandardButton {
            idc = 9105; text = "MAIN OPERATIONS";
            x = 0.69 * safezoneW + safezoneX; y = 0.15 * safezoneH + safezoneY;
            w = 0.12 * safezoneW; h = 0.06 * safezoneH;
            onButtonClick = "closeDialog 0; ['OPEN', 'MAIN_OPERATIONS'] call MWF_fnc_dataHub;";
        };

        // --- BOTTEN (MISSIONS & REDEPLOY) ---
        class Btn_Missions: RscStandardButton {
            idc = 9106; text = "MISSIONS";
            x = 0.13 * safezoneW + safezoneX; y = 0.82 * safezoneH + safezoneY;
            w = 0.14 * safezoneW; h = 0.07 * safezoneH;
            onButtonClick = "closeDialog 0; ['OPEN', 'SIDE_MISSIONS'] call MWF_fnc_dataHub;";
        };
        class Btn_Redeploy: RscStandardButton {
            idc = 9107; text = "REDEPLOY";
            x = 0.67 * safezoneW + safezoneX; y = 0.82 * safezoneH + safezoneY;
            w = 0.14 * safezoneW; h = 0.07 * safezoneH;
            onButtonClick = "closeDialog 0; [] call MWF_fnc_openRedeploy;";
        };
    };
};
