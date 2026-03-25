class MWF_RscGuide {
    idd = 12300;
    movingEnable = false;
    enableSimulation = true;

    class Controls {
        class BackgroundOuter: RscText {
            idc = 12301;
            x = 0.12 * safezoneW + safezoneX;
            y = 0.12 * safezoneH + safezoneY;
            w = 0.76 * safezoneW;
            h = 0.72 * safezoneH;
            colorBackground[] = {0.05, 0.05, 0.05, 0.92};
        };

        class BackgroundInner: RscText {
            idc = 12302;
            x = 0.135 * safezoneW + safezoneX;
            y = 0.145 * safezoneH + safezoneY;
            w = 0.73 * safezoneW;
            h = 0.67 * safezoneH;
            colorBackground[] = {0.72, 0.72, 0.72, 0.92};
        };

        class HeaderBG: RscText {
            idc = 12303;
            x = 0.145 * safezoneW + safezoneX;
            y = 0.155 * safezoneH + safezoneY;
            w = 0.71 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.12, 0.12, 0.12, 0.88};
        };

        class HeaderText: RscStructuredText {
            idc = 12304;
            text = "";
            x = 0.152 * safezoneW + safezoneX;
            y = 0.162 * safezoneH + safezoneY;
            w = 0.55 * safezoneW;
            h = 0.028 * safezoneH;
        };

        class BtnClose: RscButton {
            idc = 12305;
            text = "$STR_MWF_GUIDE_CLOSE";
            x = 0.748 * safezoneW + safezoneX;
            y = 0.158 * safezoneH + safezoneY;
            w = 0.10 * safezoneW;
            h = 0.032 * safezoneH;
            action = "['CLOSE'] call MWF_fnc_openGuide;";
        };

        class SidebarBG: RscText {
            idc = 12306;
            x = 0.145 * safezoneW + safezoneX;
            y = 0.205 * safezoneH + safezoneY;
            w = 0.19 * safezoneW;
            h = 0.60 * safezoneH;
            colorBackground[] = {0.14, 0.14, 0.14, 0.90};
        };

        class ContentBG: RscText {
            idc = 12307;
            x = 0.345 * safezoneW + safezoneX;
            y = 0.205 * safezoneH + safezoneY;
            w = 0.51 * safezoneW;
            h = 0.60 * safezoneH;
            colorBackground[] = {0.95, 0.95, 0.95, 0.82};
        };

        class BtnStart: RscButton {
            idc = 12310;
            text = "$STR_MWF_GUIDE_TOPIC_START";
            x = 0.153 * safezoneW + safezoneX;
            y = 0.218 * safezoneH + safezoneY;
            w = 0.174 * safezoneW;
            h = 0.042 * safezoneH;
            action = "['SET_PAGE','START'] call MWF_fnc_openGuide;";
        };
        class BtnUndercover: RscButton {
            idc = 12311;
            text = "$STR_MWF_GUIDE_TOPIC_UNDERCOVER";
            x = 0.153 * safezoneW + safezoneX;
            y = 0.266 * safezoneH + safezoneY;
            w = 0.174 * safezoneW;
            h = 0.042 * safezoneH;
            action = "['SET_PAGE','UNDERCOVER'] call MWF_fnc_openGuide;";
        };
        class BtnThreat: RscButton {
            idc = 12312;
            text = "$STR_MWF_GUIDE_TOPIC_THREAT";
            x = 0.153 * safezoneW + safezoneX;
            y = 0.314 * safezoneH + safezoneY;
            w = 0.174 * safezoneW;
            h = 0.042 * safezoneH;
            action = "['SET_PAGE','THREAT'] call MWF_fnc_openGuide;";
        };
        class BtnTier: RscButton {
            idc = 12313;
            text = "$STR_MWF_GUIDE_TOPIC_TIER";
            x = 0.153 * safezoneW + safezoneX;
            y = 0.362 * safezoneH + safezoneY;
            w = 0.174 * safezoneW;
            h = 0.042 * safezoneH;
            action = "['SET_PAGE','WORLD_TIER'] call MWF_fnc_openGuide;";
        };
        class BtnZones: RscButton {
            idc = 12314;
            text = "$STR_MWF_GUIDE_TOPIC_ZONES";
            x = 0.153 * safezoneW + safezoneX;
            y = 0.410 * safezoneH + safezoneY;
            w = 0.174 * safezoneW;
            h = 0.042 * safezoneH;
            action = "['SET_PAGE','ZONES'] call MWF_fnc_openGuide;";
        };
        class BtnSupply: RscButton {
            idc = 12315;
            text = "$STR_MWF_GUIDE_TOPIC_SUPPLY";
            x = 0.153 * safezoneW + safezoneX;
            y = 0.458 * safezoneH + safezoneY;
            w = 0.174 * safezoneW;
            h = 0.042 * safezoneH;
            action = "['SET_PAGE','SUPPLY'] call MWF_fnc_openGuide;";
        };
        class BtnIntel: RscButton {
            idc = 12316;
            text = "$STR_MWF_GUIDE_TOPIC_INTEL";
            x = 0.153 * safezoneW + safezoneX;
            y = 0.506 * safezoneH + safezoneY;
            w = 0.174 * safezoneW;
            h = 0.042 * safezoneH;
            action = "['SET_PAGE','INTEL'] call MWF_fnc_openGuide;";
        };
        class BtnMainOps: RscButton {
            idc = 12317;
            text = "$STR_MWF_GUIDE_TOPIC_MAINOPS";
            x = 0.153 * safezoneW + safezoneX;
            y = 0.554 * safezoneH + safezoneY;
            w = 0.174 * safezoneW;
            h = 0.042 * safezoneH;
            action = "['SET_PAGE','MAIN_OPS'] call MWF_fnc_openGuide;";
        };
        class BtnFOB: RscButton {
            idc = 12318;
            text = "$STR_MWF_GUIDE_TOPIC_FOB";
            x = 0.153 * safezoneW + safezoneX;
            y = 0.602 * safezoneH + safezoneY;
            w = 0.174 * safezoneW;
            h = 0.042 * safezoneH;
            action = "['SET_PAGE','FOB_ATTACKS'] call MWF_fnc_openGuide;";
        };
        class BtnEndgame: RscButton {
            idc = 12319;
            text = "$STR_MWF_GUIDE_TOPIC_ENDGAME";
            x = 0.153 * safezoneW + safezoneX;
            y = 0.650 * safezoneH + safezoneY;
            w = 0.174 * safezoneW;
            h = 0.042 * safezoneH;
            action = "['SET_PAGE','ENDGAME'] call MWF_fnc_openGuide;";
        };

        class ContentTitle: RscStructuredText {
            idc = 12320;
            text = "";
            x = 0.360 * safezoneW + safezoneX;
            y = 0.222 * safezoneH + safezoneY;
            w = 0.48 * safezoneW;
            h = 0.05 * safezoneH;
        };

        class ContentText: RscStructuredText {
            idc = 12321;
            text = "";
            x = 0.360 * safezoneW + safezoneX;
            y = 0.275 * safezoneH + safezoneY;
            w = 0.48 * safezoneW;
            h = 0.50 * safezoneH;
        };
    };
};
