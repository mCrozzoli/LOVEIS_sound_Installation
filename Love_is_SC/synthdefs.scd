//1.
(
SynthDef(\noise, {
	arg gate=1, amp=0.5, freq=#[1200,500,200,1100,700,1500], atk=0.05, rel=5; //, data=#[0,0];
	var sig, res, pan, env;
	sig = Crackle.ar(Rand(0.5,1.8));
	res = Resonz.ar(sig, freq, freq/100);
	env = EnvGen.kr(Env.perc(atk,rel,1,2), gate:gate, doneAction:2);
	sig = sig * res * env * amp;
	pan = Pan2.ar(sig, Rand(-1,1));
	Out.ar(0,pan);
}).add;
);


//2.
(
SynthDef(\blipenvironment, {
	arg gate=1, amp=1, freq1 = 150, freq2 = 25;
	var sig, env, freq;
	freq = SinOsc.ar([freq1, freq2],0,0.25);
	sig = Blip.ar(freq,0,0.25);
	env = EnvGen.kr(Env.triangle(7, 2), doneAction:2); //gate:gate???
	sig = sig * env * amp;
	Out.ar(0,sig);
}).add;
);


//3.
(
SynthDef(\backbeating ,{
	arg freq=200, atk=2, rel=1, gate=1, amp=0.25; //atk and rel?
	var sig, pan, sig2, env, env2;
	freq = Array.exprand(8, 250, 1200);
	sig = SinOsc.ar(freq, 1, 0.25);
	sig = LPF.ar(sig,1150,0.25)*rand(2,5);
	sig2 = LFDNoise3.ar(LastValue.ar(freq,0.01))*0.5;
	sig2 = LPF.ar(sig2,220,0.25);
	env = EnvGen.kr(Env.perc(atk, rel, 1, -1),doneAction:2); //gate????
	env2 = EnvGen.kr(Env.linen(1, 10, 5, 0.6, \sine),doneAction:2); //gate??
	sig = sig*env*amp;
	sig2 = sig2*env2*amp;
	pan = (sig + sig2)!2 * 0.15;
	Out.ar(0,pan);
	FreeSelf.kr(Done.kr(env)*Done.kr(env2));
}).add;
);


//4.
(
SynthDef(\spookyreso, {
	arg out=0, gate = 1, amp = 0.25, atk=5, rel=6, freq=440;
    var pan, env, freqdev, sig;
    pan = LFNoise0.kr(1);
    freqdev = WhiteNoise.kr(10).exprand(100,5000);
	sig = GrainFM.ar(2, Impulse.kr(10), 1.5, freq + freqdev, 1200, LFNoise1.kr.range(1, 50),pan, -1,500,amp);
	env = EnvGen.kr(Env.pairs({ { 3.0.rand } ! 2 } ! 16, \exp),2,gate: gate, doneAction:2);
    sig = sig * env * amp;
	Out.ar(out, sig)
}).add;
);

//5.
(
SynthDef(\organ,{
	arg out =0, gate=1, fb=1, amp=0.25, freq1=rrand(100,250), freq2=rrand(250,750);
	var sig, env, harm;
	sig = SinOscFB.ar([freq1, freq2],fb,0.25)!4; //FB in relation to heart b
	//harm = Harmonics.new(16);
	env = EnvGen.kr(Env.linen(5, 12, 10, 1, [[\sine, \welch, \lin, \exp]]), doneAction:2); // gate:gate
	sig = sig*env*amp;
	sig = RLPF.ar(sig,XLine.kr(200,4000,25), 0.1, 0.25); //rq in relation to heart beat
	Out.ar(out,sig);
}).add;
);