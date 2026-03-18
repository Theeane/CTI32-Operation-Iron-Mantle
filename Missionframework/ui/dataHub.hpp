/*
    Author: OpenAI / ChatGPT
    Project: Military War Framework

    Description:
    Standalone prototype shell for the unified command/data map.
    The GUI tool can later restyle or replace this dialog while reusing the backend logic.
*/

class RscMapControl {
    access = 0;
    type = 101;
    idc = -1;
    style = 48;
    x = 0;
    y = 0;
    w = 0.2;
    h = 0.2;
    moveOnEdges = 1;
    ptsPerSquareSea = 5;
    ptsPerSquareTxt = 20;
    ptsPerSquareCLn = 10;
    ptsPerSquareExp = 10;
    ptsPerSquareCost = 10;
    ptsPerSquareFor = 9;
    ptsPerSquareForEdge = 9;
    ptsPerSquareRoad = 6;
    ptsPerSquareObj = 9;
    showCountourInterval = 0;
    scaleMin = 0.001;
    scaleMax = 1;
    scaleDefault = 0.16;
    maxSatelliteAlpha = 0.85;
    alphaFadeStartScale = 0.15;
    alphaFadeEndScale = 0.29;
    colorBackground[] = {0.969,0.957,0.949,1};
    colorOutside[] = {0,0,0,1};
    colorText[] = {0,0,0,1};
    colorSea[] = {0.467,0.631,0.851,0.5};
    colorForest[] = {0.624,0.78,0.388,0.5};
    colorForestBorder[] = {0,0,0,0};
    colorRocks[] = {0,0,0,0.3};
    colorRocksBorder[] = {0,0,0,0};
    colorLevels[] = {0.286,0.177,0.094,0.5};
    colorMainCountlines[] = {0.572,0.354,0.188,0.5};
    colorCountlines[] = {0.572,0.354,0.188,0.25};
    colorMainCountlinesWater[] = {0.491,0.577,0.702,0.6};
    colorCountlinesWater[] = {0.491,0.577,0.702,0.3};
    colorPowerLines[] = {0.1,0.1,0.1,1};
    colorRailWay[] = {0.8,0.2,0,1};
    colorNames[] = {0.1,0.1,0.1,0.9};
    colorInactive[] = {1,1,1,0.5};
    colorTracks[] = {0.84,0.76,0.65,0.15};
    colorTracksFill[] = {0.84,0.76,0.65,1};
    colorRoads[] = {0.7,0.7,0.7,1};
    colorRoadsFill[] = {1,1,1,1};
    colorGrid[] = {0.1,0.1,0.1,0.6};
    colorGridMap[] = {0.1,0.1,0.1,0.6};
    font = "RobotoCondensed";
    sizeEx = 0.04;
    fontLabel = "RobotoCondensed";
    sizeExLabel = 0.034;
    fontGrid = "RobotoCondensed";
    sizeExGrid = 0.03;
    fontUnits = "RobotoCondensed";
    sizeExUnits = 0.034;
    fontNames = "RobotoCondensed";
    sizeExNames = 0.04;
    fontInfo = "RobotoCondensed";
    sizeExInfo = 0.03;
    fontLevel = "RobotoCondensed";
    sizeExLevel = 0.03;
    text = "#(argb,8,8,3)color(1,1,1,1)";
    class Legend {
        x = "SafeZoneX + 0.02";
        y = "SafeZoneY + safezoneH - 4.5 * (((safezoneW / safezoneH) min 1.2) / 40)";
        w = "10 * (((safezoneW / safezoneH) min 1.2) / 40)";
        h = "3.5 * (((safezoneW / safezoneH) min 1.2) / 40)";
        font = "RobotoCondensed";
        sizeEx = "(((safezoneW / safezoneH) min 1.2) / 40)";
        colorBackground[] = {1,1,1,0.5};
        color[] = {0,0,0,1};
    };
};

