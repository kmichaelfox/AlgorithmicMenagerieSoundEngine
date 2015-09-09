MenagerieEngine {
	var <>addr,
	//<>addrWall,
	<>state,
	<>create,
	<>destroy,
	<>update,
	<>stageWipe,
	<>restart,
	<>creatureListFloor,
	<>creatureListWall;

	*new { | addr = nil, port |
		^super.new.init(addr, port);
	}

	init { | addr, port |
		this.creatureListFloor = List.new;
		this.creatureListWall = List.new;

		this.state = true;

		/*if(addrFloor.isNil.not, {
			this.addrFloor = NetAddr(addrFloor.asString, nil);
		});
		if(addrWall.isNil.not, {
			this.addrWall = NetAddr(addrWall.asString, nil);
		});*/
		thisProcess.openUDPPort(port);

		this.stageWipe = OSCFunc({| msg |

			this.state = false;

			if(creatureListFloor.isEmpty.not, {
				for(0, creatureListFloor.size-1, {
					creatureListFloor.last.die;
					creatureListFloor.pop;
				});
			});

			if(creatureListWall.isEmpty.not, {
				for(0, creatureListWall.size-1, {
					creatureListWall.last.die;
					creatureListWall.pop;
				});
			});

			}
			,
			'/clear',
			this.addr
		);

		this.restart = OSCFunc({| msg |
			this.state = true;
			}
			,
			'/begin',
			this.addr
		);

		this.create = //[
			OSCFunc({| msg |
				var creatureType = msg[1].asString;
				var id = msg[2];
		    var projectionSpace = msg[3].asString;

				if(this.state,{
			    if(projectionSpace == "FLOOR", {
					  this.creator(creatureType, id);
				  }, {
					  this.creator2(creatureType, id);
			    });
				});

				},
				'/create',
				this.addr
			);/*,
			OSCFunc({| msg |
				var creatureType = msg[1].asString;
				var id = msg[2];

				if(this.state,{
					this.creator2(creatureType, id);
				});

				},
				'/create',
				this.addrWall
			)
		];*/

		this.destroy = //[
			OSCFunc({ | msg |
				var id = msg[1].asInteger;
				var removeIndex = -1;

				//creatureList.size.postln;
				//msg.postln;
				//id.post;
				//": destroy".postln;

				// search for creature with id in creatureList
				if(this.creatureListFloor.isEmpty.not, {
					for(0, (this.creatureListFloor.size-1), {| i |
						if(this.creatureListFloor.at(i).id == id, {
							this.creatureListFloor.at(i).die;
							removeIndex = i;
						});
					});

			    if((removeIndex == -1).not, {
					  this.creatureListFloor.removeAt(removeIndex);
				    removeIndex = -1;
			    });
				});
		    if(this.creatureListWall.isEmpty.not, {
					for(0, (this.creatureListWall.size-1), {| i |
						if(this.creatureListWall.at(i).id == id, {
							this.creatureListWall.at(i).die;
							removeIndex = i;
						});
					});

			    if((removeIndex == -1).not, {
					  this.creatureListWall.removeAt(removeIndex);
				    removeIndex = -1;
			    });
				});
				},
				'/destroy',
				this.addr
			);/*,
			OSCFunc({ | msg |
				var id = msg[1].asInteger;
				var removeIndex = 0;

				//creatureList.size.postln;
				//msg.postln;
				//id.post;
				//": destroy".postln;

				// search for creature with id in creatureList
				if(this.creatureListWall.isEmpty.not, {
					for(0, (this.creatureListWall.size-1), {| i |
						if(this.creatureListWall.at(i).id == id, {
							this.creatureListWall.at(i).die;
							removeIndex = i;
						});
					});
					this.creatureListWall.removeAt(removeIndex);
				});
				},
				'/destroy',
				this.addrWall
			)
		];*/

		this.update = //[
			OSCFunc({ | msg |
			var id = msg[1].asInteger;
			var creatureType = msg[2].asString;
		  var projectionSpace = msg[3].asString;
			var params = msg.copy;
			var index = nil;

			params.removeAt(0);
			params.removeAt(0);
			params.removeAt(0);
		  //params.removeAt(0);

			if(this.state, {
			  if(projectionSpace == "FLOOR", {
				  if(this.creatureListFloor.isEmpty.not, {
				  	for(0, (this.creatureListFloor.size-1), { | i |
				  		if(this.creatureListFloor.at(i).id == id, { index = i; });
				  	});
				  });
				  }, {
				  if(this.creatureListWall.isEmpty.not, {
				  	for(0, (this.creatureListWall.size-1), { | i |
				  		if(this.creatureListWall.at(i).id == id, { index = i; });
				  	});
				  });
			  });

				if(index == nil, {
				  if(projectionSpace == "FLOOR", {
					  this.creator(creatureType, id);
					  this.creatureListFloor.at(this.creatureListFloor.size-1).update(params);
					}, {
						this.creator2(creatureType, id);
						this.creatureListWall.at(this.creatureListWall.size-1).update(params);
				  });
					},{
					if(projectionSpace == "FLOOR", {
						this.creatureListFloor.at(index).update(params);
						}, {
						this.creatureListWall.at(index).update(params);
					});
				});
			});

			//id.post;
			//": update".postln;

			// search for creature with id in creatureList
			//for(0, creatureList.size-1, {| i |
			//	if(creatureList.at(i).id == id, {
			//		creatureList.at(i).update(params);
			//	});
			//});

			},
			'/update',
			this.addr
		);/*,
		OSCFunc({ | msg |
			var id = msg[1].asInteger;
			var creatureType = msg[2].asString;
			var params = msg.copy;
			var index = nil;

			params.removeAt(0);
			params.removeAt(0);
			params.removeAt(0);

			if(this.state, {
				if(this.creatureListWall.isEmpty.not, {
					for(0, (this.creatureListWall.size-1), { | i |
						if(this.creatureListWall.at(i).id == id, { index = i; });
					});
				});

				if(index == nil, {
					this.creator2(creatureType, id);
					this.creatureListWall.at(this.creatureListWall.size-1).update(params);
					},{
						this.creatureListWall.at(index).update(params);
				});
			});

			},
			'/update',
			this.addrWall
		)
		];*/
	}

	creator { | creatureType, id |
		case
		{creatureType == "1B5F1"}{
			this.creatureListFloor.add(Creature_1B5F1_sequential.new(id, \gabor0Wall));
		}
		{creatureType == "CBF5"}{
			this.creatureListFloor.add(Creature_CBF5.new(id, \gaborGlissWall));
		}
		{creatureType == "C99D"}{
			this.creatureListFloor.add(Creature_C99D.new(id, \gaborGlissWall));
		}
		{creatureType == "EDF0"}{
			this.creatureListFloor.add(Creature_EDF0.new(id, \gabor0Wall));
		}
		{creatureType == "1D789"}{
			this.creatureListFloor.add(Creature_1D789.new(id, \gabor0Wall));
		}
		{creatureType == "CB2D"}{
			this.creatureListFloor.add(Creature_CB2D.new(id, \gabor0Wall));
		}
		{creatureType == "CB91"}{
			this.creatureListFloor.add(Creature_CB91.new(id, \gabor0Wall));
		}
		{creatureType == "1194D"}{
			this.creatureListFloor.add(Creature_1194D.new(id, \gabor0Wall));
		}
		{creatureType == "1B5F1c"}{
			this.creatureListFloor.add(Creature_1B5F1_continuous.new(id, \gabor0Wall));
		}
	}

	creator2 { | creatureType, id |
		case
		{creatureType == "1B5F1"}{
			this.creatureListWall.add(Creature_1B5F1_sequential.new(id, \gabor0Wall));
		}
		{creatureType == "CBF5"}{
			this.creatureListWall.add(Creature_CBF5.new(id, \gaborGlissWall));
		}
		{creatureType == "C99D"}{
			this.creatureListWall.add(Creature_C99D.new(id, \gaborGlissWall));
		}
		{creatureType == "EDF0"}{
			this.creatureListWall.add(Creature_EDF0.new(id, \gabor0Wall));
		}
		{creatureType == "1D789"}{
			this.creatureListWall.add(Creature_1D789.new(id, \gabor0Wall));
		}
		{creatureType == "CB2D"}{
			this.creatureListWall.add(Creature_CB2D.new(id, \gabor0Wall));
		}
		{creatureType == "CB91"}{
			this.creatureListWall.add(Creature_CB91.new(id, \gabor0Wall));
		}
		{creatureType == "1194D"}{
			this.creatureListWall.add(Creature_1194D.new(id, \gabor0Wall));
		}
		{creatureType == "1B5F1c"}{
			this.creatureListFloor.add(Creature_1B5F1_continuous.new(id, \gabor0Wall));
		}
	}
}