class MWF_RscGuide {
    idd = 12300;
    movingEnable = false;
    enableSimulation = true;

    class Controls {
        class BackgroundOuter: RscPicture {
            idc = 12301;
            text = "ui\terminal_bg.paa";
            x = 0.060 * safezoneW + safezoneX;
            y = 0.046 * safezoneH + safezoneY;
            w = 0.880 * safezoneW;
            h = 0.847 * safezoneH;
        };

        class BackgroundInner: RscText {
            idc = 12302;
            x = 0.135 * safezoneW + safezoneX;
            y = 0.145 * safezoneH + safezoneY;
            w = 0.730 * safezoneW;
            h = 0.670 * safezoneH;
            colorBackground[] = {0, 0, 0, 0};
        };

        class HeaderBG: RscText {
            idc = 12303;
            x = 0.145 * safezoneW + safezoneX;
            y = 0.155 * safezoneH + safezoneY;
            w = 0.710 * safezoneW;
            h = 0.040 * safezoneH;
            colorBackground[] = {0.12, 0.12, 0.12, 0.88};
        };

        class HeaderText: RscStructuredText {
            idc = 12304;
            text = "";
            x = 0.152 * safezoneW + safezoneX;
            y = 0.162 * safezoneH + safezoneY;
            w = 0.520 * safezoneW;
            h = 0.028 * safezoneH;
        };

        class BtnCloseBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.748 * safezoneW + safezoneX;
            y = 0.146 * safezoneH + safezoneY;
            w = 0.119 * safezoneW;
            h = 0.066 * safezoneH;
        };

        class BtnClose: MWF_RscTerminalButton {
            idc = 12305;
            text = "Back";
            x = 0.760 * safezoneW + safezoneX;
            y = 0.154 * safezoneH + safezoneY;
            w = 0.095 * safezoneW;
            h = 0.050 * safezoneH;
            action = "['CLOSE'] call MWF_fnc_openGuide;";
        };

        class SidebarBG: RscText {
            idc = 12306;
            x = 0.145 * safezoneW + safezoneX;
            y = 0.205 * safezoneH + safezoneY;
            w = 0.190 * safezoneW;
            h = 0.600 * safezoneH;
            colorBackground[] = {0, 0, 0, 0};
        };

        class ContentBG: RscText {
            idc = 12307;
            x = 0.345 * safezoneW + safezoneX;
            y = 0.205 * safezoneH + safezoneY;
            w = 0.510 * safezoneW;
            h = 0.600 * safezoneH;
            colorBackground[] = {0, 0, 0, 0};
        };

