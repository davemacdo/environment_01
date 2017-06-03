// Environment_01

s.boot;
s.meter(2,8);
s.plotTree;

( // Filter
SynthDef.new(\limiter, {|in=0, out=0|
	var sig_in, leaked, limited;

	sig_in = In.ar(in, 2); // Bring signal stream into synth
	leaked = LeakDC.ar(sig_in); // eliminate any built up DC offset
	limited = Limiter.ar(leaked, 0.99);  // signal maxes out JUST below unity gain

	ReplaceOut.ar(out, limited); // ReplaceOut so that the resulting signal overwrites the previous
}).add;
)

// Synth.new if nothing is happening yet
y = Synth.new(\limiter);

// Synth.after if the audio is already running.
y = Synth.after(x, \limiter); // make sure the limiter is the LAST item on the node tree
y.free;

// SynthDef to test
(
SynthDef(\bloop, {
	|freq=440, out=0, dur=0.5, pan=0, gate=1|
	var sig, env;

	sig = Klang.ar(`[ [freq, freq * 2.1, freq * 4.9], [0.6, 0.3, 0.1], nil ], mul:0.5);
	//sig = Klang.ar(`[ Array.fill(3, { rand2(freq*0.9, freq*1.1) }), [0.6, 0.3, 0.1], nil ], mul:0.5);

	sig = Pan2.ar(sig, pan);
	env = EnvGen.kr(Env.adsr(attackTime: 0.01, decayTime: 0.1, sustainLevel: 0.3, releaseTime:0.2), gate:gate, doneAction: 2);

	Out.ar(out, sig * env * 0.5);

}).add;
)

(
p = Pbind(
	\instrument, \bloop,
	\scale, Scale.augmented,
	\root, -10,
    // \degree, Pxrand((0..5), inf),
	\degree, Pwalk(
		(0..20), // list
		Pwrand([-1,1, -3, 3],[0.3, 0.6, 0.6, 0.3], inf), // stepPattern
		1, // directionPattern (at boundary)
		0 // startPos
	),
    \dur, Pwrand(0.2 * [1, 2, 4, 5], [0.5, 0.2, 0.2, 0.1], inf),
	\legato, 1,
).play;
)

x = { LFNoise0.ar(MouseX.kr(200, 10000, 1), 0.25) }.scope(1);
x.free

p.stop

s.quit

s.plotTree