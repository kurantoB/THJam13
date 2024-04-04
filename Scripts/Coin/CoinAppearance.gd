extends Node2D

func _ready():
	var num_children = get_children().size()
	var child = get_child(randi() % num_children) as AnimatedSprite
	child.visible = true
	child.play()
