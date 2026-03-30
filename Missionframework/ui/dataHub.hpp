/*
    Author: OpenAI / ChatGPT
    Project: Military War Framework

    Description:
    Unified command/data hub terminal shell.
    UI lock pass only.
*/

class MWF_RscDataHubMapControl {
    access = 0;
    type = 101;
    idc = -1;
    style = 48;
    shadow = 0;
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
    colorMainRoads[] = {0.9,0.75,0.45,1};
    colorMainRoadsFill[] = {1,0.95,0.75,1};
    widthRailWay = 4;
    widthRoads = 2;
    widthMainRoads = 2.2;
    widthTracks = 0.35;
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
        class BackgroundOuter: RscPicture {
            idc = 12201;
            text = "ui\terminal_bg.paa";
            x = 0.014 * safezoneW + safezoneX;
            y = 0.004 * safezoneH + safezoneY;
            w = 0.972 * safezoneW;
            h = 0.944 * safezoneH;
        };

        class BackgroundInner: RscText {
            idc = 12202;
            x = 0.160 * safezoneW + safezoneX;
            y = 0.145 * safezoneH + safezoneY;
            w = 0.660 * safezoneW;
            h = 0.640 * safezoneH;
            colorBackground[] = {0,0,0,0};
        };

        class TerminalStatusBG: RscText {
            idc = 12217;
            x = 0.164 * safezoneW + safezoneX;
            y = 0.149 * safezoneH + safezoneY;
            w = 0.652 * safezoneW;
            h = 0.032 * safezoneH;
            colorBackground[] = {0.12,0.12,0.12,0.88};
        };

        class TerminalStatusText: RscStructuredText {
            idc = 12218;
            text = "";
            x = 0.170 * safezoneW + safezoneX;
            y = 0.153 * safezoneH + safezoneY;
            w = 0.640 * safezoneW;
            h = 0.026 * safezoneH;
        };

