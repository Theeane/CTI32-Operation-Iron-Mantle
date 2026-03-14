
#include "Missionframework/preset/blufor/blufor_classnames.sqf"
#include "Missionframework/preset/civilians/civilians_classnames.sqf"

private _targetBase = getMarkerPos "disruptBase_easy";
private _undercoverBonus = false;

hint "Sabotera fiendens försörjning!";
sleep 1;

if (!isPlayerDetected) then {
    _undercoverBonus = true;
    hint "Du har genomfört uppdraget stealthy!";
} else {
    hint "Du har blivit upptäckt! Vanlig belöning.";
};

sleep 5;

private _threatLevel = getGlobalVariable ["currentThreatLevel", 0];

if (_threatLevel > 5) then {
    private _intelLaptop = createVehicle ["Laptop_Intel", _targetBase, [], 0, "NONE"];
    private _officer = createUnit [blufor_officer_classname, _targetBase, [], 0, "FORM"];
    hint "Intel Laptop och Officer har spawnt i området!";
} else {
    hint "Hotnivån är låg, ingen officer eller laptop spawnad.";
};

if (_undercoverBonus) then {
    hint "Uppdraget slutfört! Belöningar: 50 intel, 100 supply (undercover bonus).";
    player addIntel 50;
    player addSupply 100;
} else {
    hint "Uppdraget slutfört! Vanliga belöningar: 100 supply.";
    player addSupply 100;
};
