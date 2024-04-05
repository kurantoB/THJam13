extends NPCUnit

var Bullet = preload("res://Scenes/Bullet.tscn")

const TRIGGER_RADIUS = 5
const BULLET_SPEED = 7

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

func execute_actions(delta):
	.execute_actions(delta)
	for action_num in Constants.UNIT_TYPE_ACTIONS[unit_type]:
		if !actions[action_num]:
			continue
		match action_num:
			# handle custom actions
			Constants.ActionType.FIRE:
				var bullet = Bullet.instance()
				scene.get_node("Bullets").add_child(bullet)
				bullet.configure(position + Vector2(0, -0.5) * Constants.GRID_SIZE * Constants.SCALE_FACTOR)
				var map_x = position.x / Constants.GRID_SIZE / Constants.SCALE_FACTOR
				var map_y = -1 * position.y / Constants.GRID_SIZE / Constants.SCALE_FACTOR
				if facing == Constants.Direction.RIGHT:
					if scene.player.pos.y - map_y > abs(scene.player.pos.x - map_x) / 2:
						bullet.x_speed = BULLET_SPEED / sqrt(2)
						bullet.y_speed = BULLET_SPEED / sqrt(2)
					else:
						bullet.x_speed = BULLET_SPEED
						bullet.y_speed = 0
				else:
					if scene.player.pos.y - map_y > abs(scene.player.pos.x - map_x) / 2:
						bullet.x_speed = -1 * BULLET_SPEED / sqrt(2)
						bullet.y_speed = BULLET_SPEED / sqrt(2)
					else:
						bullet.x_speed = -1 * BULLET_SPEED
						bullet.y_speed = 0
				get_node("/root/Scene/SFX/Shoot").play()
			_:
				pass
