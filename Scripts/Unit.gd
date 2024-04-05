extends Area2D

# base class for units
# we assume every unit can move and jump so we see their handlers here
# sprite management is handled here (and subclasses) as well
class_name Unit


const Constants = preload("res://Scripts/Constants.gd")
const GameUtils = preload("res://Scripts/GameUtils.gd")

var scene

# position
export var unit_type : int

var actions = {}
var unit_conditions = {}
var facing : int = Constants.Direction.RIGHT
var current_action_time_elapsed : float = 0
var unit_condition_timers = {}

var pos : Vector2
var h_speed : float = 0
var v_speed : float = 0
var target_move_speed : float
var last_contacted_ground_collider : Array

var current_sprite : Node2D
var sprite_class_nodes = {} # sprite class to node list dictionary

var hit_queued : bool = false
var hit_dir : int
var time_elapsed : float
var is_flash : bool = false
var flash_start_timestamp : float

var timer_actions = {}

# Called when the node enters the scene tree for the first time
func _ready():
	for action_num in Constants.UNIT_TYPE_ACTIONS[unit_type]:
		actions[action_num] = false
	for condition_num in Constants.UNIT_TYPE_CONDITIONS[unit_type].keys():
		set_unit_condition(condition_num, Constants.UNIT_TYPE_CONDITIONS[unit_type][condition_num])
	for condition_num in Constants.UNIT_CONDITION_TIMERS[unit_type].keys():
		unit_condition_timers[condition_num] = 0
	target_move_speed = Constants.UNIT_TYPE_MOVE_SPEEDS[unit_type]
	
	# populate sprite_class_nodes
	for sprite_class in Constants.UNIT_SPRITES[unit_type]:
		sprite_class_nodes[sprite_class] = []
		for node_name in Constants.UNIT_SPRITES[unit_type][sprite_class][1]:
			sprite_class_nodes[sprite_class].append(get_node(node_name))
	
	pos = Vector2(position.x / Constants.GRID_SIZE, -1 * position.y / Constants.GRID_SIZE) / Constants.SCALE_FACTOR
	position.x = position.x * Constants.SCALE_FACTOR
	position.y = position.y * Constants.SCALE_FACTOR
	scale.x = Constants.SCALE_FACTOR
	scale.y = Constants.SCALE_FACTOR
	
	for timer_action_num in Constants.ACTION_TIMERS[unit_type].keys():
		timer_actions[timer_action_num] = 0

func _process(delta):
	# stop animating sprite if paused
	if current_sprite is AnimatedSprite:
		if scene.paused or scene.hurt_pause_timer > 0:
			if current_sprite.playing:
				current_sprite.stop()
		else:
			if !current_sprite.playing:
				current_sprite.play()

func init_unit_w_scene(scene):
	self.scene = scene

func set_action(action : int):
	assert(action in Constants.UNIT_TYPE_ACTIONS[unit_type])
	actions[action] = true

func set_timer_action(action : int):
	assert(action in Constants.UNIT_TYPE_ACTIONS[unit_type])
	assert(action in Constants.ACTION_TIMERS[unit_type].keys())
	timer_actions[action] = Constants.ACTION_TIMERS[unit_type][action]

func do_with_timeout(action : int):
	if timer_actions[action] == 0:
		set_action(action)
		set_timer_action(action)

func reset_timer_action(action : int):
	assert(action in Constants.UNIT_TYPE_ACTIONS[unit_type])
	assert(action in Constants.ACTION_TIMERS[unit_type].keys())
	timer_actions[action] = 0

func set_unit_condition(condition_type : int, condition):
	assert(condition_type in Constants.UNIT_TYPE_CONDITIONS[unit_type].keys())
	unit_conditions[condition_type] = condition

func set_unit_condition_with_timer(condition_type : int):
	assert(condition_type in Constants.UNIT_CONDITION_TIMERS[unit_type].keys())
	set_unit_condition(condition_type, Constants.UNIT_CONDITION_TIMERS[unit_type][condition_type][1])
	unit_condition_timers[condition_type] = Constants.UNIT_CONDITION_TIMERS[unit_type][condition_type][0]

func get_condition(condition_num : int, default):
	if condition_num in Constants.UNIT_TYPE_CONDITIONS[unit_type].keys():
		return unit_conditions[condition_num]
	else:
		return default

