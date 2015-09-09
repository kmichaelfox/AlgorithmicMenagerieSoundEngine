Creature_CBF5 {
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
		^( instance ?? { instance = Creature_CBF5.new(-1, -1)});
	}

	*initClass {
		StartUp.add {
			Creature_CBF5.get();
		};
	}

	init {| id, synthID |
		this.id = id;
		this.synthID = synthID;

		this.grainList = List.new;
		this.routineList = List.new;

		this.synthParams = ();
	}

	update { | input |
		for(0, (input.size/7)-1, { | i |
			if(i < grainList.size, {
				// alter existing grain parameters at grainList.at(i)
				for(0, 6, {| j |
					grainList.at(i).put(j, input.at((i*7)+j));
				});
				}, {
					// create new grain and routine, add to grainList and routineList
					var temp = List.new;
					for(0, 6, {| j |
						temp.add(input.at((i*7)+j));
					});
					grainList.add(temp.copy.asArray);
					routineList.add(
						Routine({
							var currentNode = grainList.at(i);

							loop({
								Server.local.sendMsg("s_new",
									this.synthID, -1, 0, 0,
									\freq_start, (((currentNode.at(0))/80)*440),
									\freq_end, (((currentNode.at(0))/80)*440)*(currentNode.at(6)),
									\sustain, (currentNode.at(1)/1000.0).clip(0.002, 0.1),
									\amp, ((currentNode.at(2)/56).sqrt.clip(0, 1) * 0.02 + 0.01).clip(0, 0.01),
									\x, currentNode.at(3),
									\y, currentNode.at(4),
									\z, currentNode.at(5)
								);
								((currentNode.at(1)/100.0).clip(0.01,1)).wait;
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