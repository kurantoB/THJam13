extends Area2D

const Constants = preload("res://Scripts/Constants.gd")
var TriggeredCoin = preload("res://Scripts/Coin/TriggeredCoin.gd")
var EmptyBlock = preload("res://Scenes/Blocks/EmptyBlock.tscn")

var area_entered_while_jumping = false
var watch_area
var area_entered_first_frame_mark = false

var origin_y
var bump_timer = 0
const BUMP_DURATION = 0.2 # seconds
const BUMP_DISTANCE = 0.5 # grid units

var dialogue_resource : Resource
var dialogue_triggered = false

var scene: GameScene

func set_scene(scene: GameScene):
	self.scene = scene

func _on_ItemBlock_area_entered(area):
	if (area is Player
	and (area as Player).v_speed > 0):
		area_entered_while_jumping = true
		watch_area = area

func process_block(delta):
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
			if dialogue_resource == null:
				# Item block
				var triggered_coin = TriggeredCoin.new()
				scene.add_child(triggered_coin)
				get_tree().get_nodes_in_group("Player")[0].add_coin()
				triggered_coin.scale.x = Constants.SCALE_FACTOR
				triggered_coin.scale.y = Constants.SCALE_FACTOR
				triggered_coin.position.x = position.x + (Constants.GRID_SIZE * Constants.SCALE_FACTOR / 2)
				triggered_coin.position.y = position.y
	if bump_timer > 0:
		var displacement = BUMP_DISTANCE - abs(BUMP_DURATION / 2 - bump_timer) / (BUMP_DURATION / 2) * BUMP_DISTANCE
		position.y = origin_y - displacement * Constants.GRID_SIZE * Constants.SCALE_FACTOR
		bump_timer = max(0, bump_timer - delta)
		if dialogue_resource != null:
			# Info block
			if bump_timer < BUMP_DURATION / 2 and !dialogue_triggered:
				get_tree().get_nodes_in_group("DialogueManager")[0].start_dialogue(dialogue_resource)
				dialogue_triggered = true
			if bump_timer == 0:
				dialogue_triggered = false
		if dialogue_resource == null and bump_timer == 0:
			# Flip item block
			var empty_block = EmptyBlock.instance()
			scene.add_child(empty_block)
			empty_block.scale.x = Constants.SCALE_FACTOR
			empty_block.scale.y = Constants.SCALE_FACTOR
			empty_block.position.x = self.position.x
			empty_block.position.y = origin_y
			scene.blocks.erase(self)
			queue_free()
	else:
		position.y = origin_y
