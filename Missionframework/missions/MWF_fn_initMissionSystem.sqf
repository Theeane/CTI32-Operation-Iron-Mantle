/*
    Author: Theane / ChatGPT
    Function: fn_initMissionSystem
    Project: Military War Framework

    Description:
    Initializes the folder-driven rotating side mission framework.
    The system waits for zone, world, and threat foundations, discovers templates from folders,
    generates session-only placements, and rotates fixed mission board slots every 5 minutes.
*/

if (!isServer) exitWith {};
if (missionNamespace getVariable ["MWF_MissionSystemStarted", false]) exitWith {};

missionNamespace setVariable ["MWF_MissionSystemStarted", true, true];
missionNamespace setVariable ["MWF_MissionSystemReady", false, true];

[] spawn {
    private _startupDeadline = diag_tickTime + 120;

    waitUntil {
        uiSleep 1;
        (
            missionNamespace getVariable ["MWF_ZoneSystemReady", false] &&
            missionNamespace getVariable ["MWF_WorldSystemReady", false] &&
            missionNamespace getVariable ["MWF_ThreatSystemReady", false]
        ) || {diag_tickTime >= _startupDeadline}
    };

    if (!(missionNamespace getVariable ["MWF_ZoneSystemReady", false])) then {
        diag_log "[MWF Missions] Startup timeout reached before zone system reported ready. Continuing with current zone registry.";
    };
    if (!(missionNamespace getVariable ["MWF_WorldSystemReady", false])) then {
        diag_log "[MWF Missions] Startup timeout reached before world system reported ready. Continuing with current world outputs.";
    };
    if (!(missionNamespace getVariable ["MWF_ThreatSystemReady", false])) then {
        diag_log "[MWF Missions] Startup timeout reached before threat system reported ready. Continuing with current threat outputs.";
    };

    private _templates = [];
    if (!isNil "MWF_fnc_discoverMissionTemplates") then {
        _templates = [] call MWF_fnc_discoverMissionTemplates;
    };

    if (_templates isEqualTo []) then {
        diag_log "[MWF Missions] No mission templates discovered. Mission board will remain empty until templates exist.";
        missionNamespace setVariable ["MWF_MissionSystemReady", true, true];
    } else {
        if (!isNil "MWF_fnc_buildMissionSessionPlacements") then {
            [_templates] call MWF_fnc_buildMissionSessionPlacements;
        };

        if (!isNil "MWF_fnc_buildGrandOperationPlacements") then {
            [] call MWF_fnc_buildGrandOperationPlacements;
        };

        if (!isNil "MWF_fnc_refreshMissionBoard") then {
            [] call MWF_fnc_refreshMissionBoard;
        };

        private _pendingActiveMissions = + (missionNamespace getVariable ["MWF_PendingActiveSideMissions", []]);
        if !(_pendingActiveMissions isEqualTo []) then {
            {
                private _savedMissionKey = _x param [0, ""];
                if (_savedMissionKey isNotEqualTo "") then {
                    private _registry = + (missionNamespace getVariable ["MWF_MissionTemplateRegistry", []]);
                    private _templateIndex = _registry findIf { (_x # 0) isEqualTo _savedMissionKey };

                    if (_templateIndex < 0) then {
                        diag_log format ["[MWF Missions] Pending mission restore skipped. Template key not found: %1", _savedMissionKey];
                    } else {
                        private _template = + (_registry # _templateIndex);
                        _template params ["_missionKey", "_category", "_difficulty", "_missionId", "_missionPath"];

                        private _placements = + (missionNamespace getVariable ["MWF_MissionSessionPlacements", []]);
                        private _placementIndex = _placements findIf { (_x # 0) isEqualTo _missionKey };

                        if (_placementIndex < 0) then {
                            diag_log format ["[MWF Missions] Pending mission restore skipped. Placement key not found: %1", _missionKey];
                        } else {
                            private _placement = + (_placements # _placementIndex);
                            _placement params ["_placementMissionKey", "_position", "_zoneId", "_zoneName"];

                            private _boardSlots = + (missionNamespace getVariable ["MWF_MissionBoardSlots", []]);
                            private _slotIndex = _boardSlots findIf { (_x # 4) isEqualTo _missionKey };
                            if (_slotIndex >= 0) then {
                                _slotIndex = (_boardSlots # _slotIndex) # 0;
                            } else {
                                _slotIndex = -1;
                            };

                            private _slotData = [
                                _slotIndex,
                                _category,
                                _difficulty,
                                _missionId,
                                _placementMissionKey,
                                _missionPath,
                                _position,
                                _zoneId,
                                _zoneName,
                                "active"
                            ];

                            [_slotData, objNull, _category, _difficulty, _missionId] call MWF_fnc_executeMissionTemplate;
                        };
                    };
                };
            } forEach _pendingActiveMissions;

            missionNamespace setVariable ["MWF_PendingActiveSideMissions", [], true];
            missionNamespace setVariable ["MWF_PendingActiveSideMissionsRestored", true, true];
            diag_log format ["[MWF Missions] Restored %1 pending active mission(s).", count _pendingActiveMissions];
        };

        missionNamespace setVariable ["MWF_MissionSystemReady", true, true];
        diag_log format ["[MWF Missions] Mission system ready. Templates discovered: %1.", count _templates];
    };

    while {true} do {
        private _systemReady = missionNamespace getVariable ["MWF_MissionSystemReady", false];
        private _expiresAt = missionNamespace getVariable ["MWF_MissionBoardExpiresAt", 0];

        if (_systemReady && {serverTime >= _expiresAt}) then {
            [] call MWF_fnc_refreshMissionBoard;
            diag_log "[MWF Missions] Mission board rotated.";
        };

        uiSleep 5;
    };
};
