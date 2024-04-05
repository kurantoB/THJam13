extends Area2D

var Constants = preload("res://Scripts/Constants.gd")

const BULLET_RANGE = 9
const BULLET_SPEED = 12

var x_speed = 0
var y_speed = 0

var x_origin
var y_origin

var time_elapsed = 0

var pos = Vector2()

var scene

func _ready():
	scene = get_node("/root/Scene")
	
	var num_children = find_node("Sprites").get_children().size()
	var child = find_node("Sprites").get_child(randi() % num_children) as Sprite
	child.visible = true

func configure(position: Vector2):
	self.position = position
	self.scale *= Constants.SCALE_FACTOR
	x_origin = position.x / Constants.GRID_SIZE / Constants.SCALE_FACTOR
	y_origin = -1 * position.y / Constants.GRID_SIZE / Constants.SCALE_FACTOR
	pos.x = x_origin
	pos.y = y_origin

func _physics_process(delta):
	if scene.paused or scene.hurt_pause_timer > 0:
		return
	if sqrt(pow(pos.x - x_origin, 2) + pow(pos.y - y_origin, 2)) > BULLET_RANGE:
		queue_free()
	if scene.stage_env.stage_collision(pos.x, pos.y, y_speed < 0):
		queue_free()
	time_elapsed += delta
	pos.x = x_origin + time_elapsed * x_speed
	pos.y = y_origin + time_elapsed * y_speed
	position.x = pos.x * Constants.GRID_SIZE * Constants.SCALE_FACTOR
	position.y = -1 * pos.y * Constants.GRID_SIZE * Constants.SCALE_FACTOR
