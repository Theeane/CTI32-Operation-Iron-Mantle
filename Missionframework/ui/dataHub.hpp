/*
    Author: OpenAI / ChatGPT
    Project: Military War Framework

    Description:
    Standalone prototype shell for the unified command/data map.
    The GUI tool can later restyle or replace this dialog while reusing the backend logic.
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
    colorText[] = {1,1,1,1};
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
            x = 0.133 * safezoneW + safezoneX;
            y = 0.145 * safezoneH + safezoneY;
            w = 0.734 * safezoneW;
            h = 0.680 * safezoneH;
            colorBackground[] = {0, 0, 0, 0};
        };

        class TerminalStatusBG: RscText {
            idc = 12217;
            x = 0.139 * safezoneW + safezoneX;
            y = 0.149 * safezoneH + safezoneY;
            w = 0.722 * safezoneW;
            h = 0.034 * safezoneH;
            colorBackground[] = {0.12, 0.12, 0.12, 0.88};
        };

        class TerminalStatusText: RscStructuredText {
            idc = 12218;
            text = "";
            x = 0.145 * safezoneW + safezoneX;
            y = 0.153 * safezoneH + safezoneY;
            w = 0.710 * safezoneW;
            h = 0.028 * safezoneH;
        };

        class BtnGuideBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.130 * safezoneW + safezoneX;
            y = 0.168 * safezoneH + safezoneY;
            w = 0.128 * safezoneW;
            h = 0.092 * safezoneH;
        };
        class BtnGuide: MWF_RscTerminalButton {
            idc = 12209;
            text = "$STR_MWF_GUIDE_BUTTON";
            x = 0.141 * safezoneW + safezoneX;
            y = 0.179 * safezoneH + safezoneY;
            w = 0.106 * safezoneW;
            h = 0.070 * safezoneH;
            action = "uiNamespace setVariable ['MWF_Guide_ReturnMode', uiNamespace getVariable ['MWF_DataHub_Mode','ZONES']]; ['CLOSE'] call MWF_fnc_dataHub; ['OPEN', 'START'] call MWF_fnc_openGuide;";
        };

        class BtnVehicleBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.226 * safezoneW + safezoneX;
            y = 0.168 * safezoneH + safezoneY;
            w = 0.147 * safezoneW;
            h = 0.092 * safezoneH;
        };
        class BtnVehicle: MWF_RscTerminalButton {
            idc = 12210;
            text = "Vehicle Menu";
            x = 0.239 * safezoneW + safezoneX;
            y = 0.179 * safezoneH + safezoneY;
            w = 0.121 * safezoneW;
            h = 0.070 * safezoneH;
            action = "private _terminal = uiNamespace getVariable ['MWF_DataHub_ContextTerminal', missionNamespace getVariable ['MWF_CommandTerminal_Object', objNull]]; ['CLOSE'] call MWF_fnc_dataHub; ['OPEN', _terminal] call MWF_fnc_terminal_vehicleMenu;";
        };
        class BtnBuildBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.353 * safezoneW + safezoneX;
            y = 0.168 * safezoneH + safezoneY;
            w = 0.147 * safezoneW;
            h = 0.092 * safezoneH;
        };
        class BtnBuild: MWF_RscTerminalButton {
            idc = 12211;
            text = "Base Building";
            x = 0.366 * safezoneW + safezoneX;
            y = 0.179 * safezoneH + safezoneY;
            w = 0.121 * safezoneW;
            h = 0.070 * safezoneH;
            action = "private _terminal = uiNamespace getVariable ['MWF_DataHub_ContextTerminal', missionNamespace getVariable ['MWF_CommandTerminal_Object', objNull]]; ['CLOSE'] call MWF_fnc_dataHub; [_terminal] spawn MWF_fnc_enterBuildMode;";
        };
        class BtnMainOpsBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.480 * safezoneW + safezoneX;
            y = 0.168 * safezoneH + safezoneY;
            w = 0.147 * safezoneW;
            h = 0.092 * safezoneH;
        };
        class BtnMainOps: MWF_RscTerminalButton {
            idc = 12212;
            text = "Main Operations";
            x = 0.493 * safezoneW + safezoneX;
            y = 0.179 * safezoneH + safezoneY;
            w = 0.121 * safezoneW;
            h = 0.070 * safezoneH;
            action = "['SET_MODE','MAIN_OPERATIONS'] call MWF_fnc_dataHub;";
        };
        class BtnSupportBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.607 * safezoneW + safezoneX;
            y = 0.168 * safezoneH + safezoneY;
            w = 0.147 * safezoneW;
            h = 0.092 * safezoneH;
        };
        class BtnSupport: MWF_RscTerminalButton {
            idc = 12213;
            text = "Build Support";
            x = 0.620 * safezoneW + safezoneX;
            y = 0.179 * safezoneH + safezoneY;
            w = 0.121 * safezoneW;
            h = 0.070 * safezoneH;
            action = "['SET_MODE','SUPPORT'] call MWF_fnc_dataHub;";
        };
        class BtnUpgradesBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.734 * safezoneW + safezoneX;
            y = 0.168 * safezoneH + safezoneY;
            w = 0.147 * safezoneW;
            h = 0.092 * safezoneH;
        };
        class BtnUpgrades: MWF_RscTerminalButton {
            idc = 12214;
            text = "Base Upgrades";
            x = 0.747 * safezoneW + safezoneX;
            y = 0.179 * safezoneH + safezoneY;
            w = 0.121 * safezoneW;
            h = 0.070 * safezoneH;
            action = "['SET_MODE','UPGRADES'] call MWF_fnc_dataHub;";
        };

        class MapFrame: RscText {
            idc = 12204;
            x = 0.142 * safezoneW + safezoneX;
            y = 0.255 * safezoneH + safezoneY;
            w = 0.716 * safezoneW;
            h = 0.430 * safezoneH;
            colorBackground[] = {0,0,0,0.2};
        };

        class WorldMap: MWF_RscDataHubMapControl {
            idc = 12205;
            x = 0.148 * safezoneW + safezoneX;
            y = 0.261 * safezoneH + safezoneY;
            w = 0.704 * safezoneW;
            h = 0.416 * safezoneH;
            onMouseButtonDblClick = "if ((_this select 1) isEqualTo 0) then { ['MAP_CLICK', [_this select 2, _this select 3]] call MWF_fnc_dataHub; };";
        };

        class StatusText: RscText {
            idc = 12206;
            text = "Mode: ZONES";
            x = 0.148 * safezoneW + safezoneX;
            y = 0.688 * safezoneH + safezoneY;
            w = 0.460 * safezoneW;
            h = 0.030 * safezoneH;
            colorText[] = {1,1,1,1};
            shadow = 0;
        };

        class InfoText: RscStructuredText {
            idc = 12216;
            text = "";
            x = 0.592 * safezoneW + safezoneX;
            y = 0.692 * safezoneH + safezoneY;
            w = 0.255 * safezoneW;
            h = 0.070 * safezoneH;
            colorText[] = {1,1,1,1};
            size = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 34) * 1)";
        };

        class BtnSideMissionsBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.124 * safezoneW + safezoneX;
            y = 0.742 * safezoneH + safezoneY;
            w = 0.186 * safezoneW;
            h = 0.092 * safezoneH;
        };

        class BtnSideMissions: MWF_RscTerminalButton {
            idc = 12215;
            text = "Missions";
            x = 0.137 * safezoneW + safezoneX;
            y = 0.753 * safezoneH + safezoneY;
            w = 0.160 * safezoneW;
            h = 0.066 * safezoneH;
            action = "['ACTION_SECONDARY'] call MWF_fnc_dataHub;";
        };

        class BtnActionBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.689 * safezoneW + safezoneX;
            y = 0.742 * safezoneH + safezoneY;
            w = 0.186 * safezoneW;
            h = 0.092 * safezoneH;
        };

        class BtnAction: MWF_RscTerminalButton {
            idc = 12207;
            text = "Back";
            x = 0.702 * safezoneW + safezoneX;
            y = 0.753 * safezoneH + safezoneY;
            w = 0.160 * safezoneW;
            h = 0.066 * safezoneH;
            action = "['ACTION'] call MWF_fnc_dataHub;";
        };
    };
};

