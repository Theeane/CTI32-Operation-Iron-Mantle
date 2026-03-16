params [["_unit", objNull, [objNull]], ["_curator", objNull, [objNull]]];
if (!isServer) exitWith {};
if (!isNull _unit) then { unassignCurator _curator; };
if (!isNull _curator) then { deleteVehicle _curator; };
