s.boot


(
p = Pbind(
	\scale, Scale.augmented,
	\root, -7,
	\degree, Pwalk( // random walk up and down
		(0..50), // list (of degrees to walk through)
		//Pwrand([-1,1, -3, 3, 6, -6],[0.3, 0.6, 0.6, 0.3, 0.1, 0.1], inf), // stepPattern (steps up and skips down are more likely)
		Pwrand([1, 3, 6],[0.6, 0.3, 0.1], inf) * Pwrand([-1, 1], [0.4, 0.6], inf),
		// 1,
		1, // directionPattern (turn around at boundary)
		0 // startPos
	),
	\dur, Pwrand(0.2 * [1, 2, 4, 5], [0.8, 0.1, 0.05, 0.05], inf),
	\legato, 1,
	\pan, Pgauss(
		mean: 0,
		dev: 1,
		length: inf),
	\do, Pfunc { |e| if (e.degree > 20) { p.stop }{ p } },

).play(quant: 4);
)


p.stop
Scale.directory