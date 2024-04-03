extends Control

onready var anim_player = get_node("AnimationPlayer")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func go_to_game_scene():
	get_tree().change_scene("res://Scenes/SandboxScene.tscn")
	
func _on_PlayButton_pressed():
	anim_player.play("FadeOut")
