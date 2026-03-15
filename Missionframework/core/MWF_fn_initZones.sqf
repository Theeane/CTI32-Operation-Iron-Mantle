// MWF_fn_initZones.sqf
// Date: 2026-03-15 13:12:17 UTC
// This script initializes zone capture loops for all registered zone objects.

// List of all registered zones
private _zones = ["Zone1", "Zone2", "Zone3"]; // Example zone names

// Function to start capture loop for each zone
{ 
    private _zone = _x;
    // Your zone start logic here
    hint format ["Starting capture loop for %1", _zone];
} forEach _zones;