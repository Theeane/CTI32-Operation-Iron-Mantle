params [["_mode", "SAVE", [""]]];
if (!isServer) exitWith {};
if (!isNil "MWF_fnc_requestDelayedSave") then { [] call MWF_fnc_requestDelayedSave; } else { ["Legacy SaveManager"] call MWF_fnc_saveGame; };
