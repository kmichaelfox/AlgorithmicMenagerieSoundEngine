Creature_1D789 {
	classvar instance;
	var <>id,
	<>synthID,
	<>routineList,
	<>sequenceList,
	<>grainList,
	<>synthParams;

	*new { | id, synthID |
		^super.new.init(id, synthID);
	}

	*get {
		^( instance ?? { instance = Creature_1D789.new(-1, -1)});
	}

	*initClass {
		StartUp.add {
			Creature_1D789.get();
		};
	}

	init {| id, synthID |
		this.id = id;
		this.synthID = synthID;

		this.grainList = List.new;
		this.routineList = List.new;

		this.synthParams = ();

		this.synthParams.centerFreq = 440;
		this.synthParams.freqScalar = 20;

		this.synthParams.sustainScalar = 100.0;

		this.synthParams.ampScalar = 1364/2;

		this.synthParams.delayOffsetScalar = 1000.0;
	}

	update { | input |
		for(0, (input.size/6)-1, { | i |
			if(i < grainList.size, {
				// alter existing grain parameters at grainList.at(i)
				var temp = List.new;
				for(0, 5, {| j |
					temp.add(input.at((i*6)+j));
				});
				grainList.at(i).add(temp.copy);
				if(grainList.at(i).size > 10, {
					grainList.at(i).removeAt(0);
				});

			}, {
				// create new grain and routine, add to grainList and routineList
					var temp = List.new;
					var temp2 = List.new;
					for(0, 5, {| j |
						temp.add(input.at((i*6)+j));
					});
					temp2.add(temp.copy.asArray);
					grainList.add(temp2.copy);
					routineList.add(
						Routine({
							var seq = Pseq(grainList.at(i), inf).asStream;

							/*
							loop({
								var currentNode = seq.next;
								Server.local.sendMsg("s_new",
									this.synthID, -1, 0, 0,
									\freq, (((112-currentNode.at(0))/56)*440),
									\sustain, (currentNode.at(1)/1000.0).clip(0.002, 0.1),
									\amp, ((currentNode.at(2)/56).sqrt.clip(0, 1) * 0.02 + 0.01).clip(0, 0.03),
									\x, currentNode.at(3),
									\y, currentNode.at(4),
									\z, currentNode.at(5)
								);
								((currentNode.at(1)/10.0).clip(0.01, 1)).wait;
							})
							*/

							loop({
								var currentNode = seq.next;
								Server.local.sendMsg("s_new",
									this.synthID, -1, 0, 0,
									\freq, (currentNode.at(0)/instance.synthParams.freqScalar*
										instance.synthParams.centerFreq),
									\sustain, (currentNode.at(1)/instance.synthParams.sustainScalar),
									\amp, ((currentNode.at(2)/instance.synthParams.ampScalar)
										.sqrt * 0.02 + 0.01).clip(0, 0.1),
									\x, currentNode.at(3),
									\y, currentNode.at(4),
									\z, currentNode.at(5)
								);
								((currentNode.at(0)/instance.synthParams.delayOffsetScalar).clip(0.01, 1)).wait;
							})
						}).play;
					);
			});
		});
	}

	die {
		for(0, routineList.size-1, { | i |
			routineList.at(i).stop;
			routineList.at(i).free;
		});
	}
}
