/*
    Author: OpenAI / repaired from patch
    Function: MWF_fnc_initFOB
    Project: Military War Framework

    Description:
    Adds the deploy hold action to a FOB truck/container.
    Uses a self-contained local ghost placement flow and routes confirmation to the
    authoritative server-side deploy pipeline.
*/

params [["_asset", objNull, [objNull]]];

if (isNull _asset) exitWith {
    diag_log "[MWF FOB] initFOB called with null object.";
};

if (_asset getVariable ["MWF_FOB_InitComplete", false]) exitWith {};

private _originType = if (typeOf _asset == (missionNamespace getVariable ["MWF_FOB_Truck", ""])) then { "TRUCK" } else { "BOX" };
_asset setVariable ["MWF_FOB_Type", _originType, true];

[
    _asset,
    "<t color='#00FF00'>Deploy FOB</t>",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_connect_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_connect_ca.paa",
    "_this distance _target < 10 && speed _target < 1 && !(_target getVariable ['MWF_FOB_PlacementInProgress', false])",
    "_caller distance _target < 10",
    {},
    {},
    {
        params ["_target", "_caller"];
        _target setVariable ["MWF_FOB_PlacementInProgress", true, true];

        [_target] spawn {
            params [["_sourceObject", objNull, [objNull]]];

            if (!hasInterface || {isNull _sourceObject}) exitWith {
                if (!isNull _sourceObject) then {
                    _sourceObject setVariable ["MWF_FOB_PlacementInProgress", false, true];
                };
            };

            private _originPos = getPosATL _sourceObject;
            private _currentDir = getDir _sourceObject;
            private _currentCenter = +_originPos;

            private _compositionData = [
                ["Land_Cargo_HQ_V1_F", [0, 0, 0], 0],
                ["Land_HBarrier_5_F", [7, 7, 0], 45],
                ["Land_HBarrier_5_F", [-7, 7, 0], 315],
                ["Land_BagBunker_Small_F", [0, -10, 0], 180],
                ["Land_PortableLight_Single_F", [5, -5, 0], 0]
            ];

            private _ghosts = [];
            {
                _x params ["_type", "_offset", "_dirOffset"];
                private _ghost = _type createVehicleLocal [0, 0, 0];
                _ghost setAllowDamage false;
                _ghost enableSimulation false;
                _ghost setAlpha 0.5;
                _ghosts pushBack [_ghost, _offset, _dirOffset];
            } forEach _compositionData;

            private _confirmed = false;
            private _abort = false;
            private _lastValidation = -10;
            private _placementValid = false;

            hint parseText "<t color='#00ff00'>FOB PLACEMENT MODE</t><br/>[LMB/Space]: Place<br/>[RMB/Esc]: Cancel<br/>[Q/E]: Rotate";

            while {!_confirmed && !_abort && alive player} do {
                private _desiredCenter = player modelToWorld [0, 15, 0];
                _currentCenter = +_desiredCenter;

                if (inputAction "User1" > 0) then { _currentDir = _currentDir + 2; };
                if (inputAction "User2" > 0) then { _currentDir = _currentDir - 2; };

                {
                    _x params ["_obj", "_offset", "_dirOffset"];
                    private _rotatedOffset = [_offset, -_currentDir] call BIS_fnc_rotateVector2D;
                    private _finalPos = _currentCenter vectorAdd _rotatedOffset;
                    _obj setPosATL _finalPos;
                    _obj setDir (_currentDir + _dirOffset);
                } forEach _ghosts;

                if ((diag_tickTime - _lastValidation) > 0.15) then {
                    _placementValid = ["CAN_DEPLOY", [_currentCenter]] call MWF_fnc_baseManager;
                    _lastValidation = diag_tickTime;
                };

                {
                    (_x select 0) setAlpha (if (_placementValid) then { 0.5 } else { 0.2 });
                } forEach _ghosts;

                if (inputAction "DefaultAction" > 0) then {
                    if (_placementValid) then {
                        _confirmed = true;
                    } else {
                        hint "Invalid FOB location. Move farther from the MOB and other bases.";
                    };
                };

                if (inputAction "ReloadMagazine" > 0 || {inputAction "MenuBack" > 0}) then {
                    _abort = true;
                };

                uiSleep 0.01;
            };

            { deleteVehicle (_x select 0); } forEach _ghosts;

            if (_confirmed) then {
                [_sourceObject, ATLToASL _currentCenter, _currentDir] remoteExec ["MWF_fnc_deployFOB", 2];
                hint "FOB deployment requested.";
                diag_log format ["[MWF FOB] FOB placement confirmed at %1 with direction %2.", _currentCenter, _currentDir];
            } else {
                _sourceObject setVariable ["MWF_FOB_PlacementInProgress", false, true];
                hint "Placement aborted.";
                diag_log "[MWF FOB] FOB placement aborted by player.";
            };
        };
    },
    {
        params ["_target"];
        _target setVariable ["MWF_FOB_PlacementInProgress", false, true];
        hint "Deployment aborted.";
    },
    [],
    10,
    0,
    true,
    false
] call BIS_fnc_holdActionAdd;

_asset setVariable ["MWF_FOB_InitComplete", true, true];
diag_log format ["[MWF FOB] Initialized %1 as deployable %2.", _asset, _originType];
