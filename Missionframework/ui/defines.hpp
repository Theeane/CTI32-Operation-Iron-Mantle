/*
    Author: Theane / ChatGPT
    Function: defines
    Project: Military War Framework

    Description:
    Defines the UI layout for defines.
*/

// Standard Arma 3 UI Styles
#define ST_LEFT           0x00
#define ST_RIGHT          0x01
#define ST_CENTER         0x02
#define ST_PICTURE        0x30

class RscText {
    access = 0;
    type = 0;
    idc = -1;
    colorBackground[] = {0,0,0,0};
    colorText[] = {1,1,1,1};
    text = "";
    fixedWidth = 0;
    x = 0; y = 0; w = 0; h = 0;
    style = 0;
    shadow = 1;
    font = "RobotoCondensed";
    sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
};

class RscButton {
    access = 0;
    type = 1;
    text = "";
    colorText[] = {1,1,1,1};
    colorDisabled[] = {0.4,0.4,0.4,1};
    colorBackground[] = {0,0,0,0.7};
    colorBackgroundDisabled[] = {0,0,0,0.4};
    colorBackgroundActive[] = {0,0,0,1};
    colorFocused[] = {0,0,0,1};
    colorShadow[] = {0,0,0,0};
    colorBorder[] = {0,0,0,1};
    soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.09,1};
    soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.09,1};
    soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1};
    soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1};
    style = 2;
    x = 0; y = 0; w = 0; h = 0;
    shadow = 2;
    font = "RobotoCondensed";
    sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
    offsetX = 0.003; offsetY = 0.003;
    offsetPressedX = 0.002; offsetPressedY = 0.002;
    borderSize = 0;
};

class RscListBox {
    access = 0;
    type = 5;
    style = 16;
    w = 0.4; h = 0.4;
    font = "RobotoCondensed";
    sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
    colorFixed[] = {1,1,1,1};
    colorText[] = {1,1,1,1};
    colorScrollbar[] = {1,0,0,0};
    colorSelect[] = {0,0,0,1};
    colorSelect2[] = {0,0,0,1};
    colorSelectBackground[] = {0.95,0.95,0.95,1};
    colorSelectBackground2[] = {1,1,1,0.5};
    colorBackground[] = {0,0,0,0.3};
    soundSelect[] = {"\A3\ui_f\data\sound\RscListbox\soundSelect",0.09,1};
    arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
    arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
    wholeHeight = 0.45;
    rowHeight = 0.04;
    maxHistorySize = 100;
    class ListScrollBar {
        color[] = {1,1,1,0.6};
        width = 0;
        autoScrollEnabled = 1;
    };
};

class RscActivePicture {
    access = 0;
    type = 11;
    style = 48;
    color[] = {1,1,1,0.7};
    colorActive[] = {1,1,1,1};
    colorDisabled[] = {1,1,1,0.3};
    soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.09,1};
    soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.09,1};
    soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1};
    soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1};
    action = "";
    x = 0; y = 0; w = 0; h = 0;
    font = "RobotoCondensed";
    sizeEx = 0;
    tooltipColorText[] = {1,1,1,1};
    tooltipColorBox[] = {1,1,1,1};
    tooltipColorShade[] = {0,0,0,0.65};
};
