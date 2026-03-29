/*
    Author: OpenAI / ChatGPT
    Project: Military War Framework

    Description:
    Standalone prototype shell for the unified command/data map.
    The GUI tool can later restyle or replace this dialog while reusing the backend logic.
*/

class MWF_RscTerminalButton: RscButton {
    style = ST_CENTER;
    colorText[] = {1,1,1,1};
    colorDisabled[] = {0.5,0.5,0.5,1};
    colorBackground[] = {0,0,0,0};
    colorBackgroundActive[] = {0,0,0,0};
    colorFocused[] = {0,0,0,0};
    colorShadow[] = {0,0,0,0};
    colorBorder[] = {0,0,0,0};
    soundEnter[] = {"",0.09,1};
    soundPush[] = {"",0.09,1};
    soundClick[] = {"",0.09,1};
    soundEscape[] = {"",0.09,1};
    shadow = 0;
    borderSize = 0;
    offsetX = 0;
    offsetY = 0;
    offsetPressedX = 0;
    offsetPressedY = 0;
    sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 32) * 1)";
};

class MWF_RscMapControl {
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
    widthRailWay = 4;
    widthRoads = 2;
    widthMainRoads = 2.2;
    widthPowerLines = 2;
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
    class ActiveMarker {
        color[] = {0.3,0.1,0.9,1};
        size = 50;
    };
    class Command {
        icon = "\A3\ui_f\data\map\mapcontrol\waypoint_ca.paa";
        color[] = {0,0,0,1};
        size = 18;
        importance = 1;
        coefMin = 1;
        coefMax = 1;
    };
    class Task {
        icon = "\A3\ui_f\data\map\mapcontrol\taskIcon_CA.paa";
        iconCreated = "\A3\ui_f\data\map\mapcontrol\taskIconCreated_CA.paa";
        iconCanceled = "\A3\ui_f\data\map\mapcontrol\taskIconCanceled_CA.paa";
        iconDone = "\A3\ui_f\data\map\mapcontrol\taskIconDone_CA.paa";
        iconFailed = "\A3\ui_f\data\map\mapcontrol\taskIconFailed_CA.paa";
        color[] = {1,1,1,1};
        colorCreated[] = {1,1,1,1};
        colorCanceled[] = {0.7,0.7,0.7,1};
        colorDone[] = {0.7,1,0.3,1};
        colorFailed[] = {1,0.3,0.2,1};
        size = 27;
        importance = 1;
        coefMin = 1;
        coefMax = 1;
    };
    class CustomMark {
        icon = "\A3\ui_f\data\map\mapcontrol\custommark_ca.paa";
        color[] = {1,1,1,1};
        size = 24;
        importance = 1;
        coefMin = 1;
        coefMax = 1;
    };
    class Tree {
        icon = "\A3\ui_f\data\map\mapcontrol\tree_ca.paa";
        color[] = {0.45,0.64,0.33,0.8};
        size = 12;
        importance = 0.9;
        coefMin = 0.25;
        coefMax = 4;
    };
    class SmallTree: Tree { size = 10; };
    class Bush {
        icon = "\A3\ui_f\data\map\mapcontrol\bush_ca.paa";
        color[] = {0.45,0.64,0.33,0.8};
        size = 12;
        importance = 0.2;
        coefMin = 0.25;
        coefMax = 4;
    };
    class Church {
        icon = "\A3\ui_f\data\map\mapcontrol\church_CA.paa";
        color[] = {1,1,1,1};
        size = 24;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1;
    };
    class Chapel: Church { icon = "\A3\ui_f\data\map\mapcontrol\Chapel_CA.paa"; };
    class Cross: Church { icon = "\A3\ui_f\data\map\mapcontrol\Cross_CA.paa"; };
    class Rock {
        icon = "\A3\ui_f\data\map\mapcontrol\rock_ca.paa";
        color[] = {0.1,0.1,0.1,0.8};
        size = 12;
        importance = 0.5;
        coefMin = 0.25;
        coefMax = 4;
    };
    class Bunker {
        icon = "\A3\ui_f\data\map\mapcontrol\bunker_ca.paa";
        color[] = {1,1,1,1};
        size = 14;
        importance = 1.5;
        coefMin = 0.5;
        coefMax = 4;
    };
    class Fortress: Bunker { icon = "\A3\ui_f\data\map\mapcontrol\fortress_ca.paa"; };
    class Fountain {
        icon = "\A3\ui_f\data\map\mapcontrol\fountain_ca.paa";
        color[] = {1,1,1,1};
        size = 12;
        importance = 1;
        coefMin = 0.25;
        coefMax = 4;
    };
    class ViewTower {
        icon = "\A3\ui_f\data\map\mapcontrol\viewtower_ca.paa";
        color[] = {1,1,1,1};
        size = 16;
        importance = 2.5;
        coefMin = 0.5;
        coefMax = 4;
    };
    class Lighthouse: ViewTower { icon = "\A3\ui_f\data\map\mapcontrol\lighthouse_ca.paa"; };
    class Quay {
        icon = "\A3\ui_f\data\map\mapcontrol\quay_ca.paa";
        color[] = {1,1,1,1};
        size = 16;
        importance = 1;
        coefMin = 0.5;
        coefMax = 4;
    };
    class Fuelstation {
        icon = "\A3\ui_f\data\map\mapcontrol\fuelstation_ca.paa";
        color[] = {1,1,1,1};
        size = 16;
        importance = 1;
        coefMin = 0.75;
        coefMax = 4;
    };
    class Hospital: Fuelstation { icon = "\A3\ui_f\data\map\mapcontrol\hospital_ca.paa"; };
    class BusStop {
        icon = "\A3\ui_f\data\map\mapcontrol\busstop_CA.paa";
        color[] = {1,1,1,1};
        size = 12;
        importance = 1;
        coefMin = 0.5;
        coefMax = 4;
    };
    class Transmitter {
        icon = "\A3\ui_f\data\map\mapcontrol\transmitter_CA.paa";
        color[] = {1,1,1,1};
        size = 20;
        importance = 1;
        coefMin = 0.5;
        coefMax = 4;
    };
    class Stack {
        icon = "\A3\ui_f\data\map\mapcontrol\stack_ca.paa";
        color[] = {1,1,1,1};
        size = 20;
        importance = 2;
        coefMin = 0.9;
        coefMax = 4;
    };
    class Ruin {
        icon = "\A3\ui_f\data\map\mapcontrol\ruin_ca.paa";
        color[] = {1,1,1,1};
        size = 16;
        importance = 1.2;
        coefMin = 1;
        coefMax = 4;
    };
    class Tourism {
        icon = "\A3\ui_f\data\map\mapcontrol\tourism_ca.paa";
        color[] = {1,1,1,1};
        size = 16;
        importance = 1;
        coefMin = 0.7;
        coefMax = 4;
    };
    class Watertower {
        icon = "\A3\ui_f\data\map\mapcontrol\watertower_ca.paa";
        color[] = {1,1,1,1};
        size = 20;
        importance = 1.2;
        coefMin = 0.75;
        coefMax = 4;
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
            x = 0.060 * safezoneW + safezoneX;
            y = 0.046 * safezoneH + safezoneY;
            w = 0.880 * safezoneW;
            h = 0.847 * safezoneH;
        };

