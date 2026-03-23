/*
    Author: Theane / ChatGPT
    Function: fn_abandonManager
    Project: Military War Framework

    Description:
    Cleans up player-owned vehicles that have been abandoned far away from players and
    friendly bases for an extended period. Uses authoritative base positions instead of
    the old marker-array assumption.
*/

if (!isServer) exitWith {};
if (missionNamespace getVariable ["MWF_AbandonManagerStarted", false]) exitWith {};

missionNamespace setVariable ["MWF_AbandonManagerStarted", true, true];
diag_log "[Iron Mantle] Abandon Manager started.";

private _isTrackedVehicle = {
    params ["_veh"];
    (_veh getVariable ["MWF_isBought", false]) ||
    (_veh getVariable ["MWF_isBuiltByPlayer", false]) ||
    (_veh getVariable ["MWF_isPermanent", false])
};

private _isNearFriendlyBase = {
    params ["_veh"];

    private _vehPos = getPosATL _veh;
    private _mainBase = missionNamespace getVariable ["MWF_MainBase", missionNamespace getVariable ["MWF_MOB", objNull]];
    if (!isNull _mainBase && {_vehPos distance2D _mainBase < 200}) exitWith { true };

    {
        private _terminal = _x param [1, objNull];
        if (!isNull _terminal && {_vehPos distance2D _terminal < 200}) exitWith { true };
    } forEach (missionNamespace getVariable ["MWF_FOB_Registry", []]);

    false
};

while {true} do {
    {
        private _veh = _x;

        if (!alive _veh) then {
            _veh setVariable ["MWF_abandonStartedAt", nil];
        } else {
            if !(_veh isKindOf "StaticWeapon") then {
                if ([_veh] call _isTrackedVehicle) then {
                    private _nearPlayers = allPlayers select {
                        alive _x &&
                        {(_x distance2D _veh) < 500}
                    };

                    private _isHome = [_veh] call _isNearFriendlyBase;

                    if ((count _nearPlayers) == 0 && {!_isHome}) then {
                        private _startedAt = _veh getVariable ["MWF_abandonStartedAt", -1];
                        if (_startedAt < 0) then {
                            _veh setVariable ["MWF_abandonStartedAt", serverTime, true];
                        } else {
                            if ((serverTime - _startedAt) >= 1800) then {
                                diag_log format [
                                    "[Iron Mantle] Deleting abandoned tracked vehicle: %1 at %2",
                                    typeOf _veh,
                                    getPosATL _veh
                                ];
                                deleteVehicle _veh;
                            };
                        };
                    } else {
                        if ((_veh getVariable ["MWF_abandonStartedAt", -1]) >= 0) then {
                            _veh setVariable ["MWF_abandonStartedAt", -1, true];
                        };
                    };
                };
            };
        };
    } forEach vehicles;

    uiSleep 60;
};