func is_current_action_timer_done(current_action : int):
	assert(current_action in Constants.CURRENT_ACTION_TIMERS[unit_type].keys())
	return current_action_time_elapsed >= Constants.CURRENT_ACTION_TIMERS[unit_type][current_action]

func reset_actions():
	for action_num in Constants.UNIT_TYPE_ACTIONS[unit_type]:
		actions[action_num] = false

func process_unit(delta, time_elapsed : float):
	current_action_time_elapsed += delta
	execute_actions(delta)
	handle_idle()
	advance_timers(delta)
	handle_moving_status(delta)
	handle_recoil() # must be after handle_moving_status
	reset_current_action()
	self.time_elapsed = time_elapsed

func advance_timers(delta):
	for timer_action_num in Constants.ACTION_TIMERS[unit_type].keys():
		timer_actions[timer_action_num] = move_toward(timer_actions[timer_action_num], 0, delta)
	for condition_num in Constants.UNIT_CONDITION_TIMERS[unit_type].keys():
		unit_condition_timers[condition_num] = move_toward(unit_condition_timers[condition_num], 0, delta)
		if unit_condition_timers[condition_num] == 0:
			set_unit_condition(condition_num, Constants.UNIT_CONDITION_TIMERS[unit_type][condition_num][2])
			if condition_num == Constants.UnitCondition.IS_INVINCIBLE:
				invincibility_ended()

func reset_current_action():
	# process CURRENT_ACTION
	if get_current_action() == Constants.UnitCurrentAction.JUMPING:
		if not actions[Constants.ActionType.JUMP]:
			set_current_action(Constants.UnitCurrentAction.IDLE)
	# process MOVING_STATUS
	if not actions[Constants.ActionType.MOVE] and not (Constants.UNIT_TYPE_ACTIONS[unit_type].find(Constants.ActionType.DASH) != -1 and actions[Constants.ActionType.DASH]):
		set_unit_condition(Constants.UnitCondition.MOVING_STATUS, Constants.UnitMovingStatus.IDLE)

func handle_input(delta):
	# implemented in subclass
	pass

func get_current_action():
	return unit_conditions[Constants.UnitCondition.CURRENT_ACTION]

func set_current_action(current_action : int):
	assert(current_action in Constants.UNIT_TYPE_CURRENT_ACTIONS[unit_type])
	if get_current_action() != current_action:
		current_action_time_elapsed = 0
	set_unit_condition(Constants.UnitCondition.CURRENT_ACTION, current_action)

func execute_actions(delta):
	for action_num in Constants.UNIT_TYPE_ACTIONS[unit_type]:
		if !actions[action_num]:
			continue
		match action_num:
			Constants.ActionType.JUMP:
				jump()
			Constants.ActionType.MOVE:
				move()

func jump():
	set_current_action(Constants.UnitCurrentAction.JUMPING)
	if (unit_conditions[Constants.UnitCondition.IS_ON_GROUND]):
		# hit ground
		v_speed = max(Constants.UNIT_TYPE_JUMP_SPEEDS[unit_type], v_speed)
	else:
		# airborne
		v_speed = max(Constants.UNIT_TYPE_JUMP_SPEEDS[unit_type], move_toward(v_speed, Constants.UNIT_TYPE_JUMP_SPEEDS[unit_type], get_process_delta_time() * Constants.GRAVITY))
	set_unit_condition(Constants.UnitCondition.IS_ON_GROUND, false)
	if get_current_action() == Constants.UnitCurrentAction.JUMPING and v_speed > 0:
		set_sprite(Constants.SpriteClass.JUMP, 0)
	if is_current_action_timer_done(Constants.UnitCurrentAction.JUMPING):
		set_current_action(Constants.UnitCurrentAction.IDLE)
		

func move():
	set_unit_condition(Constants.UnitCondition.MOVING_STATUS, Constants.UnitMovingStatus.MOVING)
	if (get_current_action() == Constants.UnitCurrentAction.IDLE
	and unit_conditions[Constants.UnitCondition.IS_ON_GROUND]):
		set_sprite(Constants.SpriteClass.WALK)
	target_move_speed = Constants.UNIT_TYPE_MOVE_SPEEDS[unit_type]

func handle_recoil():
	# implemented in subclass
	pass

