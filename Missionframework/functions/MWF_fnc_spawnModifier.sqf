sqf
// Author: Theane / ChatGPT
// Project: Mission War Framework

MWF_fnc_spawnModifier = {
    params ["_units"];

    // Adjust the number of spawned units based on global patrol density
    private _adjustedUnits = _units * MWF_Global_PatrolDensity;

    // Return the adjusted number of units
    _adjustedUnits;
};
