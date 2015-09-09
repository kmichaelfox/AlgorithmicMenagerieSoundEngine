Creature_1B5F1_sequential {
	classvar instance;
	var <>id,
	<>rout,
	<>seq,
	<>synthID,
	<>grainList,
	<>synthParams;

	*new { | id, synthID |
		^super.new.init(id, synthID);
	}

	*get {
		^( instance ?? { instance = Creature_1B5F1_sequential.new(-1, -1) });
	}

	*initClass {
		StartUp.add {
			Creature_1B5F1_sequential.get();
		};
	}

	init {| id, synthID |
		//if(instance.isNil, { instance = Creature_1B5F1_sequential.new(-1, -1) });
		this.id = id;
		this.synthID = synthID;

		this.grainList = List.new;
		this.rout = nil;
		this.seq = nil;

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
			});
		});
		if(rout == nil, {
			this.seq = Pseq(grainList, inf).asStream;
			this.rout = Routine({
				var currentNode = this.seq.next;

				loop({
					Server.local.sendMsg("s_new",
						this.synthID, -1, 0, 0,
						\freq, (currentNode.at(0)/instance.synthParams.freqScalar*
							instance.synthParams.centerFreq),
						\sustain, (currentNode.at(1)/instance.synthParams.sustainScalar).clip(0.002,0.1),
						\amp, ((currentNode.at(2)/instance.synthParams.ampScalar)
							.sqrt.clip(0, 1) * 0.02 + 0.01).clip(0, 0.1),
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

		});
	}

	die {
		this.rout.stop;
		this.rout.clear.free;
	}
}