        class BackgroundInner: RscText {
            idc = 12202;
            x = 0.135 * safezoneW + safezoneX;
            y = 0.145 * safezoneH + safezoneY;
            w = 0.730 * safezoneW;
            h = 0.670 * safezoneH;
            colorBackground[] = {0, 0, 0, 0};
        };

        class TerminalStatusBG: RscText {
            idc = 12217;
            x = 0.145 * safezoneW + safezoneX;
            y = 0.155 * safezoneH + safezoneY;
            w = 0.710 * safezoneW;
            h = 0.032 * safezoneH;
            colorBackground[] = {0.12, 0.12, 0.12, 0.88};
        };

        class TerminalStatusText: RscStructuredText {
            idc = 12218;
            text = "";
            x = 0.151 * safezoneW + safezoneX;
            y = 0.158 * safezoneH + safezoneY;
            w = 0.700 * safezoneW;
            h = 0.026 * safezoneH;
        };

        class BtnGuideBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.136 * safezoneW + safezoneX;
            y = 0.172 * safezoneH + safezoneY;
            w = 0.116 * safezoneW;
            h = 0.084 * safezoneH;
        };
        class BtnGuide: MWF_RscTerminalButton {
            idc = 12209;
            text = "$STR_MWF_GUIDE_BUTTON";
            x = 0.146 * safezoneW + safezoneX;
            y = 0.182 * safezoneH + safezoneY;
            w = 0.096 * safezoneW;
            h = 0.064 * safezoneH;
            action = "uiNamespace setVariable ['MWF_Guide_ReturnMode', uiNamespace getVariable ['MWF_DataHub_Mode','ZONES']]; ['CLOSE'] call MWF_fnc_dataHub; ['OPEN', 'START'] call MWF_fnc_openGuide;";
        };

        class BtnVehicleBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.233 * safezoneW + safezoneX;
            y = 0.172 * safezoneH + safezoneY;
            w = 0.134 * safezoneW;
            h = 0.084 * safezoneH;
        };
        class BtnVehicle: MWF_RscTerminalButton {
            idc = 12210;
            text = "Vehicle Menu";
            x = 0.245 * safezoneW + safezoneX;
            y = 0.182 * safezoneH + safezoneY;
            w = 0.110 * safezoneW;
            h = 0.064 * safezoneH;
            action = "private _terminal = uiNamespace getVariable ['MWF_DataHub_ContextTerminal', missionNamespace getVariable ['MWF_CommandTerminal_Object', objNull]]; ['CLOSE'] call MWF_fnc_dataHub; ['OPEN', _terminal] call MWF_fnc_terminal_vehicleMenu;";
        };
        class BtnBuildBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.360 * safezoneW + safezoneX;
            y = 0.172 * safezoneH + safezoneY;
            w = 0.134 * safezoneW;
            h = 0.084 * safezoneH;
        };
        class BtnBuild: MWF_RscTerminalButton {
            idc = 12211;
            text = "Base Building";
            x = 0.372 * safezoneW + safezoneX;
            y = 0.182 * safezoneH + safezoneY;
            w = 0.110 * safezoneW;
            h = 0.064 * safezoneH;
            action = "private _terminal = uiNamespace getVariable ['MWF_DataHub_ContextTerminal', missionNamespace getVariable ['MWF_CommandTerminal_Object', objNull]]; ['CLOSE'] call MWF_fnc_dataHub; [_terminal] spawn MWF_fnc_enterBuildMode;";
        };
        class BtnMainOpsBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.487 * safezoneW + safezoneX;
            y = 0.172 * safezoneH + safezoneY;
            w = 0.134 * safezoneW;
            h = 0.084 * safezoneH;
        };
        class BtnMainOps: MWF_RscTerminalButton {
            idc = 12212;
            text = "Main Operations";
            x = 0.499 * safezoneW + safezoneX;
            y = 0.182 * safezoneH + safezoneY;
            w = 0.110 * safezoneW;
            h = 0.064 * safezoneH;
            action = "['SET_MODE','MAIN_OPERATIONS'] call MWF_fnc_dataHub;";
        };
        class BtnSupportBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.614 * safezoneW + safezoneX;
            y = 0.172 * safezoneH + safezoneY;
            w = 0.134 * safezoneW;
            h = 0.084 * safezoneH;
        };
        class BtnSupport: MWF_RscTerminalButton {
            idc = 12213;
            text = "Build Support";
            x = 0.626 * safezoneW + safezoneX;
            y = 0.182 * safezoneH + safezoneY;
            w = 0.110 * safezoneW;
            h = 0.064 * safezoneH;
            action = "['SET_MODE','SUPPORT'] call MWF_fnc_dataHub;";
        };
        class BtnUpgradesBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.741 * safezoneW + safezoneX;
            y = 0.172 * safezoneH + safezoneY;
            w = 0.134 * safezoneW;
            h = 0.084 * safezoneH;
        };
        class BtnUpgrades: MWF_RscTerminalButton {
            idc = 12214;
            text = "Base Upgrades";
            x = 0.753 * safezoneW + safezoneX;
            y = 0.182 * safezoneH + safezoneY;
            w = 0.110 * safezoneW;
            h = 0.064 * safezoneH;
            action = "['SET_MODE','UPGRADES'] call MWF_fnc_dataHub;";
        };

        class MapFrame: RscText {
            idc = 12204;
            x = 0.140 * safezoneW + safezoneX;
            y = 0.258 * safezoneH + safezoneY;
            w = 0.720 * safezoneW;
            h = 0.455 * safezoneH;
            colorBackground[] = {0,0,0,0.2};
        };

        class WorldMap: MWF_RscMapControl {
            idc = 12205;
            x = 0.145 * safezoneW + safezoneX;
            y = 0.264 * safezoneH + safezoneY;
            w = 0.710 * safezoneW;
            h = 0.440 * safezoneH;
            onMouseButtonDblClick = "if ((_this select 1) isEqualTo 0) then { ['MAP_CLICK', [_this select 2, _this select 3]] call MWF_fnc_dataHub; };";
        };

        class StatusText: RscText {
            idc = 12206;
            text = "Mode: ZONES";
            x = 0.145 * safezoneW + safezoneX;
            y = 0.720 * safezoneH + safezoneY;
            w = 0.450 * safezoneW;
            h = 0.032 * safezoneH;
            colorText[] = {1,1,1,1};
        };

        class InfoText: RscStructuredText {
            idc = 12216;
            text = "";
            x = 0.595 * safezoneW + safezoneX;
            y = 0.718 * safezoneH + safezoneY;
            w = 0.260 * safezoneW;
            h = 0.068 * safezoneH;
            colorText[] = {1,1,1,1};
            size = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 34) * 1)";
        };

        class BtnSideMissionsBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.133 * safezoneW + safezoneX;
            y = 0.773 * safezoneH + safezoneY;
            w = 0.169 * safezoneW;
            h = 0.084 * safezoneH;
        };

        class BtnSideMissions: MWF_RscTerminalButton {
            idc = 12215;
            text = "Missions";
            x = 0.145 * safezoneW + safezoneX;
            y = 0.785 * safezoneH + safezoneY;
            w = 0.145 * safezoneW;
            h = 0.060 * safezoneH;
            action = "['ACTION_SECONDARY'] call MWF_fnc_dataHub;";
        };

        class BtnActionBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.698 * safezoneW + safezoneX;
            y = 0.773 * safezoneH + safezoneY;
            w = 0.169 * safezoneW;
            h = 0.084 * safezoneH;
        };

        class BtnAction: MWF_RscTerminalButton {
            idc = 12207;
            text = "Back";
            x = 0.710 * safezoneW + safezoneX;
            y = 0.785 * safezoneH + safezoneY;
            w = 0.145 * safezoneW;
            h = 0.060 * safezoneH;
            action = "['ACTION'] call MWF_fnc_dataHub;";
        };
    };
};

