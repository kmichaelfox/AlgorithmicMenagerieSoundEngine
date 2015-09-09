(
o = Server.local.options;
o.device="MOTU Traveler mk3";
o.device.postln;
)

s.boot;

x.state;
x.restart;

x = MenagerieEngine.new("192.168.1.3", "192.168.1.2", 12000);

x.addrFloor;
x.creatureListFloor.size();
x.creatureListFloor.postln;
x.creatureListFloor.at(0).synthID;
x.creatureListWall.size();
x.creatureListWall.postln;
x.creatureListWall.at(0).synthID;
x.creatureListWall.at(x.creatureListWall.size-2).grainList;

x = Creature_1B5F1_continuous.new(0);
y = Creature_1B5F1_sequential.new(0);
x = Creature_C99D.new(0);
x = Creature_CB2D.new(0);
x = Creature_CB91.new(0);
x = Creature_1194D.new(0);
x = Creature_CBF5.new(0);
x = Creature_EDF0.new(0);
x = Creature_1D789.new(0);

x.update([56.11878, 1.1231033, 0, -79.7205, -57.806286, 0]);
x.update([56.11878, 1.1231033, 0, -79.7205, -57.806286, 0, 2]);

n = NetAddr("192.168.1.1", 12000);
n.sendMsg("/update",
	2, "1B5F1",
	1.rrand(80)+1, 1.1231033, 0, -79.7205, -57.806286, 0,
	1.rrand(80)+1, 1.512105, 0, -72.76623, -2.1200335, 0,
	1.rrand(80)+1, 1.339225, 0, -23.678993, -18.487776, 0,
	1.rrand(80)+1, 1.339225, 0, -23.678993, -18.487776, 0
);

x.update(
	[
		2, "EDF0",
		1.rrand(80)+1, 1.1231033, 0, -79.7205, -57.806286, 0,
		1.rrand(80)+1, 1.512105, 0, -72.76623, -2.1200335, 0,
		1.rrand(80)+1, 1.339225, 0, -23.678993, -18.487776, 0,
		1.rrand(80)+1, 1.339225, 0, -23.678993, -18.487776, 0
	]
);
x.update(
	[
		1.rrand(80)+1, 1.1231033, 0, -79.7205, -57.806286, 0, 0.5,
		1.rrand(80)+1, 1.512105, 0, -72.76623, -2.1200335, 0, 0.2,
		1.rrand(80)+1, 1.339225, 0, -23.678993, -18.487776, 0, 0.05
	]
);

x.grainList.size;
x.grainList.at(0).size;
x.grainList.at(1).size;
x.grainList.at(2).size;
x.grainList.at(3).size;
x.routineList.size;
x.routineList.at(0).stop;
x.routineList.at(1).stop;
x.routineList.at(2).stop;

Creature_EDF0.new(0,
	[
		[56.11878, 1.1231033, 0, -79.7205, -57.806286],
		[34.22926, 1.512105, 0, -72.76623, -2.1200335],
		[51.744175, 1.339225, 0, -23.678993, -18.487776]
	]
);

y = Creature_1194D.new( 0,
	[
		[1.rrand(80)+1, 1.1231033, 0, -79.7205, -57.806286],
		[1.rrand(80)+1, 1.512105, 0, -72.76623, -2.1200335],
		[1.rrand(80)+1, 1.339225, 0, -23.678993, -18.487776]
	]
);

z = Creature_CBF5.new( 0,
	[
		[56.11878, 1.1231033, 0, -79.7205, -57.806286, 0,  0.5],
		[34.22926, 1.512105, 0, -72.76623, -2.1200335, 0, 0.07],
		[51.744175, 1.339225, 0, -23.678993, -18.487776, 0, 0.3]
	]
);

x.die;

x.routineList.postln;
x.grainList.postln;

(
o = Server.local.options;
o.device="MOTU Traveler mk3";
o.device.postln;
o.memSize;
)

s.boot;

ip: 128.113.243.56
port: 12000

n = NetAddr("192.168.1.2", 12000);
n = NetAddr("192.168.1.3", 12000);
n.sendMsg("\hello", "world");

thisProcess.openUDPPort(12000);
OSCFunc.trace(true);
thisProcess.openPorts.postln;

for(0, 4, { |i| i.postln; "printing".postln; });

a = nil;
a == 0;
a == nil;

n = NetAddr("192.168.1.2", nil);
x = OSCFunc({ | msg |
	msg[0].postln;
	},
	'/clear',
	n
);

~boolFlag.postln;
~loopEnd;
Routine.allEnabled;

x.stageWipe.permanent.postln;
x.restart.permanent.postln;

(-1).equals(2);

x = MenagerieEngine("127.0.0.1", 12345);