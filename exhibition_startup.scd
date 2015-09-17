s.boot();

SynthDef(\gabor0Wall, {| out, freq = 440, sustain = 0.02, amp = 0.02, pan, x = 0, y = 0, z = 0 |
	var env = EnvGen.ar(Env.sine(sustain, amp), doneAction: 2);
	var sound = SinOsc.ar(freq) * env;
	OffsetOut.ar(out, [
		// channel 1
		MulAdd(sound, ((1 - ((-960-x).abs/1920))*((1120+z)/1120))),
		// channel 2
		MulAdd(sound, ((1 - ((960-x).abs/1920))*((1120+z)/1120)))]
	)
}, \ir.dup(5)).add;

SynthDef(\gaborGlissWall, {| out, freq_start = 440, freq_end = 880, sustain = 0.02, amp = 0.02, pan, x = 0, y = 0, z = 0 |
	var env = EnvGen.ar(Env.sine(sustain, amp), doneAction: 2);
	var sound = SinOsc.ar(XLine.kr(freq_start, freq_end, sustain, doneAction: 2)) * env;
	OffsetOut.ar(out, [
		// channel 1
		MulAdd(sound, ((1 - ((-960-x).abs/1920))*((1120+z)/1120))),
		// channel 2
		MulAdd(sound, ((1 - ((960-x).abs/1920))*((1120+z)/1120)))]
	)
}, \ir.dup(5)).add;

MenagerieEngine.new("192.186.1.86", 12345);