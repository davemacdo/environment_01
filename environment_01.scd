// Environment_01

s.boot


// SynthDef to test
(
SynthDef(\bloop, {
	|freq=440, out=0, dur=0.5, pan=0, gate=1|
	var sig, env;

	sig = Pan2.ar(SinOsc.ar(freq, mul: 0.9), pan);
	env = EnvGen.kr(Env.adsr(attackTime: 0.01, decayTime: 0.1, sustainLevel: 0.7, releaseTime:0.2), gate:gate, doneAction: 2);

	Out.ar(out, sig * env);

}).add;
)

(
p = Pbind(
	\instrument, \bloop,
    \freq, Pseq([200, 200, 400, 300, 600, 660, 330], inf),
    \dur, Pseq([0.1, 0.1, 0.1, 0.1, 0.1, 0.3], inf),
	\legato, 1
).play;
)

p.stop

x.free

s.quit

