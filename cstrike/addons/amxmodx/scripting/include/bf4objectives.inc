#if defined _bf4objectives_included
	#endinput
#endif
#define _bf4objectives_included

// API version 1. Teams use engine IDs: neutral/draw=0, T=1, CT=2.
// Modes: disabled=0, domination=1, conquest=2. Point indices are zero-based A..G.
// No compatibility csf_* events are emitted by the independent provider.
native BF4ObjectivesAPIVersion();
native BF4ObjectiveMode();
native bool:BF4ObjectivesRunning();
native BF4ObjectiveTickets(team);
forward BF4ObjectiveCaptured(id, point, team);
forward BF4ObjectiveMatchEnded(mode, winner);
