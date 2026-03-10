class CfgFunctions {
    class AGS {
        tag = "AGS";
        class Core {
            file = "Missionframework\core";
            class initGlobals {};
            class scanZones {};
            class economy {};
            class zoneCapture {};
            class notorietyResponse {};
            class setupInteractions {};
        };
        class UI {
            file = "Missionframework\ui";
            class initUI {};
            class updateResourceUI {};
        };
        class Missions {
            file = "Missionframework\missions";
            class generateInitialMission {};
        };
    };
};
