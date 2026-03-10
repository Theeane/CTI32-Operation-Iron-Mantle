/*
    Author: Theane (AGS Project)
    Description: Opens Zeus with access to ALL static structures and objects.
    Language: English
*/

if (!hasInterface) exitWith {};

// 1. Skapa Zeus-modulen
private _group = createGroup sideLogic;
private _curator = _group createUnit ["ModuleCurator_F", [0,0,0], [], 0, "NONE"];
player assignCurator _curator;

// 2. Anropa rensningen på servern - vi skickar "ALL_STRUCTURES" som flagga
[_curator, "ALL_STRUCTURES"] remoteExec ["AGS_fnc_limitZeusAssets", 2];

openCuratorInterface;

hint parseText "<t color='#00bbff' size='1.2'>ARCHITECT MODE</t><br/>Full access to all structures and objects enabled.";
