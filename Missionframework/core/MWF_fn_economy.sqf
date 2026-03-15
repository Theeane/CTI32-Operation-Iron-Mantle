// MWF_fnc_addResource: Function to add resources in the economy.
function MWF_fnc_addResource {_amount,_resourceType} {
    // Handle adding resources logic here
    // Example: resources[_resourceType] += _amount;
}

// Economy loop logic to handle the shared economy and notoriety decay.
while {true} do {
    // Logic for updating economy over time
    // Pseudo code for notoriety decay
    // notoriety -= decayRate;
    // Handle resource income over time
    // Example: call MWF_fnc_addResource with income values
    sleep 60; // Adjust the sleep duration as necessary
} 

// Shared economy helpers can be defined here.

// To initialize the economy, call these functions at the start of the mission.
MWF_fnc_addResource(100, "money"); // Example to add starting resources