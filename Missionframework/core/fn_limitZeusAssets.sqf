/*
    Author: Theane (AGS Project)
    Description: Limits Zeus to specific buildings and removes all other tabs.
    Language: English
*/

params ["_curator", "_allowedClasses"];

if (!isServer) exitWith {};

// Remove all default addons (this clears the tabs like 'Units', 'Groups' etc)
removeAllCuratorAddons _curator;

// Add only the classes we want to see in the 'Objects' tab
_curator addCuratorEditableObjects [ [], true ]; 

// Add the ability to see things placed by others (for cleanup/moving)
_curator addCuratorEditableObjects [allUnits + vehicles, true];

true
