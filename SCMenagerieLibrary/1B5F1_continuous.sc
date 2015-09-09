Creature_1B5F1_continuous {
	classvar instance;
	var <>id,
	<>synthID,
	<>routineList,
	<>grainList,
	<>synthParams;

	*new { | id, synthID |
		^super.new.init(id);
	}

	*get {
		^( instance ?? { instance = Creature_1B5F1_continuous.new(-1, -1)});
	}

	*initClass {
		StartUp.add {
			Creature_1B5F1_continuous.get();
		};
	}

	init {| id, synthID |
		this.id = id;
		this.synthID = synthID;

		this.grainList = List.new;
		this.routineList = List.new;

		this.synthParams = ();

		this.synthParams.centerFreq = 440.0;
		this.synthParams.freqScalar = 40.0;

		this.synthParams.sustainScalar = 1000.0;

		this.synthParams.ampScalar = 1364;

		this.synthParams.delayOffsetScalar = 10.0;
	}

	update { | input |
		for(0, (input.size/6)-1, { | i |
			if(i < grainList.size, {
				// alter existing grain parameters at grainList.at(i)
				for(0, 5, {| j |
					grainList.at(i).put(j, input.at((i*6)+j));
				});
			}, {
				// create new grain and routine, add to grainList and routineList
					var temp = List.new;
					for(0, 5, {| j |
						temp.add(input.at((i*6)+j));
					});
					grainList.add(temp.copy.asArray);
					routineList.add(
						Routine({
							var currentNode = grainList.at(i);

							loop({
								Server.local.sendMsg("s_new",
									this.synthID, -1, 0, 0,
									\freq, (currentNode.at(0)/instance.synthParams.freqScalar
										*instance.synthParams.centerFreq),
									\sustain, (currentNode.at(1)/instance.synthParams.sustainScalar).clip(0.002, 0.1),
									\amp, ((currentNode.at(2)/instance.synthParams.ampScalar)
										.sqrt.clip(0, 1) * 0.02 + 0.01).clip(0, 0.03),
									\x, currentNode.at(3),
									\y, currentNode.at(4),
									\z, currentNode.at(5)
								);
								((currentNode.at(1)/instance.synthParams.delayOffsetScalar).clip(0.01, 1)).wait;
							})

							//loop({
							//	Server.local.sendMsg("s_new",
							//		\gabor0, -1, 0, 0,
							//		\freq, (((112-currentNode.at(0))/56)*440),
							//		\sustain, (currentNode.at(1)/100.0),
							//		\amp, ((currentNode.at(2)/1364).sqrt * 0.02 + 0.01),
							//		\x, currentNode.at(3),
							//		\y, currentNode.at(4)
							//	);
							//	((currentNode.at(1)/10.0)+0.001).wait;
							//})

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