func handle_moving_status(delta):
	# what we have: facing, current speed, move status, grounded
	# we want: to set the new intended speed
	var magnitude : float
	if unit_conditions[Constants.UnitCondition.IS_ON_GROUND]:
		magnitude = sqrt(pow(v_speed, 2) + pow(h_speed, 2))
	else:
		magnitude = abs(h_speed)
	
	# if move status is idle
	if unit_conditions[Constants.UnitCondition.MOVING_STATUS] == Constants.UnitMovingStatus.IDLE:
		# slow down
		magnitude = move_toward(magnitude, 0, Constants.ACCELERATION * delta)
	# if move status is not idle
	else:
		# if is facing-aligned
		if (h_speed <= 0 and facing == Constants.Direction.LEFT) or (h_speed >= 0 and facing == Constants.Direction.RIGHT):
			# speed up
			magnitude = move_toward(magnitude, target_move_speed, Constants.ACCELERATION * delta)
		# if is not facing-aligned
		else:
			# slow down
			magnitude = move_toward(magnitude, 0, Constants.ACCELERATION * delta)
	
	# if is grounded
	if unit_conditions[Constants.UnitCondition.IS_ON_GROUND]:
		# make magnitude greater than quantum distance
		if magnitude > 0 and magnitude < Constants.QUANTUM_DIST:
			magnitude = Constants.QUANTUM_DIST * 2
		
		# make move vector point down
		if magnitude > 0:
			if h_speed > 0:
				h_speed = Constants.QUANTUM_DIST # preserve h direction
			elif h_speed < 0:
				h_speed = -1 * Constants.QUANTUM_DIST
			else:
				# from still to moving
				if facing == Constants.Direction.RIGHT:
					h_speed = Constants.QUANTUM_DIST
				else:
					h_speed = -1 * Constants.QUANTUM_DIST
		else:
			h_speed = 0
		v_speed = -1 * magnitude
	# if is not grounded
	else:
		# set h_speed
		if magnitude > 0:
			if h_speed > 0:
				h_speed = magnitude
			elif h_speed < 0:
				h_speed = -1 * magnitude
			else:
				# from no lateral movement to having lateral movement
				if facing == Constants.Direction.RIGHT:
					h_speed = magnitude
				else:
					h_speed = -1 * magnitude
		else:
			h_speed = 0

func handle_idle():
	if get_current_action() == Constants.UnitCurrentAction.IDLE:
		if unit_conditions[Constants.UnitCondition.IS_ON_GROUND]:
			if unit_conditions[Constants.UnitCondition.MOVING_STATUS] == Constants.UnitMovingStatus.IDLE:
				set_sprite(Constants.SpriteClass.IDLE)
		elif v_speed > 0:
			set_sprite(Constants.SpriteClass.JUMP, 0)
		else:
			set_sprite(Constants.SpriteClass.JUMP, 1)

func set_sprite(sprite_class : int, index : int = 0):
	assert(unit_type in Constants.UNIT_SPRITES)
	assert(sprite_class in Constants.UNIT_SPRITES[unit_type])
	var node_list = sprite_class_nodes[sprite_class]
	var true_index : int = index
	if true_index > len(node_list) - 1:
		true_index = 0
	var new_sprite : Node2D = node_list[true_index]
	if (is_flash):
		if int((time_elapsed - flash_start_timestamp) / Constants.FLASH_CYCLE) % 2 == 1:
			new_sprite.set_modulate(Color(2, 1, 1))
		else:
			new_sprite.set_modulate(Color(1, .5, .5))
	else:
		new_sprite.set_modulate(Color(1, 1, 1))
	if current_sprite == null or current_sprite != new_sprite:
		if current_sprite != null:
			current_sprite.visible = false
		current_sprite = new_sprite
		current_sprite.visible = true
		if (Constants.UNIT_SPRITES[unit_type][sprite_class][0]):
			current_sprite.set_frame(0)
			current_sprite.play()
	if facing == Constants.Direction.LEFT:
		current_sprite.scale.x = -1
	else:
		current_sprite.scale.x = 1

func react(delta):
	pos.x = pos.x + h_speed * delta
	pos.y = pos.y + v_speed * delta
	position.x = pos.x * Constants.GRID_SIZE * Constants.SCALE_FACTOR
	position.y = -1 * pos.y * Constants.GRID_SIZE * Constants.SCALE_FACTOR

func hit(dir : int):
	# implemented in subclass
	hit_queued = true
	hit_dir = dir

func start_flash():
	is_flash = true
	flash_start_timestamp = time_elapsed

func invincibility_ended():
	# implemented in subclass
	pass

func delete_unit():
	scene.units.erase(self)
	queue_free()
