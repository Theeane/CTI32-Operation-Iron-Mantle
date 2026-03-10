/*
    Author: Theane (AGS Project)
    Description: Opens Zeus with area-restricted camera and no units/factions.
    Language: Swedish/English
*/

if (!hasInterface) exitWith {};

private _terminal = _this select 0;
private _fobPos = getPosATL _terminal;
private _maxRange = 150; // Radien för byggområdet i meter

// 1. Skapa Zeus
private _group = createGroup sideLogic;
private _curator = _group createUnit ["ModuleCurator_F", [0,0,0], [], 0, "NONE"];
player assignCurator _curator;

// 2. Rensa fraktioner via servern
[_curator] remoteExec ["AGS_fnc_limitZeusAssets", 2];

openCuratorInterface;

// 3. Kamera-begränsning (Loop)
[_curator, _fobPos, _maxRange] spawn {
    params ["_curator", "_fobPos", "_range"];
    
    while {not isNull (getAssignedCuratorLogic player)} do {
        if (getCuratorCameraPos _curator distance _fobPos > _range) then {
            // Om kameran är för långt bort, flytta den mot FOB:en
            _curator setCuratorCameraScene [
                _fobPos, 
                [velocity curatorCamera select 0, velocity curatorCamera select 1, 50], 
                0.5
            ];
            hintSilent "Varning: Du lämnar byggområdet!";
        };
        uiSleep 0.5;
        if (isNull (findDisplay 312)) exitWith { deleteVehicle _curator; }; // Stäng vid ESC
    };
};

hint parseText format ["<t color='#00bbff' size='1.2'>ARCHITECT MODE</t><br/>Byggområde: %1m radie.", _range];
