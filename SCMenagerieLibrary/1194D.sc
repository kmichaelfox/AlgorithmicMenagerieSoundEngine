Creature_1194D {
	classvar instance;
	var <>id,
	<>synthID,
	<>routineList,
	<>grainList,
	<>synthParams;

	*new { | id, synthID |
		^super.new.init(id, synthID);
	}

	*get {
		^( instance ?? { instance = Creature_1194D.new(-1, -1)});
	}

	init {| id, synthID |
		this.id = id;
		this.synthID = synthID;

		this.grainList = List.new;
		this.routineList = List.new;

		this.synthParams = ();

		this.synthParams.centerFreq = 440;
		this.synthParams.freqOffset = 112;
		this.synthParams.freqScalar = 56;

		this.synthParams.sustainScalar = 1000.0;

		this.synthParams.ampScalar = 56;

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
									\freq, (((instance.synthParams.freqOffset-currentNode.at(0))/
										instance.synthParams.freqScalar)*instance.synthParams.centerFreq),
									\sustain, (currentNode.at(1)/instance.synthParams.sustainScalar).clip(0.002, 0.1),
									\amp, ((currentNode.at(2)/instance.synthParams.ampScalar).sqrt
										.clip(0, 1) * 0.02 + 0.01).clip(0, 0.03),
									\x, currentNode.at(3),
									\y, currentNode.at(4),
									\z, currentNode.at(5)
								);
								((currentNode.at(1)/instance.synthParams.delayOffsetScalar).clip(0.01, 1)).wait;
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