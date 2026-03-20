/*
    Author: Theeane / ChatGPT / Gemini
    File: initPlayerLocal.sqf
    Project: Military War Framework
    Description:
    Handles client-side initialization for each player.
*/

// Wait until server initialization is complete
waitUntil { missionNamespace getVariable ["MWF_ServerInitialized", false] };

// Log player initialization start
diag_log format ["[MWF] INFO: Player initialization started for %1.", name player];

// Initialize UI
[] call MWF_fnc_initUI;

// Setup player interactions
[] call MWF_fnc_setupInteractions;

// Initialize loadout + undercover client systems
[] call MWF_fnc_initLoadoutSystem;
[] spawn MWF_fnc_undercoverHandler;

// Update resource display
[] call MWF_fnc_updateResourceUI;

// Log completion
diag_log format ["[MWF] SUCCESS: Player initialization completed for %1.", name player];

[] spawn {
    uiSleep 3;

    if !(missionNamespace getVariable ["MWF_HasCampaignSave", false]) exitWith {};

    private _loadSummary = missionNamespace getVariable ["MWF_LastLoadSummary", []];
    if (_loadSummary isEqualType [] && {count _loadSummary >= 6}) then {
        _loadSummary params [
            ["_phase", "TUTORIAL", [""]],
            ["_zoneCount", 0, [0]],
            ["_vehicleCount", 0, [0]],
            ["_missionCount", 0, [0]],
            ["_damagedFobCount", 0, [0]],
            ["_grandOpActive", false, [true]]
        ];

        private _loadText = format [
            "Campaign restored. Phase: %1 | Saved zones: %2 | Bought vehicles: %3 | Active side missions: %4 | Damaged FOBs: %5",
            _phase,
            _zoneCount,
            _vehicleCount,
            _missionCount,
            _damagedFobCount
        ];
        if (_grandOpActive) then {
            _loadText = _loadText + " | Main operation active";
        };

        [["SAVE RESTORED", _loadText], "info"] call MWF_fnc_showNotification;
    };

    uiSleep 2;

    private _restoreSummary = missionNamespace getVariable ["MWF_LastRestoreSummary", []];
    if (_restoreSummary isEqualType [] && {count _restoreSummary >= 2}) then {
        _restoreSummary params [
            ["_restoredVehicles", 0, [0]],
            ["_failedVehicles", 0, [0]]
        ];

        private _restoreText = format ["Bought vehicles restored: %1", _restoredVehicles];
        if (_failedVehicles > 0) then {
            _restoreText = _restoreText + format [" | Failed restores: %1", _failedVehicles];
        };

        [["SESSION RESTORE", _restoreText], "info"] call MWF_fnc_showNotification;
    };
};
