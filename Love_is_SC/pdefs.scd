(
Pdef(\blipy, Pfindur(25, Ppar( [0, 1].collect {
	arg n;
	Pbind(
		\instrument, \blipenvironment,
		\freq1, Pfunc{h.beat(n).linlin(55,150, 25,75)},
		\freq2, Pfunc{h.beat(n).linlin(55,150, 95,225)},
		\dur, Pfunc{ h.beat(n) / 100 }, //0 or 1 is the miband device.
		\detune, Pfunc{h.beat(n).linlin(55,150, 7, 15)}, //Pexprand(10,15, inf),
		\amp, Pfunc{ h.beat(n) / 1500 },//0.5,
	)
})));
);

(
Pdef(\bbeating, Pfindur(35, Ppar( [0, 1].collect {
	arg n;
	Pbind(
	\instrument, \backbeating,
	\freq, Pfunc{h.beat(n).linexp(55,150, 1200,250)},
	\atk, Pfunc{h.beat(n).linexp(55,150, 1.5,10)},//Pwhite(1.5, 5, inf),
	\rel, Pfunc{h.beat(n).linlin(55,150, 15,25)},//Pwhite(1, 10, inf),
	\dur, Pfunc{h.beat(n).linexp(55,150, 15,35)},//30,
	\amp, Pfunc{h.beat(n).linlin(55,150, 0.007,0.02)}, //0.25,
	)
})));
);

(
Pdef(\spooky, Pfindur(15, Ppar( [0, 1].collect {
	arg n;
	Pbind(
	\instrument, \spookyreso,
	\freq, Pfunc{h.beat(n).linexp(55,150, 700,250)},//Pfunc{ h.beat(n) * 250 },
	\amp, Pfunc{h.beat(n).linexp(55,150, 0.003,0.007)}, //0.5,
	)
})));
);

(
Pdef(\blip, Pfindur(45, Ppar( [0, 1].collect {
	arg n;
	Pbind(
	\instrument, \organ,
	\freq1, Pfunc{h.beat(n).linlin(55,150, 250, 750)},
	\freq2, Pfunc{h.beat(n).linlin(55,150, 1200,2200)},
	\dur, Pexprand(2,7,inf),
	\fb, Pexprand(0.1,1,inf),
	\amp, Pfunc{h.beat(n).linlin(55,150, 0.09,0.01)}, //0.55,
	)
})));
);

(
Pdef(\sand, Ppar( [0, 1].collect {
	arg n;
	Pbind(
	\instrument, \noise,
	\freq, Pfunc{h.beat(n).linexp(55,150, 1000,2100)}, //is this ok?
	\atk, Pfunc{h.beat(n).linexp(55,150, 1.5,2.5)}, //Pwhite(1.5, 2.5, inf),
	\rel, Pfunc{h.beat(n).linexp(55,150, 10,6)}, //Pwhite(6, 10, inf),
	\dur, 1,
	\amp, Pfunc{h.beat(n).linlin(55,150, 0.15,0.45)},//0.55,
	)
}));
);

//Pdef(\blipy).play;