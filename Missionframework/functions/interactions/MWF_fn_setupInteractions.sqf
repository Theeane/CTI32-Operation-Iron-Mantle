/*
    Author: OpenAI / Operation Iron Mantle
    Function: MWF_fnc_setupInteractions
    Project: Military War Framework

    Description:
    Compatibility bridge for interaction setup.
    Resolves the active MOB terminal and ensures the local command actions are present
    without re-adding the legacy scroll menu stack.
*/

params [["_object", objNull, [objNull]]];

if (!hasInterface) exitWith { false };

if (isNull _object) then {
    _object = missionNamespace getVariable ["MWF_Intel_Center", objNull];
    if (isNull _object && {!isNil "MWF_Intel_Center"}) then { _object = MWF_Intel_Center; };

    if (isNull _object) then {
        private _assetAnchor = missionNamespace getVariable ["MWF_MOB_AssetAnchor", objNull];
        if (isNull _assetAnchor && {!isNil "MWF_MOB_AssetAnchor"}) then { _assetAnchor = MWF_MOB_AssetAnchor; };
        if (!isNull _assetAnchor) then {
            private _terminalClasses = [
                missionNamespace getVariable ["MWF_FOB_Asset_Terminal", "Land_Laptop_unfolded_F"],
                "Land_Laptop_unfolded_F",
                "RuggedTerminal_01_communications_F",
                "Land_DataTerminal_01_F"
            ];
            private _nearAnchor = nearestObjects [_assetAnchor, _terminalClasses, 12, true];
            if !(_nearAnchor isEqualTo []) then {
                _object = _nearAnchor # 0;
            };
        };
    };
};

if (isNull _object) exitWith { false };

missionNamespace setVariable ["MWF_Intel_Center", _object, true];
player setVariable ["MWF_Player_Authenticated", true, true];

if (!isNil "MWF_fnc_initCommandPC") then {
    [_object] call MWF_fnc_initCommandPC;
};

true
