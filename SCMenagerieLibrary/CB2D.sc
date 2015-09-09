Creature_CB2D {
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
		^( instance ?? { instance = Creature_CB2D.new(-1, -1)});
	}

	init {| id, synthID |
		this.id = id;
		this.synthID = synthID;

		this.grainList = List.new;
		this.routineList = List.new;

		this.synthParams = ();
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
									\freq, (((112-currentNode.at(0))/56)*440),
									\sustain, (currentNode.at(1)/1000.0).clip(0.002, 0.1),
									\amp, ((currentNode.at(2)/56).sqrt.clip(0, 1) * 0.02 + 0.01).clip(0, 0.1),
									\x, currentNode.at(3),
									\y, currentNode.at(4),
									\z, currentNode.at(5)
								);
								((currentNode.at(1)/10.0).clip(0.01, 1)).wait;
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
