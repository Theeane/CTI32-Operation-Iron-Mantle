/*
    Author: Theane / Gemini / ChatGPT
    Project: Military War Framework
    Description: Terminal UI Layout based on Untitled1.png
*/

// Standard Arma 3 UI Styles
#define ST_LEFT              0x00
#define ST_RIGHT             0x01
#define ST_CENTER            0x02
#define ST_PICTURE           0x30
#define ST_KEEP_ASPECT_RATIO 0x800

class RscText {
    access = 0;
    type = 0;
    idc = -1;
    colorBackground[] = {0,0,0,0};
    colorText[] = {1,1,1,1};
    text = "";
    fixedWidth = 0;
    x = 0;
    y = 0;
    w = 0;
    h = 0;
    style = 0;
    shadow = 1;
    font = "RobotoCondensed";
    sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
};

class IGUIBack : RscText {
    style = 128;
    text = "";
    colorText[] = {0,0,0,0};
    colorBackground[] = {0,0,0,0.5};
};

class RscPicture {
    access = 0;
    idc = -1;
    type = 0;
    style = 48;
    colorBackground[] = {0,0,0,0};
    colorText[] = {1,1,1,1};
    font = "RobotoCondensed";
    sizeEx = 0;
    lineSpacing = 0;
    text = "";
    fixedWidth = 0;
    shadow = 0;
    x = 0;
    y = 0;
    w = 0;
    h = 0;
};

class RscButton {
    access = 0;
    type = 1;
    idc = -1;
    text = "";
    colorText[] = {1,1,1,1};
    colorDisabled[] = {0.4,0.4,0.4,1};
    colorBackground[] = {0,0,0,0.7};
    colorBackgroundActive[] = {0,0,0,1};
    colorFocused[] = {0,0,0,1};
    colorShadow[] = {0,0,0,0};
    colorBorder[] = {0,0,0,1};
    soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.09,1};
    soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.09,1};
    soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1};
    soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1};
    style = 2;
    x = 0;
    y = 0;
    w = 0;
    h = 0;
    shadow = 2;
    font = "RobotoCondensed";
    sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
    offsetX = 0;
    offsetY = 0;
    offsetPressedX = 0;
    offsetPressedY = 0;
    borderSize = 0;
};

class RscStandardButton : RscButton {
    style = ST_CENTER;
    colorBackground[] = {0,0,0,0};
    colorBackgroundActive[] = {1,1,1,0.08};
    colorFocused[] = {1,1,1,0.08};
    colorBorder[] = {0,0,0,0};
    borderSize = 0;
    shadow = 0;
    sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 24) * 1)";
};

class MWF_RscTerminalButton : RscStandardButton {
    colorText[] = {0.96,0.96,0.96,1};
    colorDisabled[] = {0.7,0.7,0.7,0.7};
    colorBackground[] = {0,0,0,0};
    colorBackgroundActive[] = {1,1,1,0.06};
    colorFocused[] = {1,1,1,0.06};
    sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 22) * 1)";
};

class RscStructuredText {
    access = 0;
    type = 13;
    idc = -1;
    style = ST_LEFT;
    text = "";
    x = 0;
    y = 0;
    w = 0;
    h = 0;
    colorBackground[] = {0,0,0,0};
    colorText[] = {1,1,1,1};

    class Attributes {
        font = "RobotoCondensed";
        color = "#FFFFFF";
        colorLink = "#D09B43";
        align = "left";
        shadow = 1;
    };

    size = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 30) * 1)";
    shadow = 1;
};

class RscListBox {
    access = 0;
    type = 5;
    style = 16;
    idc = -1;
    x = 0;
    y = 0;
    w = 0;
    h = 0;
    font = "RobotoCondensed";
    sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
    rowHeight = 0;
    colorText[] = {1,1,1,1};
    colorDisabled[] = {0.4,0.4,0.4,1};
    colorBackground[] = {0,0,0,0.7};
    colorSelect[] = {1,1,1,1};
    colorSelect2[] = {1,1,1,1};
    colorSelectBackground[] = {0.2,0.2,0.2,1};
    colorSelectBackground2[] = {0.2,0.2,0.2,1};
    colorScrollbar[] = {1,1,1,1};
    period = 1;
    maxHistoryDelay = 1;
    autoScrollSpeed = -1;
    autoScrollDelay = 5;
    autoScrollRewind = 0;
    soundSelect[] = {"",0.1,1};
    shadow = 0;

    class ListScrollBar {
        color[] = {1,1,1,1};
        autoScrollEnabled = 1;
        width = 0.021;
        height = 0.028;
        scrollSpeed = 0.01;
        arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
        arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
        border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
        thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
    };
};

class RscControlsGroup {
    access = 0;
    type = 15;
    idc = -1;
    style = 0;
    x = 0;
    y = 0;
    w = 0;
    h = 0;
    shadow = 0;

    class VScrollbar {
        color[] = {1,1,1,1};
        width = 0.021;
        autoScrollEnabled = 1;
    };

    class HScrollbar {
        color[] = {1,1,1,1};
        height = 0.028;
    };

    class Controls {};
};
