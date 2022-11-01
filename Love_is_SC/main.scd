(
"OSC.scd".loadRelative;
"COM.scd".loadRelative;
~pdefs = [\blipy, \bbeating, \spooky, \blip];

s.waitForBoot({
	ServerQuit.add {
		"Error: server quit. Exiting.".postln;
		1.exit;
	};
	"synthdefs.scd".loadRelative;
	h.init;
	"pdefs.scd".loadRelative;
	~sensor.init("/dev/ttyUSB0", 115200, {
		"Error: can't open serial port. Exiting.".postln;
		1.exit;
	});

	Pdef(\sand).play;
}, 100, {
	"Error: server failed to start after 100 tries. Exiting.".postln;
	1.exit;
});
)