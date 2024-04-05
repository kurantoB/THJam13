extends NPCUnit

const TRIGGER_RADIUS = 5

func before_tick():
	var map_x = position.x / Constants.GRID_SIZE / Constants.SCALE_FACTOR
	if abs(scene.player.pos.x - map_x) < 5:
		if scene.player.pos.x < map_x:
			facing = Constants.Direction.LEFT
		else:
			facing = Constants.Direction.RIGHT
	else:
		if scene.rng.randf() < 0.5:
			facing = Constants.Direction.RIGHT
		else:
			facing = Constants.Direction.LEFT
