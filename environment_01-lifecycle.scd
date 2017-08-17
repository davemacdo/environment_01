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

(
// Scales
~nineteenChrom = Scale.new((0..18), 19, name: "19EDO");
~nineteenSub1 = Scale.new([0,3,4,7,8,10,12,13,16,18], 19, name: "19EDO");

// SynthDefs
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
	|freq=440, out=0, dur=0.5, pan = -1, gate=1, bwr=0.01|
	var sig, env;

	sig = Resonz.ar(WhiteNoise.ar(1), freq, bwr: bwr, mul: 1/bwr);

	sig = Pan2.ar(sig, pan, 1);
	env = EnvGen.kr(Env.adsr(attackTime: 0.01, decayTime: 0.1, sustainLevel: 0.3, releaseTime:0.2), gate:gate, doneAction: 2);

	Out.ar(out, sig * env * 0.5);

}).add;

)

(
// add `numpats` of EventStreamPlayers using `scale`
~addemup = {|numpats, scale, rate=0.2, synth=\klang, bwrval=0.01|
	numpats.do({
		var streamID;
		streamID = p.size.postln;
		p = p.add([Pbind( // add EventStreamPlayer to Array p
			\instrument, synth,
			\scale, scale,
			\root, Pwrand([ -24, -12, 0, 12, 17 ], [ 0.1, 0.2, 0.5, 0.2, 0.1 ], inf), // pick a root x semitones from middle C
			\degree, Pwalk( // random walk up and down
				(0..20), // list (of degrees to walk through)
				Pwrand([-1,1, -3, 3, 6, -6],[0.4, 0.6, 0.4, 0.6, 0.1, 0.1], inf), // stepPattern (steps up and skips down are more likely)
				1, // directionPattern (turn around at boundary)
				0 // startPos
			),
			\dur, Pwrand(rate * [1, 2, 4, 5], [0.8, 0.1, 0.05, 0.05], inf),
			\legato, 1,
			\pan, Pgauss(
				mean: 0,
				dev: 1,
				length: inf),
			\bwr, bwrval,
			\do, Pfunc { |e| if (e.degree > 12) { p[streamID][0].stop }{ p; } },

		).play(quant: 4),
		scale.name,
		rate,
		synth,
		bwrval
		];)
	})
};

// last in, first out
~pattbounce = {p[(p.size - 1)][0].stop;};

// first in, first out
~pattretire = {p[0][0].stop;};

)

// start up 1 or more streams
~addemup.value(numpats: 1, scale: ~nineteenSub1, rate: 0.2, synth: \klang, bwrval: 0.3);

// remove the most recent stream
~pattbounce.value

// remove the oldest stream
~pattretire.value

// stop all streams and clear the array
~pattretire.dup(p.size);
p.size

( // Stop all pattern streams
p.do({arg item, i;
	item[0].stop;
})
)


z = [1, 2, 3]
z.add("test")
z.size

~foobar.size