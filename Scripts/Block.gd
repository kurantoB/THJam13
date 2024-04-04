extends Area2D

const Constants = preload("res://Scripts/Constants.gd")

var area_entered_while_jumping = false
var watch_area
var area_entered_first_frame_mark = false

var origin_y
var bump_timer = 0
const BUMP_DURATION = 0.2 # seconds
const BUMP_DISTANCE = 0.5 # grid units

var dialogue_resource : Resource
var dialogue_triggered = false

func _on_ItemBlock_area_entered(area):
	if (area is Player
	and (area as Player).v_speed > 0):
		area_entered_while_jumping = true
		watch_area = area

func _process(delta):
	if area_entered_while_jumping:
		area_entered_while_jumping = false
		area_entered_first_frame_mark = true
		return
	if area_entered_first_frame_mark:
		area_entered_first_frame_mark = false
		area_entered_while_jumping = false
		if (watch_area as Player).v_speed < 0:
			# triggered
			bump_timer = BUMP_DURATION
	if bump_timer > 0:
		var displacement = BUMP_DISTANCE - abs(BUMP_DURATION / 2 - bump_timer) / (BUMP_DURATION / 2) * BUMP_DISTANCE
		position.y = origin_y - displacement * Constants.GRID_SIZE * Constants.SCALE_FACTOR
		bump_timer = max(0, bump_timer - delta)
		if dialogue_resource != null:
			if bump_timer < BUMP_DURATION / 2 and !dialogue_triggered:
				get_tree().get_nodes_in_group("DialogueManager")[0].start_dialogue(dialogue_resource)
				dialogue_triggered = true
			if bump_timer == 0:
				dialogue_triggered = false
	else:
		position.y = origin_y
