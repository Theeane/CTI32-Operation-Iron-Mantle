/*
    Cleanly interrupts sensitive local interactions when the player takes damage.
    No invulnerability is granted; this only closes UI/build states and cleans up
    transient placement helpers.
*/

if (!hasInterface) exitWith { false };

private _lastAt = missionNamespace getVariable ["MWF_SensitiveInterrupt_LastAt", -10];
if ((diag_tickTime - _lastAt) < 0.2) exitWith { false };
missionNamespace setVariable ["MWF_SensitiveInterrupt_LastAt", diag_tickTime];

private _interrupted = false;

if (missionNamespace getVariable ["MWF_VehicleBuild_Active", false]) then {
    [] call MWF_fnc_cleanupVehicleBuildSession;
    _interrupted = true;
};

if (missionNamespace getVariable ["MWF_BuildPlacement_Active", false]) then {
    [] call MWF_fnc_cleanupBuildPlacement;
    _interrupted = true;
};

private _dataHubDisplay = uiNamespace getVariable ["MWF_DataHub_Display", displayNull];
if (!isNull _dataHubDisplay) then {
    ["CLOSE"] call MWF_fnc_dataHub;
    _interrupted = true;
};

if (player getVariable ["MWF_BaseArchitect_Active", false]) then {
    player setVariable ["MWF_BaseArchitect_ForceClosed", true];
    player setVariable ["MWF_BaseArchitect_BlockKeyUntil", diag_tickTime + 3];
    _interrupted = true;
};

private _curatorDisplay = findDisplay 312;
if (!isNull _curatorDisplay) then {
    _curatorDisplay closeDisplay 2;
    _interrupted = true;
};

if (_interrupted) then {
    [["INTERACTION INTERRUPTED", "Damage received. Active build/garage/terminal interaction closed."], "warning"] call MWF_fnc_showNotification;
};

_interrupted
