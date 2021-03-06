/*RUN*/

(
var gui = gui ? ();

SynthDef(\speakerTest, {
	|channel = -1|
	var sig = Pan2.ar(PinkNoise.ar(1), pos: channel);
	Out.ar(0, sig);
}).add;

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

Window.closeAll;

gui.w = Window.new("menagerie", Rect(75, 10, 1100, 720))
.front;

StaticText(gui.w, Rect(30, 20, 600, 50))
.string_("Algorithmic Menagerie Sound Engine")
.font_(Font("Helvetica", 20))
//.background_(Color.white)
.align_(\left)
.front;

gui.customAddr = "192.168.1.86";

StaticText(gui.w, Rect(400, 10, 100, 20))
.string_("IP Address")
.font_(Font("Helvetica", 12))
.front;

gui.customAddrValue = TextField(gui.w, Rect(425, 30, 105, 20))
.string_("localhost")
.align_(\center)
.stringColor_(Color.gray(0.6))
.background_(Color.gray(0.8))
.enabled_(false)
.front;

Button(gui.w, Rect(400, 30, 20, 20))
.states_([
	["o", Color.black],
	["x", Color.blue]
])
.action_({ |state|
	if(state.value == 0,
		{
			gui.customAddrValue.string_("localhost")
			.stringColor_(Color.gray(0.6))
			.background_(Color.gray(0.8))
			.enabled_(false);

			//gui.customAddrValue.string.postln;

			gui.startButton.action_({
				gui.customAddrValue.string.postln;
				MenagerieEngine(gui.customAddrValue.string, 12345);
			});
		}, {
			gui.customAddrValue.string_(gui.customAddr)
			.stringColor_(Color.black)
			.background_(Color.gray(0.95))
			.enabled_(true);

			//gui.customAddrValue.string.postln;

			gui.startButton.action_({
				gui.customAddrValue.string.postln;
				MenagerieEngine(gui.customAddrValue.string, 12345);
			});
		}
	)
})
.front;

gui.startButton = Button(gui.w, Rect(400, 55, 60, 25))
.states_([
	["Start", Color.gray(0.6), Color.gray(0.8)]
])
.enabled_(false)
.front;

gui.stopButton = Button(gui.w, Rect(470, 55, 60, 25))
.states_([
	["Stop", Color.black, Color.gray(0.8)]
])
.action_({
	CmdPeriod.run();
	"stopped".postln;
})
.enabled_(true)
.front;

StaticText(gui.w, Rect(550, 20, 100, 50))
.string_("Device List")
.font_(Font("Helvetica", 12))
.align_(\left)
.front;

gui.deviceListMenu = PopUpMenu(gui.w, Rect(550, 55, 155, 25))
.items_("Using defaults")
.action_({
	arg dev;

	if(dev.value == 0,
		{ // if
			dev.item.postln;
			s.options.device = nil;
		},
		{ // else
			dev.item.postln;
			s.options.device = dev.item;
		}
	);
})
.enabled_(false)
.front;

StaticText(gui.w, Rect(785, 20, 100, 50))
.string_("Server Status")
.font_(Font("Helvetica", 12))
.align_(\left)
.front;

if(s.serverRunning,
	{
		gui.statusText = StaticText(gui.w, Rect(785, 55, 140, 25))
		.string_("  Server is Booted")
		.font_(Font("Helvetica", 12))
		.stringColor_(Color.green)
		.background_(Color.black)
		.front;

		gui.startButton.states_([
			["Start", Color.black, Color.gray(0.8)]
		])
		.action_({
			MenagerieEngine(gui.customAddrValue.string, 12345);
		})
		.enabled_(true)
		.front;
	},{
		if(s.serverBooting,
			{
				gui.statusText = StaticText(gui.w, Rect(785, 55, 140, 25))
				.string_("  Server is Booting...")
				.font_(Font("Helvetica", 12))
				.stringColor_(Color.yellow)
				.background_(Color.black)
				.front;

				s.doWhenBooted({
					gui.statusText.string_("  Server is Booted")
					.font_(Font("Helvetica", 12))
					.stringColor_(Color.green)
					.background_(Color.black)
					.front;

					gui.startButton.states_([
						["Start", Color.black, Color.gray(0.8)]
					])
					.action_({
						MenagerieEngine(gui.customAddrValue.string, 12345);
					})
					.enabled_(true)
					.front;
				});
			},
			{
				gui.statusText = StaticText(gui.w, Rect(785, 55, 140, 25))
				.string_("  Server is Stopped")
				.font_(Font("Helvetica", 12))
				.stringColor_(Color.red)
				.background_(Color.black)
				.front;
			}
		);
	}
);

gui.rebootButton = Button(gui.w, Rect(715, 55, 60, 25))
.states_([["Reboot", Color.black, Color.gray(0.8)]])
.action_({
	if((s.serverRunning || s.serverBooting),
		{
			gui.statusText.string_("  Server is Booting...")
			.font_(Font("Helvetica", 12))
			.stringColor_(Color.yellow)
			.background_(Color.black)
			.front;

			gui.startButton.states_([
				["Start", Color.gray(0.6), Color.gray(0.8)]
			])
			.enabled_(false);

			s.quit;
			s.doWhenBooted({
				gui.statusText.string_("  Server is Booted")
				.font_(Font("Helvetica", 12))
				.stringColor_(Color.green)
				.background_(Color.black)
				.front;

				gui.startButton.states_([
					["Start", Color.black, Color.gray(0.8)]
				])
				.action_({
					MenagerieEngine(gui.customAddrValue.string, 12345);
				})
				.enabled_(true)
				.front;
			});

			s.boot;
		},
		{
			s.boot;
			gui.statusText.string_("  Server is Booting...")
			.font_(Font("Helvetica", 12))
			.stringColor_(Color.yellow)
			.background_(Color.black)
			.front;

			s.reboot;

			s.doWhenBooted({
				gui.statusText.string_("  Server is Booted")
				.font_(Font("Helvetica", 12))
				.stringColor_(Color.green)
				.background_(Color.black)
				.front;

				gui.startButton.states_([
					["Start", Color.black, Color.gray(0.8)]
				])
				.action_({
					MenagerieEngine(gui.customAddrValue.string, 12345);
				})
				.enabled_(true);
			});
		}
	);
})
.front;

StaticText(gui.w, Rect(948, 14, 110, 50))
.string_("Test Noise\n(L)                  (R)")
.font_(Font("Helvetica", 12))
.align_(\center)
.front;

gui.testNoiseLeftButton = Button(gui.w, Rect(935, 55, 60, 25))
.states_([
	["OFF", Color.black, Color.gray(0.8)],
	["ON", Color.red, Color.gray(0.8)]
])
.action_({
	arg obj;
	if(obj.value == 1,
		{ gui.testNoiseLeftSynth = Synth.new(\speakerTest, [\channel, -1]) },
		{ gui.testNoiseLeftSynth.free }
	);
})
.front;

gui.testNoiseRightButton = Button(gui.w, Rect(1010, 55, 60, 25))
.states_([
	["OFF", Color.black, Color.gray(0.8)],
	["ON", Color.red, Color.gray(0.8)]
])
.action_({
	arg obj;
	if(obj.value == 1,
		{ gui.testNoiseRightSynth = Synth.new(\speakerTest, [\channel, 1]) },
		{ gui.testNoiseRightSynth.free }
	);
})
.front;



gui.spacingCoeff = 70;
gui.labelWidth = 1060;
gui.labelHeight = 68;

//
//  Creature 1194D
//
//

gui.creature_1194DLabel = StaticText(
	gui.w,
	Rect(20, gui.spacingCoeff + 20, gui.labelWidth, gui.labelHeight))
.string_("   1194D")
.font_(Font("Helvetica", 12))
.align_(\left)
.background_(Color.gray(0.6))
.front;

gui.creature_1194DParam1 = NumberBox(
	gui.w,
	Rect(100, gui.spacingCoeff + 20, 70, 15))
//.value_(440.0)
.value_(Creature_1194D.get.synthParams.centerFreq)
.action_({ |obj|
	Creature_1194D.get.synthParams.centerFreq_(obj.value);
})
.front;

gui.creature_1194DParam1Label = StaticText(
	gui.w,
	Rect(100, gui.spacingCoeff + 20 + 15, 90, 15))
.string_("Center Freq")
.font_(Font("Helvetica", 10))
.front;

gui.creature_1194DParam2 = NumberBox(
	gui.w,
	Rect(100, gui.spacingCoeff + 20 + 35, 70, 15))
//.value_(112)
.value_(Creature_1194D.get.synthParams.freqOffset)
.action_({ |obj|
	Creature_1194D.get.synthParams.freqOffset_(obj.value);
})
.front;

gui.creature_1194DParam2Label = StaticText(
	gui.w,
	Rect(100, gui.spacingCoeff + 20 + 50, 90, 15))
.string_("Freq Offset")
.font_(Font("Helvetica", 10))
.front;

gui.creature_1194DParam3 = NumberBox(
	gui.w,
	Rect(190, gui.spacingCoeff + 20, 70, 15))
//.value_(56)
.value_(Creature_1194D.get.synthParams.freqScalar)
.action_({ |obj|
	Creature_1194D.get.synthParams.freqScalar_(obj.value);
})
.front;

gui.creature_1194DParam3Label = StaticText(
	gui.w,
	Rect(190, gui.spacingCoeff + 20 + 15, 90, 15))
.string_("Freq Scalar")
.font_(Font("Helvetica", 10))
.front;

gui.creature_1194DParam4 = NumberBox(
	gui.w,
	Rect(190, gui.spacingCoeff + 20 + 35, 70, 15))
//.value_(1000.0)
.value_(Creature_1194D.get.synthParams.sustainScalar)
.action_({ |obj|
	Creature_1194D.get.synthParams.sustainScalar_(obj.value);
})
.front;

gui.creature_1194DParam4Label = StaticText(
	gui.w,
	Rect(190, gui.spacingCoeff + 20 + 50, 90, 15))
.string_("Sustain Scalar")
.font_(Font("Helvetica", 10))
.front;

gui.creature_1194DParam5 = NumberBox(
	gui.w,
	Rect(280, gui.spacingCoeff + 20, 70, 15))
//.value_(56)
.value_(Creature_1194D.get.synthParams.ampScalar)
.action_({ |obj|
	Creature_1194D.get.synthParams.ampScalar_(obj.value);
})
.front;

gui.creature_1194DParam5Label = StaticText(
	gui.w,
	Rect(280, gui.spacingCoeff + 20 + 15, 90, 15))
.string_("Amplitude Scalar")
.font_(Font("Helvetica", 10))
.front;

gui.creature_1194DParam6 = NumberBox(
	gui.w,
	Rect(280, gui.spacingCoeff + 20 + 35, 70, 15))
//.value_(1000.0)
.value_(Creature_1194D.get.synthParams.delayOffsetScalar)
.action_({ |obj|
	Creature_1194D.get.synthParams.delayOffsetScalar_(obj.value);
})
.front;

gui.creature_1194DParam6Label = StaticText(
	gui.w,
	Rect(280, gui.spacingCoeff + 20 + 50, 90, 15))
.string_("Delay Offset Scalar")
.font_(Font("Helvetica", 10))
.front;

//
// Creature 1B5F1 (sequential)
//
//

gui.creature_1B5F1sLabel = StaticText(
	gui.w,
	Rect(20, gui.spacingCoeff * 2 + 20, gui.labelWidth, gui.labelHeight))
.string_("   1B5F1s")
.font_(Font("Helvetica", 12))
.align_(\left)
.background_(Color.gray(0.6))
.front;

gui.creature_1B5F1sParam1 = NumberBox(
	gui.w,
	Rect(100, gui.spacingCoeff + 90, 70, 15))
//.value_(440.0)
.value_(Creature_1B5F1_sequential.get.synthParams.centerFreq)
.action_({ |obj|
	Creature_1B5F1_sequential.get.synthParams.centerFreq_(obj.value);
})
.front;

gui.creature_1B5F1sParam1Label = StaticText(
	gui.w,
	Rect(100, gui.spacingCoeff + 90 + 15, 90, 15))
.string_("Center Freq")
.font_(Font("Helvetica", 10))
.front;

gui.creature_1B5F1sParam2 = NumberBox(
	gui.w,
	Rect(100, gui.spacingCoeff + 90 + 35, 70, 15))
//.value_(112)
.value_(Creature_1B5F1_sequential.get.synthParams.delayOffsetScalar)
.action_({ |obj|
	Creature_1B5F1_sequential.get.synthParams.delayOffsetScalar_(obj.value);
})
.front;

gui.creature_1B5F1sParam2Label = StaticText(
	gui.w,
	Rect(100, gui.spacingCoeff + 90 + 50, 90, 15))
.string_("Delay Offset Scalar")
.font_(Font("Helvetica", 10))
.front;

gui.creature_1B5F1sParam3 = NumberBox(
	gui.w,
	Rect(190, gui.spacingCoeff + 90, 70, 15))
//.value_(56)
.value_(Creature_1B5F1_sequential.get.synthParams.freqScalar)
.action_({ |obj|
	Creature_1B5F1_sequential.get.synthParams.freqScalar_(obj.value);
})
.front;

gui.creature_1B5F1sParam3Label = StaticText(
	gui.w,
	Rect(190, gui.spacingCoeff + 90 + 15, 90, 15))
.string_("Freq Scalar")
.font_(Font("Helvetica", 10))
.front;

gui.creature_1B5F1sParam4 = NumberBox(
	gui.w,
	Rect(190, gui.spacingCoeff + 90 + 35, 70, 15))
//.value_(1000.0)
.value_(Creature_1B5F1_sequential.get.synthParams.sustainScalar)
.action_({ |obj|
	Creature_1B5F1_sequential.get.synthParams.sustainScalar_(obj.value);
})
.front;

gui.creature_1B5F1sParam4Label = StaticText(
	gui.w,
	Rect(190, gui.spacingCoeff + 90 + 50, 90, 15))
.string_("Sustain Scalar")
.font_(Font("Helvetica", 10))
.front;

gui.creature_1B5F1sParam5 = NumberBox(
	gui.w,
	Rect(280, gui.spacingCoeff + 90, 70, 15))
//.value_(56)
.value_(Creature_1B5F1_sequential.get.synthParams.ampScalar)
.action_({ |obj|
	Creature_1B5F1_sequential.get.synthParams.ampScalar_(obj.value);
})
.front;

gui.creature_1B5F1sParam5Label = StaticText(
	gui.w,
	Rect(280, gui.spacingCoeff + 90 + 15, 90, 15))
.string_("Amplitude Scalar")
.font_(Font("Helvetica", 10))
.front;

//
// Creature CBF5 (7)
//
//

gui.creature_CBF5Label = StaticText(
	gui.w,
	Rect(20, gui.spacingCoeff * 3 + 20, gui.labelWidth, gui.labelHeight))
.string_("   CBF5")
.font_(Font("Helvetica", 12))
.align_(\left)
.background_(Color.gray(0.6))
.front;

gui.creature_CBF5LabelParam1 = NumberBox(
	gui.w,
	Rect(100 + (0 * 90), gui.spacingCoeff + 20 + (70 * 2), 70, 15))
//.value_(440.0)
.value_(Creature_CBF5.get.synthParams.centerFreqStart)
.action_({ |obj|
	Creature_CBF5.get.synthParams.centerFreqStart_(obj.value);
})
.front;

gui.creature_CBF5Param1Label = StaticText(
	gui.w,
	Rect(100 + (0 * 90), gui.spacingCoeff + 20 + (70 * 2) + 15, 90, 15))
.string_("Center Freq Start")
.font_(Font("Helvetica", 10))
.front;

gui.creature_CBF5Param2 = NumberBox(
	gui.w,
	Rect(100 + (0 * 90), gui.spacingCoeff + 20 + (70 * 2) + 35, 70, 15))
//.value_(112)
.value_(Creature_CBF5.get.synthParams.freqStartScalar)
.action_({ |obj|
	Creature_CBF5.get.synthParams.freqStartScalar_(obj.value);
})
.front;

gui.creature_CBF5Param2Label = StaticText(
	gui.w,
	Rect(100 + (0 * 90), gui.spacingCoeff + 20 + (70 * 2) + 50, 90, 15))
.string_("Freq Start Scalar")
.font_(Font("Helvetica", 10))
.front;

gui.creature_CBF5Param3 = NumberBox(
	gui.w,
	Rect(100 + (1 * 90), gui.spacingCoeff + 20 + (70 * 2), 70, 15))
//.value_(56)
.value_(Creature_CBF5.get.synthParams.centerFreqEnd)
.action_({ |obj|
	Creature_CBF5.get.synthParams.centerFreqEnd_(obj.value);
})
.front;

gui.creature_CBF5Param3Label = StaticText(
	gui.w,
	Rect(100 + (1 * 90), gui.spacingCoeff + 20 + (70 * 2) + 15, 90, 15))
.string_("Center Freq End")
.font_(Font("Helvetica", 10))
.front;

gui.creature_CBF5Param4 = NumberBox(
	gui.w,
	Rect(100 + (1 * 90), gui.spacingCoeff + 20 + (70 * 2) + 35, 70, 15))
//.value_(1000.0)
.value_(Creature_CBF5.get.synthParams.freqEndScalar)
.action_({ |obj|
	Creature_CBF5.get.synthParams.freqEndScalar_(obj.value);
})
.front;

gui.creature_CBF5Param4Label = StaticText(
	gui.w,
	Rect(100 + (1 * 90), gui.spacingCoeff + 20 + (70 * 2) + 50, 90, 15))
.string_("Freq End Scalar")
.font_(Font("Helvetica", 10))
.front;

gui.creature_CBF5Param5 = NumberBox(
	gui.w,
	Rect(100 + (2 * 90), gui.spacingCoeff + 20 + (70 * 2), 70, 15))
//.value_(56)
.value_(Creature_CBF5.get.synthParams.sustainScalar)
.action_({ |obj|
	Creature_CBF5.get.synthParams.sustainScalar_(obj.value);
})
.front;

gui.creature_CBF5Param5Label = StaticText(
	gui.w,
	Rect(100 + (2 * 90), gui.spacingCoeff + 20 + (70 * 2) + 15, 90, 15))
.string_("Sustain Scalar")
.font_(Font("Helvetica", 10))
.front;

gui.creature_CBF5Param6 = NumberBox(
	gui.w,
	Rect(100 + (2 * 90), gui.spacingCoeff + 20 + (70 * 2) + 35, 70, 15))
//.value_(1000.0)
.value_(Creature_CBF5.get.synthParams.ampScalar)
.action_({ |obj|
	Creature_CBF5.get.synthParams.ampScalar_(obj.value);
})
.front;

gui.creature_CBF5Param6Label = StaticText(
	gui.w,
	Rect(100 + (2 * 90), gui.spacingCoeff + 20 + (70 * 2) + 50, 90, 15))
.string_("Amplitude Scalar")
.font_(Font("Helvetica", 10))
.front;

gui.creature_CBF5Param7 = NumberBox(
	gui.w,
	Rect(100 + (3 * 90), gui.spacingCoeff + 20 + (70 * 2), 70, 15))
//.value_(1000.0)
.value_(Creature_CBF5.get.synthParams.delayOffsetScalar)
.action_({ |obj|
	Creature_CBF5.get.synthParams.delayOffsetScalar_(obj.value);
})
.front;

gui.creature_CBF5Param7Label = StaticText(
	gui.w,
	Rect(100 + (3 * 90), gui.spacingCoeff + 20 + (70 * 2) + 15, 90, 15))
.string_("Delay Offset Scalar")
.font_(Font("Helvetica", 10))
.front;

//
// Creature C99D (9)
//
//

gui.creature_C99DLabel = StaticText(
	gui.w,
	Rect(20, gui.spacingCoeff * 4 + 20, gui.labelWidth, gui.labelHeight))
.string_("   C99D")
.font_(Font("Helvetica", 12))
.align_(\left)
.background_(Color.gray(0.6))
.front;

gui.creature_C99DLabelParam1 = NumberBox(
	gui.w,
	Rect(100 + (0 * 90), gui.spacingCoeff + 20 + (70 * 3), 70, 15))
//.value_(440.0)
.value_(Creature_C99D.get.synthParams.centerFreqStart)
.action_({ |obj|
	Creature_C99D.get.synthParams.centerFreqStart_(obj.value);
})
.front;

gui.creature_C99DParam1Label = StaticText(
	gui.w,
	Rect(100 + (0 * 90), gui.spacingCoeff + 20 + (70 * 3) + 15, 90, 15))
.string_("Center Freq Start")
.font_(Font("Helvetica", 10))
.front;

gui.creature_C99DParam2 = NumberBox(
	gui.w,
	Rect(100 + (0 * 90), gui.spacingCoeff + 20 + (70 * 3) + 35, 70, 15))
//.value_(112)
.value_(Creature_C99D.get.synthParams.freqStartScalar)
.action_({ |obj|
	Creature_C99D.get.synthParams.freqStartScalar_(obj.value);
})
.front;

gui.creature_C99DParam2Label = StaticText(
	gui.w,
	Rect(100 + (0 * 90), gui.spacingCoeff + 20 + (70 * 3) + 50, 90, 15))
.string_("Freq Start Scalar")
.font_(Font("Helvetica", 10))
.front;

gui.creature_C99DParam3 = NumberBox(
	gui.w,
	Rect(100 + (1 * 90), gui.spacingCoeff + 20 + (70 * 3), 70, 15))
//.value_(56)
.value_(Creature_C99D.get.synthParams.freqStartOffset)
.action_({ |obj|
	Creature_C99D.get.synthParams.freqStartOffset_(obj.value);
})
.front;

gui.creature_C99DParam3Label = StaticText(
	gui.w,
	Rect(100 + (1 * 90), gui.spacingCoeff + 20 + (70 * 3) + 15, 90, 15))
.string_("Freq Start Offset")
.font_(Font("Helvetica", 10))
.front;

gui.creature_C99DParam4 = NumberBox(
	gui.w,
	Rect(100 + (1 * 90), gui.spacingCoeff + 20 + (70 * 3) + 35, 70, 15))
//.value_(1000.0)
.value_(Creature_C99D.get.synthParams.centerFreqEnd)
.action_({ |obj|
	Creature_C99D.get.synthParams.centerFreqEnd_(obj.value);
})
.front;

gui.creature_C99DParam4Label = StaticText(
	gui.w,
	Rect(100 + (1 * 90), gui.spacingCoeff + 20 + (70 * 3) + 50, 90, 15))
.string_("Center Freq End")
.font_(Font("Helvetica", 10))
.front;

gui.creature_C99DParam5 = NumberBox(
	gui.w,
	Rect(100 + (2 * 90), gui.spacingCoeff + 20 + (70 * 3), 70, 15))
//.value_(56)
.value_(Creature_C99D.get.synthParams.freqEndScalar)
.action_({ |obj|
	Creature_C99D.get.synthParams.freqEndScalar_(obj.value);
})
.front;

gui.creature_C99DParam5Label = StaticText(
	gui.w,
	Rect(100 + (2 * 90), gui.spacingCoeff + 20 + (70 * 3) + 15, 90, 15))
.string_("Freq End Scalar")
.font_(Font("Helvetica", 10))
.front;

gui.creature_C99DParam6 = NumberBox(
	gui.w,
	Rect(100 + (2 * 90), gui.spacingCoeff + 20 + (70 * 3) + 35, 70, 15))
//.value_(1000.0)
.value_(Creature_C99D.get.synthParams.freqEndOffset)
.action_({ |obj|
	Creature_C99D.get.synthParams.freqEndOffset_(obj.value);
})
.front;

gui.creature_C99DParam6Label = StaticText(
	gui.w,
	Rect(100 + (2 * 90), gui.spacingCoeff + 20 + (70 * 3) + 50, 90, 15))
.string_("Freq End Offset")
.font_(Font("Helvetica", 10))
.front;

gui.creature_C99DParam7 = NumberBox(
	gui.w,
	Rect(100 + (3 * 90), gui.spacingCoeff + 20 + (70 * 3), 70, 15))
//.value_(1000.0)
.value_(Creature_C99D.get.synthParams.sustainScalar)
.action_({ |obj|
	Creature_C99D.get.synthParams.sustainScalar_(obj.value);
})
.front;

gui.creature_C99DParam7Label = StaticText(
	gui.w,
	Rect(100 + (3 * 90), gui.spacingCoeff + 20 + (70 * 3) + 15, 90, 15))
.string_("Sustain Scalar")
.font_(Font("Helvetica", 10))
.front;

gui.creature_C99DParam8 = NumberBox(
	gui.w,
	Rect(100 + (3 * 90), gui.spacingCoeff + 20 + (70 * 3) + 35, 70, 15))
//.value_(56)
.value_(Creature_C99D.get.synthParams.ampScalar)
.action_({ |obj|
	Creature_C99D.get.synthParams.ampScalar_(obj.value);
})
.front;

gui.creature_C99DParam8Label = StaticText(
	gui.w,
	Rect(100 + (3 * 90), gui.spacingCoeff + 20 + (70 * 3) + 50, 90, 15))
.string_("Amplitude Scalar")
.font_(Font("Helvetica", 10))
.front;

gui.creature_C99DParam9 = NumberBox(
	gui.w,
	Rect(100 + (4 * 90), gui.spacingCoeff + 20 + (70 * 3), 70, 15))
//.value_(1000.0)
.value_(Creature_C99D.get.synthParams.delayOffsetScalar)
.action_({ |obj|
	Creature_C99D.get.synthParams.delayOffsetScalar_(obj.value);
})
.front;

gui.creature_C99DParam9Label = StaticText(
	gui.w,
	Rect(100 + (4 * 90), gui.spacingCoeff + 20 + (70 * 3) + 15, 90, 15))
.string_("Delay Offset Scalar")
.font_(Font("Helvetica", 10))
.front;

//
// Creature EDF0
//
//

gui.creature_EDF0Label = StaticText(
	gui.w,
	Rect(20, gui.spacingCoeff * 5 + 20, gui.labelWidth, gui.labelHeight))
.string_("   EDF0")
.font_(Font("Helvetica", 12))
.align_(\left)
.background_(Color.gray(0.6))
.front;

gui.creature_EDF0LabelParam1 = NumberBox(
	gui.w,
	Rect(100, gui.spacingCoeff + 20 + (70 * 4), 70, 15))
//.value_(440.0)
.value_(Creature_EDF0.get.synthParams.centerFreq)
.action_({ |obj|
	Creature_EDF0.get.synthParams.centerFreq_(obj.value);
})
.front;

gui.creature_EDF0Param1Label = StaticText(
	gui.w,
	Rect(100, gui.spacingCoeff + 20 + (70 * 4) + 15, 90, 15))
.string_("Center Freq")
.font_(Font("Helvetica", 10))
.front;

gui.creature_EDF0Param2 = NumberBox(
	gui.w,
	Rect(100, gui.spacingCoeff + 20 + (70 * 4) + 35, 70, 15))
//.value_(112)
.value_(Creature_EDF0.get.synthParams.freqScalar)
.action_({ |obj|
	Creature_EDF0.get.synthParams.freqScalar_(obj.value);
})
.front;

gui.creature_EDF0Param2Label = StaticText(
	gui.w,
	Rect(100, gui.spacingCoeff + 20 + (70 * 4) + 50, 90, 15))
.string_("Freq Scalar")
.font_(Font("Helvetica", 10))
.front;

gui.creature_EDF0Param3 = NumberBox(
	gui.w,
	Rect(190, gui.spacingCoeff + 20 + (70 * 4), 70, 15))
//.value_(56)
.value_(Creature_EDF0.get.synthParams.freqOffset)
.action_({ |obj|
	Creature_EDF0.get.synthParams.freqOffset_(obj.value);
})
.front;

gui.creature_EDF0Param3Label = StaticText(
	gui.w,
	Rect(190, gui.spacingCoeff + 20 + (70 * 4) + 15, 90, 15))
.string_("Freq Offset")
.font_(Font("Helvetica", 10))
.front;

gui.creature_EDF0Param4 = NumberBox(
	gui.w,
	Rect(190, gui.spacingCoeff + 20 + (70 * 4) + 35, 70, 15))
//.value_(1000.0)
.value_(Creature_EDF0.get.synthParams.sustainScalar)
.action_({ |obj|
	Creature_EDF0.get.synthParams.sustainScalar_(obj.value);
})
.front;

gui.creature_EDF0Param4Label = StaticText(
	gui.w,
	Rect(190, gui.spacingCoeff + 20 + (70 * 4) + 50, 90, 15))
.string_("Sustain Scalar")
.font_(Font("Helvetica", 10))
.front;

gui.creature_EDF0Param5 = NumberBox(
	gui.w,
	Rect(280, gui.spacingCoeff + 20 + (70 * 4), 70, 15))
//.value_(56)
.value_(Creature_EDF0.get.synthParams.ampScalar)
.action_({ |obj|
	Creature_EDF0.get.synthParams.ampScalar_(obj.value);
})
.front;

gui.creature_EDF0Param5Label = StaticText(
	gui.w,
	Rect(280, gui.spacingCoeff + 20 + (70 * 4) + 15, 90, 15))
.string_("Amplitude Scalar")
.font_(Font("Helvetica", 10))
.front;

gui.creature_EDF0Param6 = NumberBox(
	gui.w,
	Rect(280, gui.spacingCoeff + 20 + (70 * 4) + 35, 70, 15))
//.value_(1000.0)
.value_(Creature_EDF0.get.synthParams.delayOffsetScalar)
.action_({ |obj|
	Creature_EDF0.get.synthParams.delayOffsetScalar_(obj.value);
})
.front;

gui.creature_EDF0Param6Label = StaticText(
	gui.w,
	Rect(280, gui.spacingCoeff + 20 + (70 * 4) + 50, 90, 15))
.string_("Delay Offset Scalar")
.font_(Font("Helvetica", 10))
.front;

//
// Creature CB91 (6)
//
//

gui.creature_CB91Label = StaticText(
	gui.w,
	Rect(20, gui.spacingCoeff * 6 + 20, gui.labelWidth, gui.labelHeight))
.string_("   CB91")
.font_(Font("Helvetica", 12))
.align_(\left)
.background_(Color.gray(0.6))
.front;

gui.creature_CB91LabelParam1 = NumberBox(
	gui.w,
	Rect(100 + (0 * 90), gui.spacingCoeff + 20 + (70 * 5), 70, 15))
//.value_(440.0)
.value_(Creature_CB91.get.synthParams.centerFreq)
.action_({ |obj|
	Creature_CB91.get.synthParams.centerFreq_(obj.value);
})
.front;

gui.creature_CB91Param1Label = StaticText(
	gui.w,
	Rect(100 + (0 * 90), gui.spacingCoeff + 20 + (70 * 5) + 15, 90, 15))
.string_("Center Freq")
.font_(Font("Helvetica", 10))
.front;

gui.creature_CB91Param2 = NumberBox(
	gui.w,
	Rect(100 + (0 * 90), gui.spacingCoeff + 20 + (70 * 5) + 35, 70, 15))
//.value_(112)
.value_(Creature_CB91.get.synthParams.freqScalar)
.action_({ |obj|
	Creature_CB91.get.synthParams.freqScalar_(obj.value);
})
.front;

gui.creature_CB91Param2Label = StaticText(
	gui.w,
	Rect(100 + (0 * 90), gui.spacingCoeff + 20 + (70 * 5) + 50, 90, 15))
.string_("Freq Scalar")
.font_(Font("Helvetica", 10))
.front;

gui.creature_CB91Param3 = NumberBox(
	gui.w,
	Rect(100 + (1 * 90), gui.spacingCoeff + 20 + (70 * 5), 70, 15))
//.value_(56)
.value_(Creature_CB91.get.synthParams.freqOffset)
.action_({ |obj|
	Creature_CB91.get.synthParams.freqOffset_(obj.value);
})
.front;

gui.creature_CB91Param3Label = StaticText(
	gui.w,
	Rect(100 + (1 * 90), gui.spacingCoeff + 20 + (70 * 5) + 15, 90, 15))
.string_("Freq Offset")
.font_(Font("Helvetica", 10))
.front;

gui.creature_CB91Param4 = NumberBox(
	gui.w,
	Rect(100 + (1 * 90), gui.spacingCoeff + 20 + (70 * 5) + 35, 70, 15))
//.value_(1000.0)
.value_(Creature_CB91.get.synthParams.sustainScalar)
.action_({ |obj|
	Creature_CB91.get.synthParams.sustainScalar_(obj.value);
})
.front;

gui.creature_CB91Param4Label = StaticText(
	gui.w,
	Rect(100 + (1 * 90), gui.spacingCoeff + 20 + (70 * 5) + 50, 90, 15))
.string_("Sustain Scalar")
.font_(Font("Helvetica", 10))
.front;

gui.creature_CB91Param5 = NumberBox(
	gui.w,
	Rect(100 + (2 * 90), gui.spacingCoeff + 20 + (70 * 5), 70, 15))
//.value_(56)
.value_(Creature_CB91.get.synthParams.ampScalar)
.action_({ |obj|
	Creature_CB91.get.synthParams.ampScalar_(obj.value);
})
.front;

gui.creature_CB91Param5Label = StaticText(
	gui.w,
	Rect(100 + (2 * 90), gui.spacingCoeff + 20 + (70 * 5) + 15, 90, 15))
.string_("Amplitude Scalar")
.font_(Font("Helvetica", 10))
.front;

gui.creature_CB91Param6 = NumberBox(
	gui.w,
	Rect(100 + (2 * 90), gui.spacingCoeff + 20 + (70 * 5) + 35, 70, 15))
//.value_(1000.0)
.value_(Creature_CB91.get.synthParams.delayOffsetScalar)
.action_({ |obj|
	Creature_CB91.get.synthParams.delayOffsetScalar_(obj.value);
})
.front;

gui.creature_CB91Param6Label = StaticText(
	gui.w,
	Rect(100 + (2 * 90), gui.spacingCoeff + 20 + (70 * 5) + 50, 90, 15))
.string_("Delay Offset Scalar")
.font_(Font("Helvetica", 10))
.front;

//
// Creature CB2D (6)
//
//

StaticText(
	gui.w,
	Rect(20, gui.spacingCoeff * 7 + 20, gui.labelWidth, gui.labelHeight))
.string_("   CB2D")
.font_(Font("Helvetica", 12))
.align_(\left)
.background_(Color.gray(0.6))
.front;

gui.creature_CB2DLabelParam1 = NumberBox(
	gui.w,
	Rect(100 + (0 * 90), gui.spacingCoeff + 20 + (70 * 6), 70, 15))
//.value_(440.0)
.value_(Creature_CB2D.get.synthParams.centerFreq)
.action_({ |obj|
	Creature_CB2D.get.synthParams.centerFreq_(obj.value);
})
.front;

StaticText(
	gui.w,
	Rect(100 + (0 * 90), gui.spacingCoeff + 20 + (70 * 6) + 15, 90, 15))
.string_("Center Freq")
.font_(Font("Helvetica", 10))
.front;

gui.creature_CB2DParam2 = NumberBox(
	gui.w,
	Rect(100 + (0 * 90), gui.spacingCoeff + 20 + (70 * 6) + 35, 70, 15))
//.value_(112)
.value_(Creature_CB2D.get.synthParams.freqScalar)
.action_({ |obj|
	Creature_CB2D.get.synthParams.freqScalar_(obj.value);
})
.front;

StaticText(
	gui.w,
	Rect(100 + (0 * 90), gui.spacingCoeff + 20 + (70 * 6) + 50, 90, 15))
.string_("Freq Scalar")
.font_(Font("Helvetica", 10))
.front;

gui.creature_CB2DParam3 = NumberBox(
	gui.w,
	Rect(100 + (1 * 90), gui.spacingCoeff + 20 + (70 * 6), 70, 15))
//.value_(56)
.value_(Creature_CB2D.get.synthParams.freqOffset)
.action_({ |obj|
	Creature_CB2D.get.synthParams.freqOffset_(obj.value);
})
.front;

StaticText(
	gui.w,
	Rect(100 + (1 * 90), gui.spacingCoeff + 20 + (70 * 6) + 15, 90, 15))
.string_("Freq Offset")
.font_(Font("Helvetica", 10))
.front;

gui.creature_CB2DParam4 = NumberBox(
	gui.w,
	Rect(100 + (1 * 90), gui.spacingCoeff + 20 + (70 * 6) + 35, 70, 15))
//.value_(1000.0)
.value_(Creature_CB2D.get.synthParams.sustainScalar)
.action_({ |obj|
	Creature_CB2D.get.synthParams.sustainScalar_(obj.value);
})
.front;

StaticText(
	gui.w,
	Rect(100 + (1 * 90), gui.spacingCoeff + 20 + (70 * 6) + 50, 90, 15))
.string_("Sustain Scalar")
.font_(Font("Helvetica", 10))
.front;

gui.creature_CB2DParam5 = NumberBox(
	gui.w,
	Rect(100 + (2 * 90), gui.spacingCoeff + 20 + (70 * 6), 70, 15))
//.value_(56)
.value_(Creature_CB2D.get.synthParams.ampScalar)
.action_({ |obj|
	Creature_CB2D.get.synthParams.ampScalar_(obj.value);
})
.front;

StaticText(
	gui.w,
	Rect(100 + (2 * 90), gui.spacingCoeff + 20 + (70 * 6) + 15, 90, 15))
.string_("Amplitude Scalar")
.font_(Font("Helvetica", 10))
.front;

gui.creature_CB2DParam6 = NumberBox(
	gui.w,
	Rect(100 + (2 * 90), gui.spacingCoeff + 20 + (70 * 6) + 35, 70, 15))
//.value_(1000.0)
.value_(Creature_CB2D.get.synthParams.delayOffsetScalar)
.action_({ |obj|
	Creature_CB2D.get.synthParams.delayOffsetScalar_(obj.value);
})
.front;

StaticText(
	gui.w,
	Rect(100 + (2 * 90), gui.spacingCoeff + 20 + (70 * 6) + 50, 90, 15))
.string_("Delay Offset Scalar")
.font_(Font("Helvetica", 10))
.front;

//
// Creature 1D789 (5)
//
//

StaticText(
	gui.w,
	Rect(20, gui.spacingCoeff * 8 + 20, gui.labelWidth, gui.labelHeight))
.string_("   1D789")
.font_(Font("Helvetica", 12))
.align_(\left)
.background_(Color.gray(0.6))
.front;

gui.creature_1D789Param1 = NumberBox(
	gui.w,
	Rect(100, gui.spacingCoeff + 20 + (70 * 7), 70, 15))
//.value_(440.0)
.value_(Creature_1D789.get.synthParams.centerFreq)
.action_({ |obj|
	Creature_1D789.get.synthParams.centerFreq_(obj.value);
})
.front;

StaticText(
	gui.w,
	Rect(100, gui.spacingCoeff + 20 + (70 * 7) + 15, 90, 15))
.string_("Center Freq")
.font_(Font("Helvetica", 10))
.front;

gui.creature_1D789Param2 = NumberBox(
	gui.w,
	Rect(100, gui.spacingCoeff + 20 + (70 * 7) + 35, 70, 15))
//.value_(112)
.value_(Creature_1D789.get.synthParams.delayOffsetScalar)
.action_({ |obj|
	Creature_1D789.get.synthParams.delayOffsetScalar_(obj.value);
})
.front;

StaticText(
	gui.w,
	Rect(100, gui.spacingCoeff + 20 + (70 * 7) + 50, 90, 15))
.string_("Delay Offset Scalar")
.font_(Font("Helvetica", 10))
.front;

gui.creature_1D789Param3 = NumberBox(
	gui.w,
	Rect(190, gui.spacingCoeff + 20 + (70 * 7), 70, 15))
//.value_(56)
.value_(Creature_1D789.get.synthParams.freqScalar)
.action_({ |obj|
	Creature_1D789.get.synthParams.freqScalar_(obj.value);
})
.front;

StaticText(
	gui.w,
	Rect(190, gui.spacingCoeff + 20 + (70 * 7) + 15, 90, 15))
.string_("Freq Scalar")
.font_(Font("Helvetica", 10))
.front;

gui.creature_1D789Param4 = NumberBox(
	gui.w,
	Rect(190, gui.spacingCoeff + 20 + (70 * 7) + 35, 70, 15))
//.value_(1000.0)
.value_(Creature_1D789.get.synthParams.sustainScalar)
.action_({ |obj|
	Creature_1D789.get.synthParams.sustainScalar_(obj.value);
})
.front;

StaticText(
	gui.w,
	Rect(190, gui.spacingCoeff + 20 + (70 * 7) + 50, 90, 15))
.string_("Sustain Scalar")
.font_(Font("Helvetica", 10))
.front;

gui.creature_1D789Param5 = NumberBox(
	gui.w,
	Rect(280, gui.spacingCoeff + 20 + (70 * 7), 70, 15))
//.value_(56)
.value_(Creature_1D789.get.synthParams.ampScalar)
.action_({ |obj|
	Creature_1D789.get.synthParams.ampScalar_(obj.value);
})
.front;

StaticText(
	gui.w,
	Rect(280, gui.spacingCoeff + 20 + (70 * 7) + 15, 90, 15))
.string_("Amplitude Scalar")
.font_(Font("Helvetica", 10))
.front;

//
// Creature 1B5F1 (continuous)
//
//

StaticText(
	gui.w,
	Rect(20, gui.spacingCoeff * 9 + 20, gui.labelWidth, gui.labelHeight))
.string_("   1B5F1c")
.font_(Font("Helvetica", 12))
.align_(\left)
.background_(Color.gray(0.6))
.front;

gui.creature_1B5F1cParam1 = NumberBox(
	gui.w,
	Rect(100, gui.spacingCoeff + 20 + (70 * 8), 70, 15))
//.value_(440.0)
.value_(Creature_1B5F1_continuous.get.synthParams.centerFreq)
.action_({ |obj|
	Creature_1B5F1_continuous.get.synthParams.centerFreq_(obj.value);
})
.front;

StaticText(
	gui.w,
	Rect(100, gui.spacingCoeff + 20 + (70 * 8) + 15, 90, 15))
.string_("Center Freq")
.font_(Font("Helvetica", 10))
.front;

gui.creature_1B5F1cParam2 = NumberBox(
	gui.w,
	Rect(100, gui.spacingCoeff + 20 + (70 * 8) + 35, 70, 15))
//.value_(112)
.value_(Creature_1B5F1_continuous.get.synthParams.delayOffsetScalar)
.action_({ |obj|
	Creature_1B5F1_continuous.get.synthParams.delayOffsetScalar_(obj.value);
})
.front;

StaticText(
	gui.w,
	Rect(100, gui.spacingCoeff + 20 + (70 * 8) + 50, 90, 15))
.string_("Delay Offset Scalar")
.font_(Font("Helvetica", 10))
.front;

gui.creature_1B5F1cParam3 = NumberBox(
	gui.w,
	Rect(190, gui.spacingCoeff + 20 + (70 * 8), 70, 15))
//.value_(56)
.value_(Creature_1B5F1_continuous.get.synthParams.freqScalar)
.action_({ |obj|
	Creature_1B5F1_continuous.get.synthParams.freqScalar_(obj.value);
})
.front;

StaticText(
	gui.w,
	Rect(190, gui.spacingCoeff + 20 + (70 * 8) + 15, 90, 15))
.string_("Freq Scalar")
.font_(Font("Helvetica", 10))
.front;

gui.creature_1B5F1cParam4 = NumberBox(
	gui.w,
	Rect(190, gui.spacingCoeff + 20 + (70 * 8) + 35, 70, 15))
//.value_(1000.0)
.value_(Creature_1B5F1_continuous.get.synthParams.sustainScalar)
.action_({ |obj|
	Creature_1B5F1_continuous.get.synthParams.sustainScalar_(obj.value);
})
.front;

StaticText(
	gui.w,
	Rect(190, gui.spacingCoeff + 20 + (70 * 8) + 50, 90, 15))
.string_("Sustain Scalar")
.font_(Font("Helvetica", 10))
.front;

gui.creature_1B5F1cParam5 = NumberBox(
	gui.w,
	Rect(280, gui.spacingCoeff + 20 + (70 * 8), 70, 15))
//.value_(56)
.value_(Creature_1B5F1_continuous.get.synthParams.ampScalar)
.action_({ |obj|
	Creature_1B5F1_continuous.get.synthParams.ampScalar_(obj.value);
})
.front;

StaticText(
	gui.w,
	Rect(280, gui.spacingCoeff + 20 + (70 * 8) + 15, 90, 15))
.string_("Amplitude Scalar")
.font_(Font("Helvetica", 10))
.front;
)