        class BtnStartBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.139 * safezoneW + safezoneX;
            y = 0.206 * safezoneH + safezoneY;
            w = 0.202 * safezoneW;
            h = 0.068 * safezoneH;
        };
        class BtnStart: MWF_RscTerminalButton {
            idc = 12310;
            text = "$STR_MWF_GUIDE_TOPIC_START";
            x = 0.151 * safezoneW + safezoneX;
            y = 0.214 * safezoneH + safezoneY;
            w = 0.178 * safezoneW;
            h = 0.052 * safezoneH;
            action = "['SET_PAGE','START'] call MWF_fnc_openGuide;";
        };
        class BtnUndercoverBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.139 * safezoneW + safezoneX;
            y = 0.256 * safezoneH + safezoneY;
            w = 0.202 * safezoneW;
            h = 0.068 * safezoneH;
        };
        class BtnUndercover: MWF_RscTerminalButton {
            idc = 12311;
            text = "$STR_MWF_GUIDE_TOPIC_UNDERCOVER";
            x = 0.151 * safezoneW + safezoneX;
            y = 0.264 * safezoneH + safezoneY;
            w = 0.178 * safezoneW;
            h = 0.052 * safezoneH;
            action = "['SET_PAGE','UNDERCOVER'] call MWF_fnc_openGuide;";
        };
        class BtnThreatBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.139 * safezoneW + safezoneX;
            y = 0.306 * safezoneH + safezoneY;
            w = 0.202 * safezoneW;
            h = 0.068 * safezoneH;
        };
        class BtnThreat: MWF_RscTerminalButton {
            idc = 12312;
            text = "$STR_MWF_GUIDE_TOPIC_THREAT";
            x = 0.151 * safezoneW + safezoneX;
            y = 0.314 * safezoneH + safezoneY;
            w = 0.178 * safezoneW;
            h = 0.052 * safezoneH;
            action = "['SET_PAGE','THREAT'] call MWF_fnc_openGuide;";
        };
        class BtnTierBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.139 * safezoneW + safezoneX;
            y = 0.356 * safezoneH + safezoneY;
            w = 0.202 * safezoneW;
            h = 0.068 * safezoneH;
        };
        class BtnTier: MWF_RscTerminalButton {
            idc = 12313;
            text = "$STR_MWF_GUIDE_TOPIC_TIER";
            x = 0.151 * safezoneW + safezoneX;
            y = 0.364 * safezoneH + safezoneY;
            w = 0.178 * safezoneW;
            h = 0.052 * safezoneH;
            action = "['SET_PAGE','WORLD_TIER'] call MWF_fnc_openGuide;";
        };
        class BtnZonesBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.139 * safezoneW + safezoneX;
            y = 0.406 * safezoneH + safezoneY;
            w = 0.202 * safezoneW;
            h = 0.068 * safezoneH;
        };
        class BtnZones: MWF_RscTerminalButton {
            idc = 12314;
            text = "$STR_MWF_GUIDE_TOPIC_ZONES";
            x = 0.151 * safezoneW + safezoneX;
            y = 0.414 * safezoneH + safezoneY;
            w = 0.178 * safezoneW;
            h = 0.052 * safezoneH;
            action = "['SET_PAGE','ZONES'] call MWF_fnc_openGuide;";
        };
        class BtnSupplyBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.139 * safezoneW + safezoneX;
            y = 0.456 * safezoneH + safezoneY;
            w = 0.202 * safezoneW;
            h = 0.068 * safezoneH;
        };
        class BtnSupply: MWF_RscTerminalButton {
            idc = 12315;
            text = "$STR_MWF_GUIDE_TOPIC_SUPPLY";
            x = 0.151 * safezoneW + safezoneX;
            y = 0.464 * safezoneH + safezoneY;
            w = 0.178 * safezoneW;
            h = 0.052 * safezoneH;
            action = "['SET_PAGE','SUPPLY'] call MWF_fnc_openGuide;";
        };
        class BtnIntelBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.139 * safezoneW + safezoneX;
            y = 0.506 * safezoneH + safezoneY;
            w = 0.202 * safezoneW;
            h = 0.068 * safezoneH;
        };
        class BtnIntel: MWF_RscTerminalButton {
            idc = 12316;
            text = "$STR_MWF_GUIDE_TOPIC_INTEL";
            x = 0.151 * safezoneW + safezoneX;
            y = 0.514 * safezoneH + safezoneY;
            w = 0.178 * safezoneW;
            h = 0.052 * safezoneH;
            action = "['SET_PAGE','INTEL'] call MWF_fnc_openGuide;";
        };
        class BtnMainOpsBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.139 * safezoneW + safezoneX;
            y = 0.556 * safezoneH + safezoneY;
            w = 0.202 * safezoneW;
            h = 0.068 * safezoneH;
        };
        class BtnMainOps: MWF_RscTerminalButton {
            idc = 12317;
            text = "$STR_MWF_GUIDE_TOPIC_MAINOPS";
            x = 0.151 * safezoneW + safezoneX;
            y = 0.564 * safezoneH + safezoneY;
            w = 0.178 * safezoneW;
            h = 0.052 * safezoneH;
            action = "['SET_PAGE','MAIN_OPS'] call MWF_fnc_openGuide;";
        };
        class BtnFOBBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.139 * safezoneW + safezoneX;
            y = 0.606 * safezoneH + safezoneY;
            w = 0.202 * safezoneW;
            h = 0.068 * safezoneH;
        };
        class BtnFOB: MWF_RscTerminalButton {
            idc = 12318;
            text = "$STR_MWF_GUIDE_TOPIC_FOB";
            x = 0.151 * safezoneW + safezoneX;
            y = 0.614 * safezoneH + safezoneY;
            w = 0.178 * safezoneW;
            h = 0.052 * safezoneH;
            action = "['SET_PAGE','FOB_ATTACKS'] call MWF_fnc_openGuide;";
        };
        class BtnEndgameBG: RscPicture {
            idc = -1;
            text = "ui\button_bg.paa";
            x = 0.139 * safezoneW + safezoneX;
            y = 0.656 * safezoneH + safezoneY;
            w = 0.202 * safezoneW;
            h = 0.068 * safezoneH;
        };
        class BtnEndgame: MWF_RscTerminalButton {
            idc = 12319;
            text = "$STR_MWF_GUIDE_TOPIC_ENDGAME";
            x = 0.151 * safezoneW + safezoneX;
            y = 0.664 * safezoneH + safezoneY;
            w = 0.178 * safezoneW;
            h = 0.052 * safezoneH;
            action = "['SET_PAGE','ENDGAME'] call MWF_fnc_openGuide;";
        };

        class ContentTitle: RscStructuredText {
            idc = 12320;
            text = "";
            x = 0.355 * safezoneW + safezoneX;
            y = 0.215 * safezoneH + safezoneY;
            w = 0.480 * safezoneW;
            h = 0.040 * safezoneH;
        };

        class ContentText: RscStructuredText {
            idc = 12321;
            text = "";
            x = 0.355 * safezoneW + safezoneX;
            y = 0.255 * safezoneH + safezoneY;
            w = 0.480 * safezoneW;
            h = 0.530 * safezoneH;
        };
    };
};
