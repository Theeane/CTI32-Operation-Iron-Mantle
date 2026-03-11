/* Author: Theeane
    Description: 
    Cleans up units and vehicles in a zone when players leave the area.
    Ensures server performance remains stable.
*/

params ["_zonePos", "_despawnRadius"];

// 1. Identify all units within the radius
private _unitsInArea = allUnits select { _x distance _zonePos < _despawnRadius };

{
    // 2. Only delete AI units (never players)
    if (!isPlayer _x) then {
        
        // 3. Check if unit is part of the zone logic (not a player-driven vehicle or squad)
        private _isPermanent = _x getVariable ["GVAR_isPermanent", false];
        
        if (!_isPermanent) then {
            private _group = group _x;
            deleteVehicle _x;
            
            // Delete the group if it becomes empty to save group headers
            if (count (units _group) == 0) then {
                deleteGroup _group;
            };
        };
    };
} forEach _unitsInArea;

diag_log format ["[Iron Mantle] Zone at %1 cleaned up. Units removed.", _zonePos];
