extends Node2D

export var frequency: float
export var speed: int
export var type: int # 0: ->, 1: <-, 2: /|\, 3: \|/

const Bullet = preload("res://Scenes/Bullet.tscn")
var Constants = preload("res://Scripts/Constants.gd")

var scene
var time_to_next

func _ready():
	scene = get_node("/root/Scene")
	position.x *= Constants.SCALE_FACTOR
	position.y *= Constants.SCALE_FACTOR
	time_to_next = 1 / frequency

func _process(delta):
	if scene.paused or scene.hurt_pause_timer > 0:
		return
	if time_to_next <= 0:
		time_to_next = 1 / frequency
		var bullet = Bullet.instance()
		scene.get_node("Bullets").add_child(bullet)
		bullet.configure(position)
		match type:
			0:
				bullet.x_speed = speed
			1:
				bullet.x_speed = -speed
			2:
				bullet.y_speed = speed
			3:
				bullet.y_speed = -speed
	time_to_next -= delta
