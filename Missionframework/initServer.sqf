sqf
// Author: Theane / ChatGPT
// Project: Mission War Framework

// Server-side initialization
hint "Mission War Framework: Server initialization started.";

// Define current era and default uniform
MWF_Current_Era = "Vietnam"; // Example: "Vietnam" or "Modern"
MWF_Default_Uniform = "U_B_CombatUniform_mcam"; // Example: Default uniform

// Load the blacklist lists
preprocessFileLineNumbers "preset/blacklist/global_blacklist.sqf";
preprocessFileLineNumbers "preset/blacklist/modern_removed.sqf";

// Initialize the blacklist manager
[] execVM "preset/blacklist/blacklist_manager.sqf";
MWF_fnc_blacklistManager; // Call the function to set the undercover blacklist

// Define the base radius for arsenal and build mode
MWF_Base_Radius = 500; // Example radius value (meters)

// Make MWF_Undercover_Blacklist available to all clients
publicVariable "MWF_Undercover_Blacklist";

// Example of further server-side logic can be added below.
