// Environment_01
s.meter
(
s.waitForBoot({
	s.meter;
	s.plotTree;

	// Filter
	SynthDef.new(\limiter, {|in=0, out=0|
		var sig_in, leaked, limited;

		sig_in = In.ar(in, 2); // Bring signal stream into synth
		leaked = LeakDC.ar(sig_in); // eliminate any built up DC offset
		limited = Limiter.ar(leaked, 0.99);  // signal maxes out JUST below unity gain

		ReplaceOut.ar(out, limited); // ReplaceOut so that the resulting signal overwrites the previous
	}).play;
})
)

// Synth.new if nothing is happening yet
y = Synth.new(\limiter);

// Synth.after if the audio is already running.
y = Synth.after(x, \limiter); // make sure the limiter is the LAST item on the node tree
y.free;

// SynthDef to test
(
SynthDef(\klang, {
	|freq=440, out=0, dur=0.5, pan = -1, gate=1|
	var sig, env;

	sig = Klang.ar(`[ [freq, freq * 2.1, freq * 4.9], [0.6, 0.3, 0.1], nil ]);
	//sig = Klang.ar(`[ Array.fill(3, { rand2(freq*0.9, freq*1.1) }), [0.6, 0.3, 0.1], nil ], mul:0.5);

	sig = Pan2.ar(sig, pan, 1);
	env = EnvGen.kr(Env.adsr(attackTime: 0.01, decayTime: 0.1, sustainLevel: 0.3, releaseTime:0.2), gate:gate, doneAction: 2);

	Out.ar(out, sig * env * 0.5);

}).add;

SynthDef(\reson, {
	|freq=440, out=0, dur=0.5, pan = -1, gate=1|
	var sig, env, bwr = 0.01;

	sig = Resonz.ar(WhiteNoise.ar(1), freq, bwr: bwr, mul: 1/bwr);


	sig = Pan2.ar(sig, pan, 1);
	env = EnvGen.kr(Env.adsr(attackTime: 0.01, decayTime: 0.1, sustainLevel: 0.3, releaseTime:0.2), gate:gate, doneAction: 2);

	Out.ar(out, sig * env * 0.5);

}).add;

)

(
// add `numpats` of EventStreamPlayers using `scale`
~addemup = {|numpats, scale|
	numpats.do({
		p = p.add(Pbind( // add pattern to Array p
			\instrument, Pwrand([\klang, \reson], [0.8, 0.2], inf),
			\scale, scale,
			\root, Pwrand([ -24, -12, 0, 12, 17 ], [ 0.1, 0.2, 0.5, 0.2, 0.1 ], inf), // pick a root x semitones from middle C
			\degree, Pwalk( // random walk up and down
				(0..20), // list (of degrees to walk through)
				Pwrand([-1,1, -3, 3],[0.3, 0.6, 0.6, 0.3], inf), // stepPattern (steps up and skips down are more likely)
				1, // directionPattern (turn around at boundary)
				0 // startPos
			),
			\dur, Pwrand(0.2 * [1, 2, 4, 5], [0.8, 0.1, 0.05, 0.05], inf),
			\legato, 1,
			\pan, Pgauss(
				mean: 0,
				dev: 1,
				length: inf),
		).play;)
	})
}
)

// start up 1 or more streams
~addemup.value(numpats: 3, scale: Scale.augmented);

// stop all streams and clear the array
p.reverseDo({arg n, i; (p[i].stop)});


x = { Resonz.ar(WhiteNoise.ar(0.5), 440, 0.05) }.scope(1);
x.free



s.meter
s.quit

s.plotTree