        class BtnVehicleBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.170 * safezoneW + safezoneX;
            y = 0.168 * safezoneH + safezoneY;
            w = 0.126 * safezoneW;
            h = 0.092 * safezoneH;
        };
        class BtnVehicle: MWF_RscTerminalButton {
            idc = 12210;
            text = "Vehicle Menu";
            x = 0.178 * safezoneW + safezoneX;
            y = 0.179 * safezoneH + safezoneY;
            w = 0.110 * safezoneW;
            h = 0.070 * safezoneH;
            action = "private _terminal = uiNamespace getVariable ['MWF_DataHub_ContextTerminal', missionNamespace getVariable ['MWF_CommandTerminal_Object', objNull]]; ['OPEN', _terminal] call MWF_fnc_terminal_vehicleMenu;";
        };

        class BtnBuildBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.300 * safezoneW + safezoneX;
            y = 0.168 * safezoneH + safezoneY;
            w = 0.126 * safezoneW;
            h = 0.092 * safezoneH;
        };
        class BtnBuild: MWF_RscTerminalButton {
            idc = 12211;
            text = "Base Building";
            x = 0.308 * safezoneW + safezoneX;
            y = 0.179 * safezoneH + safezoneY;
            w = 0.110 * safezoneW;
            h = 0.070 * safezoneH;
            action = "private _terminal = uiNamespace getVariable ['MWF_DataHub_ContextTerminal', missionNamespace getVariable ['MWF_CommandTerminal_Object', objNull]]; ['CLOSE'] call MWF_fnc_dataHub; [_terminal] spawn MWF_fnc_enterBuildMode;";
        };

        class BtnMainOpsBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.430 * safezoneW + safezoneX;
            y = 0.168 * safezoneH + safezoneY;
            w = 0.126 * safezoneW;
            h = 0.092 * safezoneH;
        };
        class BtnMainOps: MWF_RscTerminalButton {
            idc = 12212;
            text = "Main Operations";
            x = 0.438 * safezoneW + safezoneX;
            y = 0.179 * safezoneH + safezoneY;
            w = 0.110 * safezoneW;
            h = 0.070 * safezoneH;
            action = "['SET_MODE','MAIN_OPERATIONS'] call MWF_fnc_dataHub;";
        };

        class BtnSupportBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.560 * safezoneW + safezoneX;
            y = 0.168 * safezoneH + safezoneY;
            w = 0.126 * safezoneW;
            h = 0.092 * safezoneH;
        };
        class BtnSupport: MWF_RscTerminalButton {
            idc = 12213;
            text = "Build Support";
            x = 0.568 * safezoneW + safezoneX;
            y = 0.179 * safezoneH + safezoneY;
            w = 0.110 * safezoneW;
            h = 0.070 * safezoneH;
            action = "['SET_MODE','SUPPORT'] call MWF_fnc_dataHub;";
        };

        class BtnUpgradesBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.690 * safezoneW + safezoneX;
            y = 0.168 * safezoneH + safezoneY;
            w = 0.126 * safezoneW;
            h = 0.092 * safezoneH;
        };
        class BtnUpgrades: MWF_RscTerminalButton {
            idc = 12214;
            text = "Base Upgrades";
            x = 0.698 * safezoneW + safezoneX;
            y = 0.179 * safezoneH + safezoneY;
            w = 0.110 * safezoneW;
            h = 0.070 * safezoneH;
            action = "['SET_MODE','UPGRADES'] call MWF_fnc_dataHub;";
        };

        class MapFrame: RscText {
            idc = 12204;
            x = 0.186 * safezoneW + safezoneX;
            y = 0.254 * safezoneH + safezoneY;
            w = 0.628 * safezoneW;
            h = 0.356 * safezoneH;
            colorBackground[] = {0,0,0,0.2};
        };

        class WorldMap: MWF_RscDataHubMapControl {
            idc = 12205;
            x = 0.190 * safezoneW + safezoneX;
            y = 0.260 * safezoneH + safezoneY;
            w = 0.620 * safezoneW;
            h = 0.338 * safezoneH;
            onMouseButtonDblClick = "if ((_this select 1) isEqualTo 0) then { ['MAP_CLICK', [_this select 2, _this select 3]] call MWF_fnc_dataHub; };";
        };

        class StatusText: RscText {
            idc = 12206;
            text = "Mode: ZONES";
            x = 0.190 * safezoneW + safezoneX;
            y = 0.614 * safezoneH + safezoneY;
            w = 0.300 * safezoneW;
            h = 0.030 * safezoneH;
            colorText[] = {1,1,1,1};
            shadow = 0;
        };

        class InfoText: RscStructuredText {
            idc = 12216;
            text = "";
            x = 0.514 * safezoneW + safezoneX;
            y = 0.612 * safezoneH + safezoneY;
            w = 0.296 * safezoneW;
            h = 0.050 * safezoneH;
            colorText[] = {1,1,1,1};
            size = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 34) * 1)";
        };

        class BtnSideMissionsBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.186 * safezoneW + safezoneX;
            y = 0.698 * safezoneH + safezoneY;
            w = 0.144 * safezoneW;
            h = 0.090 * safezoneH;
        };
        class BtnSideMissions: MWF_RscTerminalButton {
            idc = 12215;
            text = "Missions";
            x = 0.198 * safezoneW + safezoneX;
            y = 0.709 * safezoneH + safezoneY;
            w = 0.118 * safezoneW;
            h = 0.060 * safezoneH;
            action = "['ACTION_SECONDARY'] call MWF_fnc_dataHub;";
        };

        class BtnGuideBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.424 * safezoneW + safezoneX;
            y = 0.698 * safezoneH + safezoneY;
            w = 0.156 * safezoneW;
            h = 0.090 * safezoneH;
        };
        class BtnGuide: MWF_RscTerminalButton {
            idc = 12209;
            text = "$STR_MWF_GUIDE_BUTTON";
            x = 0.437 * safezoneW + safezoneX;
            y = 0.709 * safezoneH + safezoneY;
            w = 0.130 * safezoneW;
            h = 0.060 * safezoneH;
            action = "uiNamespace setVariable ['MWF_Guide_ReturnMode', uiNamespace getVariable ['MWF_DataHub_Mode','ZONES']]; ['CLOSE'] call MWF_fnc_dataHub; ['OPEN', 'START'] call MWF_fnc_openGuide;";
        };

        class BtnActionBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.680 * safezoneW + safezoneX;
            y = 0.698 * safezoneH + safezoneY;
            w = 0.144 * safezoneW;
            h = 0.090 * safezoneH;
        };
        class BtnAction: MWF_RscTerminalButton {
            idc = 12207;
            text = "Redeploy";
            x = 0.692 * safezoneW + safezoneX;
            y = 0.709 * safezoneH + safezoneY;
            w = 0.118 * safezoneW;
            h = 0.060 * safezoneH;
            action = "['ACTION'] call MWF_fnc_dataHub;";
        };
    };
};
