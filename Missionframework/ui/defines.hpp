/*
    Author: Theane / Gemini
    Project: Military War Framework
    Description: Terminal UI Layout based on Untitled1.png
*/
// Standard Arma 3 UI Styles
#define ST_LEFT           0x00
#define ST_RIGHT          0x01
#define ST_CENTER          0x02
#define ST_PICTURE         0x30
#define ST_KEEP_ASPECT_RATIO 0x800

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
    x = 0; y = 0; w = 0; h = 0;
};

class RscButton {
    access = 0;
    type = 1;
    text = "";
    colorText[] = {1,1,1,1};
    colorDisabled[] = {0.4,0.4,0.4,1};
    colorBackground[] = {0,0,0,0.7};
    colorBackgroundActive[] = {0,0,0,1};
    colorFocused[] = {0,0,0,1};
    soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.09,1};
    soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.09,1};
    soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1};
    soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1};
    style = 2;
    x = 0; y = 0; w = 0; h = 0;
    font = "RobotoCondensed";
    sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
};

// Din specialklass för bild-knappar
class RscStandardButton : RscButton {
    style = "0x02 + 0x30 + 0x800";
    colorBackground[] = {0,0,0,0};
    colorBackgroundActive[] = {1,1,1,0.1};
    text = "";
    url = "Missionframework\ui\button_bg.paa"; 
};
