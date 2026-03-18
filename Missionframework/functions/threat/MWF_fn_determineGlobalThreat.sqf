/*
    Author: Theane / ChatGPT
    Function: fn_determineGlobalThreat
    Project: Military War Framework

    Description:
    Converts the authoritative dynamic threat percent into the legacy threat layer output.
    Returns [threatLevel, threatState, pressureScore].
*/

private _threatPercent = missionNamespace getVariable ["MWF_GlobalThreatPercent", 0];
_threatPercent = (_threatPercent max 0) min 100;

private _threatLevel = 0;
private _threatState = "low";

switch (true) do {
    case (_threatPercent >= 80): { _threatLevel = 5; _threatState = "hunt"; };
    case (_threatPercent >= 60): { _threatLevel = 4; _threatState = "search"; };
    case (_threatPercent >= 40): { _threatLevel = 3; _threatState = "active"; };
    case (_threatPercent >= 20): { _threatLevel = 2; _threatState = "elevated"; };
    case (_threatPercent >= 5):  { _threatLevel = 1; _threatState = "watch"; };
    default { _threatLevel = 0; _threatState = "low"; };
};

[_threatLevel, _threatState, _threatPercent]
