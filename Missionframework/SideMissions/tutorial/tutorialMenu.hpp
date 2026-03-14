
    // UI file for the tutorial menu
    // This file will add the tutorial options to the main UI menu.

    class RscTutorialMenu {
        idd = -1;
        movingEnable = true;
        controlsBackground[] = {};
        objects[] = {};
        controls[] = {tutorialStartButton};

        class tutorialStartButton: RscButton {
            idc = 1;
            text = "Start Tutorial";
            x = 0.4;
            y = 0.3;
            w = 0.2;
            h = 0.1;
            action = "hint 'Tutorial Started!'";
        };
    };
    