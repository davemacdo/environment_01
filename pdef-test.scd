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
SynthDef(\sinetone, {
	|freq = 440, rate = 0.2|
	var sig;
	sig = SinOsc.ar(freq: freq, mul: 0.8);
	Out.ar(0, sig);

}).add;
)

x = Synth.new(\sinetone)
x.free

(
Pdef(\drone,
	Pbind(
		\instrument, \sinetone,
		\degree, Pseq([0, 1, 2, 4, 6, 3, 4, 8], inf),
		\dur, Prand([0.2, 0.4, 0.8], inf),
		\amp, 0.05,
		\octave, 5,
	)
);
)

Pdef(\drone).play;

Pdef(\drone, Pbind(\degree, Pseq([0],1)));

(
~degree = PatternProxy(Pn(Pseries(0, 1, 8), inf));
~dur = PatternProxy(Pn(0.25, inf));
~scale = PatternProxy(Pn(Scale.major));

p = Pbind(
    \degree, ~degree,
    \dur, ~dur,
	\scale, ~scale,
).play(quant: 1);
)

Scale.directory

~degree.source = (Pexprand(1, 8, inf) - 1).round;
~degree.source = (Pseq([0,1,2],1));
~degree.source = Pseq((0..20),inf);
~scale.source = Scale.chromatic24
~degree.source = \rest;


~dur.source = Pwrand(#[0.25, 0.5, 0.75], #[0.5, 0.3, 0.2], inf);

p.stop;
