/*
    Author: Theane using gemini
    Function: Dynamic Unit & Zone Cleanup
    Description: Monitors Unit Cap. Deletes furthest units and resets their 
    parent zone's spawn status to allow future respawning.
*/

if (!isServer) exitWith {};

private _unitCap = missionNamespace getVariable ["CTI32_UnitCap", 140];

diag_log format ["[CTI32 CLEANUP] Dynamic Monitor active. Cap: %1", _unitCap];

while {true} do {
    private _allOpfor = allUnits select {side _x == east && alive _x};
    private _currentCount = count _allOpfor;

    // If we exceed the cap, start the smart deletion process
    if (_currentCount > _unitCap) then {
        private _amountToDelete = _currentCount - _unitCap;
        private _allPlayers = allPlayers select {alive _x};

        // Sort units by distance to nearest player (furthest first)
        private _sortedUnits = [_allOpfor, [], {
            private _unit = _x;
            private _closestDist = 99999;
            {
                private _dist = _unit distance _x;
                if (_dist < _closestDist) then { _closestDist = _dist; };
            } forEach _allPlayers;
            _closestDist
        }, "DESCEND"] call BIS_fnc_sortBy;

        private _deletedCount = 0;
        {
            if (_deletedCount >= _amountToDelete) exitWith {};

            // RULE: Never delete units belonging to the Final Mission
            private _isPersistent = _x getVariable ["CTI32_IsPersistent", false];
            
            if (!_isPersistent) then {
                // Get the parent zone reference before deleting
                private _parentZoneID = _x getVariable ["CTI32_ParentZoneID", -1];
                private _zoneType = _x getVariable ["CTI32_ZoneType", ""]; // "RB" or "HQ"

                // Reset the spawn flag in the global arrays so it can respawn later
                if (_parentZoneID != -1) then {
                    switch (_zoneType) do {
                        case "RB": {
                            { if (_x select 4 == _parentZoneID) exitWith { _x set [3, false]; }; } forEach CTI32_ActiveRoadblocks;
                        };
                        case "HQ": {
                            { if (_x select 4 == _parentZoneID) exitWith { _x set [3, false]; }; } forEach CTI32_ActiveHQ;
                        };
                    };
                };

                // Cleanup the unit and its vehicle
                private _veh = vehicle _x;
                deleteVehicle _x;
                if (count (crew _veh) == 0 && _veh != _x) then { deleteVehicle _veh; };
                
                _deletedCount = _deletedCount + 1;
            };
        } forEach _sortedUnits;

        diag_log format ["[CTI32 CLEANUP] Cap exceeded. %1 units removed and zones reset.", _deletedCount];
    };

    sleep 10;
};
