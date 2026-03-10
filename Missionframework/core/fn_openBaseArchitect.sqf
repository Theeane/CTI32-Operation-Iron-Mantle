/*
    Author: Theane (AGS Project)
    Description: Opens a restricted 'Base Architect' Zeus mode at the FOB location.
    Language: English
*/

if (!hasInterface) exitWith {};

params ["_terminal"];

private _fobPos = getPosATL _terminal;
private _maxRange = 150; // Building radius in meters

// 1. Create a local curator (Zeus) module
private _group = createGroup sideLogic;
private _curator = _group createUnit ["ModuleCurator_F", [0,0,0], [], 0, "NONE"];
player assignCurator _curator;

// 2. Remote execute the asset filter on the server
[_curator] remoteExec ["AGS_fnc_limitZeusAssets", 2];

// 3. Open the Zeus Interface
openCuratorInterface;

// 4. Boundary Enforcement Loop (Camera Lock)
[_curator, _fobPos, _maxRange] spawn {
    params ["_curator", "_fobPos", "_range"];
    
    while {!isNull (getAssignedCuratorLogic player)} do {
        // If camera leaves the allowed radius, snap it back towards the FOB
        if (getCuratorCameraPos _curator distance _fobPos > _range) then {
            _curator setCuratorCameraScene [
                _fobPos, 
                [0, 0, 50], 
                0.5
            ];
            hintSilent "WARNING: You are leaving the designated construction zone!";
        };
        
        uiSleep 0.5;
        
        // If the player closes Zeus (ESC), delete the temporary module
        if (isNull (findDisplay 312)) exitWith { 
            [player, _curator] remoteExec ["AGS_fnc_cleanupCurator", 2]; 
        };
    };
};

hint parseText format ["<t color='#00bbff' size='1.2'>ARCHITECT MODE ACTIVE</t><br/>Construction Area: %1m radius.", _maxRange];
