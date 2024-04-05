extends Unit

# Player-specific code
class_name Player

const Bullet = preload("res://Scripts/Bullet.gd")

var lives : int = 2
var coins : int = 0

signal update_ui(lives, coins)

func _init():
	pos = Vector2(position.x / Constants.GRID_SIZE, -1 * position.y / Constants.GRID_SIZE)
	position.x = position.x * Constants.SCALE_FACTOR
	position.y = position.y * Constants.SCALE_FACTOR

func execute_actions(delta):
	.execute_actions(delta)
	for action_num in Constants.UNIT_TYPE_ACTIONS[Constants.UnitType.PLAYER]:
		if !actions[action_num]:
			continue
		match action_num:
			# handle custom actions
			Constants.ActionType.DASH:
				dash()
			_:
				pass

func handle_input(delta):
	scene.handle_player_input()

func _on_Player_area_entered(area: Area2D) -> void:
	if area is TriggerDialogue:
		area.trigger_dialogue()
	if get_condition(Constants.UnitCondition.IS_INVINCIBLE, false):
		return
	if area is Bullet:
		hit_from_area(area)
	if area is NPCUnit:
		pass

func hit_from_area(other_area : Area2D):
	var collision_dir : int
	if other_area.position > position:
		collision_dir = Constants.Direction.RIGHT
	else:
		collision_dir = Constants.Direction.LEFT
	hit(collision_dir)

func hit(dir : int):
	.hit(dir)
	lives -= 1
	if lives == 0:
		# Game Over
		return
	set_unit_condition_with_timer(Constants.UnitCondition.IS_INVINCIBLE)
	start_flash()
	set_unit_condition(Constants.UnitCondition.MOVING_STATUS, Constants.UnitMovingStatus.IDLE)
	scene.hurt_pause_timer = Constants.HURT_PAUSE_DURATION

func invincibility_ended():
	is_flash = false
	if get_overlapping_areas().size() > 0:
		if get_overlapping_areas()[0] is Unit:
			hit_from_area(get_overlapping_areas()[0])

func dash():
	set_unit_condition(Constants.UnitCondition.MOVING_STATUS, Constants.UnitMovingStatus.DASHING)
	target_move_speed = Constants.DASH_SPEED
	if unit_conditions[Constants.UnitCondition.IS_ON_GROUND]:
		set_sprite(Constants.SpriteClass.DASH)
		
func add_coin():
	coins += 1
	if coins % Constants.COINS_PER_LIFE == 0:
		lives += 1
	emit_signal("update_ui", lives, coins)
