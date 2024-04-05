extends Node2D

var CoinAppearance = preload("res://Scenes/Coin/CoinAppearance.tscn")
var Constants = preload("res://Scripts/Constants.gd")

var INIT_VELOCITY = 9
var DECELERATION = .7

var current_velocity = INIT_VELOCITY

func _init():
	var c_a = CoinAppearance.instance()
	add_child(c_a)
	INIT_VELOCITY *= Constants.GRID_SIZE * Constants.SCALE_FACTOR
	DECELERATION *= Constants.GRID_SIZE * Constants.SCALE_FACTOR

func _physics_process(delta):
	if get_node("/root/Scene").paused or get_node("/root/Scene").hurt_pause_timer > 0:
		return
	if current_velocity == 0:
		queue_free()
	position.y -= current_velocity
	if current_velocity > 0:
		current_velocity = max(0, current_velocity - delta * DECELERATION)
