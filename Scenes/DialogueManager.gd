extends Control

export(Resource) var test_dialogue
onready var anim : AnimationPlayer = get_node("AnimationPlayer")
onready var popup_text : Label = get_node("PopupText")
export(Array, String) var current_dialogue
var input_available : bool = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#if test_dialogue != null:
	#	start_dialogue(test_dialogue)

func start_dialogue(dialogue):
	current_dialogue = dialogue.text
	next_dialogue()
	
func next_dialogue():
	if not current_dialogue.size() == 0:
		popup_text.text = current_dialogue.pop_front()
		anim.play("In")
		input_available = false
	else:
		end_dialogue()

func end_dialogue():
	anim.play("Out")

func _input(event):
	if (Input.is_action_just_pressed("gba_a") or Input.is_action_just_pressed("gba_start")) and input_available == true:
		next_dialogue()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "In":
		input_available = true
		get_tree().paused = true
	elif anim_name == "Out":
		input_available = false
		get_tree().paused = false