class MWF_RscDataHub {
    idd = 12200;
    movingEnable = false;
    enableSimulation = true;

    class Controls {
        class BackgroundOuter: RscText {
            idc = 12201;
            x = 0.12 * safezoneW + safezoneX;
            y = 0.12 * safezoneH + safezoneY;
            w = 0.76 * safezoneW;
            h = 0.72 * safezoneH;
            colorBackground[] = {0.05, 0.05, 0.05, 0.92};
        };

        class BackgroundInner: RscText {
            idc = 12202;
            x = 0.135 * safezoneW + safezoneX;
            y = 0.145 * safezoneH + safezoneY;
            w = 0.73 * safezoneW;
            h = 0.67 * safezoneH;
            colorBackground[] = {0.72, 0.72, 0.72, 0.92};
        };

        class BtnVehicle: RscButton {
            idc = 12210;
            text = "Vehicle Menu";
            x = 0.185 * safezoneW + safezoneX;
            y = 0.155 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.04 * safezoneH;
            action = "['SET_MODE','ZONES'] call MWF_fnc_dataHub;";
        };
        class BtnBuild: RscButton {
            idc = 12211;
            text = "Base Building";
            x = 0.298 * safezoneW + safezoneX;
            y = 0.155 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.04 * safezoneH;
            action = "['SET_MODE','ZONES'] call MWF_fnc_dataHub;";
        };
        class BtnMainOps: RscButton {
            idc = 12212;
            text = "Main Operations";
            x = 0.411 * safezoneW + safezoneX;
            y = 0.155 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.04 * safezoneH;
            action = "['SET_MODE','MAIN_OPERATIONS'] call MWF_fnc_dataHub;";
        };
        class BtnSupport: RscButton {
            idc = 12213;
            text = "Build Support";
            x = 0.524 * safezoneW + safezoneX;
            y = 0.155 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.04 * safezoneH;
            action = "['SET_MODE','ZONES'] call MWF_fnc_dataHub;";
        };
        class BtnUpgrades: RscButton {
            idc = 12214;
            text = "Base Upgrades";
            x = 0.637 * safezoneW + safezoneX;
            y = 0.155 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.04 * safezoneH;
            action = "['SET_MODE','ZONES'] call MWF_fnc_dataHub;";
        };

        class MapFrame: RscText {
            idc = 12204;
            x = 0.14 * safezoneW + safezoneX;
            y = 0.215 * safezoneH + safezoneY;
            w = 0.72 * safezoneW;
            h = 0.50 * safezoneH;
            colorBackground[] = {0,0,0,0.2};
        };

        class WorldMap: RscMapControl {
            idc = 12205;
            x = 0.145 * safezoneW + safezoneX;
            y = 0.22 * safezoneH + safezoneY;
            w = 0.71 * safezoneW;
            h = 0.49 * safezoneH;
            onMouseButtonClick = "if ((_this select 1) isEqualTo 0) then { ['MAP_CLICK', [_this select 2, _this select 3]] call MWF_fnc_dataHub; };";
        };

        class StatusText: RscText {
            idc = 12206;
            text = "Mode: ZONES";
            x = 0.145 * safezoneW + safezoneX;
            y = 0.72 * safezoneH + safezoneY;
            w = 0.46 * safezoneW;
            h = 0.03 * safezoneH;
            colorText[] = {0,0,0,1};
        };

        class BtnSideMissions: RscButton {
            idc = 12215;
            text = "Missions";
            x = 0.155 * safezoneW + safezoneX;
            y = 0.76 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.04 * safezoneH;
            action = "['SET_MODE','SIDE_MISSIONS'] call MWF_fnc_dataHub;";
        };

        class BtnAction: RscButton {
            idc = 12207;
            text = "Close";
            x = 0.745 * safezoneW + safezoneX;
            y = 0.76 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.04 * safezoneH;
            action = "['ACTION'] call MWF_fnc_dataHub;";
        };
    };
};
