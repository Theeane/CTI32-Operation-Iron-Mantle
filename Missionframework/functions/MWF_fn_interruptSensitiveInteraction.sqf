/*
    Author: Theane / ChatGPT
    Function: MWF_fn_interruptSensitiveInteraction
    Project: Military War Framework

    Description:
    Cleanly interrupts sensitive local interactions when the player takes damage.
    No invulnerability is granted; this only closes UI/build states and cleans up
    transient placement helpers.
*/

if (!hasInterface) exitWith { false };

private _lastAt = missionNamespace getVariable ["MWF_SensitiveInterrupt_LastAt", -10];
if ((diag_tickTime - _lastAt) < 0.2) exitWith { false };
missionNamespace setVariable ["MWF_SensitiveInterrupt_LastAt", diag_tickTime];

private _interrupted = false;
private _interruptReason = "Damage received. Active build/garage/terminal interaction closed.";

if (missionNamespace getVariable ["MWF_BuildPlacement_Active", false]) then {
    private _ghost = missionNamespace getVariable ["MWF_BuildPlacement_Ghost", objNull];
    if (!isNull _ghost) then {
        deleteVehicle _ghost;
    };

    private _confirmAction = missionNamespace getVariable ["MWF_BuildPlacement_ConfirmAction", -1];
    if (_confirmAction >= 0) then {
        player removeAction _confirmAction;
    };

    private _cancelAction = missionNamespace getVariable ["MWF_BuildPlacement_CancelAction", -1];
    if (_cancelAction >= 0) then {
        player removeAction _cancelAction;
    };

    missionNamespace setVariable ["MWF_BuildPlacement_Ghost", objNull];
    missionNamespace setVariable ["MWF_BuildPlacement_ConfirmAction", -1];
    missionNamespace setVariable ["MWF_BuildPlacement_CancelAction", -1];
    missionNamespace setVariable ["MWF_BuildPlacement_Interrupted", true];
    missionNamespace setVariable ["MWF_BuildPlacement_InterruptReason", _interruptReason];
    missionNamespace setVariable ["MWF_BuildPlacement_Aborted", true];
    missionNamespace setVariable ["MWF_BuildPlacement_Confirmed", false];
    missionNamespace setVariable ["MWF_BuildPlacement_Active", false];
    if ((missionNamespace getVariable ["MWF_SensitiveInteraction_Type", ""]) isEqualTo "BUILD_PLACEMENT") then {
        missionNamespace setVariable ["MWF_SensitiveInteraction_Type", nil];
    };
    _interrupted = true;
};

if (missionNamespace getVariable ["MWF_VehiclePlacement_Active", false]) then {
    [] call MWF_fnc_cleanupVehiclePlacement;
    _interrupted = true;
};

private _dataHubDisplay = uiNamespace getVariable ["MWF_DataHub_Display", displayNull];
if (!isNull _dataHubDisplay) then {
    ["CLOSE"] call MWF_fnc_dataHub;
    _interrupted = true;
};

private _curatorDisplay = findDisplay 312;
if (!isNull _curatorDisplay) then {
    _curatorDisplay closeDisplay 2;
    _interrupted = true;
};

if (_interrupted) then {
    [["INTERACTION INTERRUPTED", _interruptReason], "warning"] call MWF_fnc_showNotification;
};

_interrupted
