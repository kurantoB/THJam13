extends Area2D
class_name TriggerDialogue

export var post_interact_disable : bool
# How to use
# add this node to anything and add own collisionshape, can also be used in specific events you are going for.

## drag and drop dialogues from res://Resources/Dialogues/
export(Resource) var dialogue_resource

func trigger_dialogue():
	get_tree().get_nodes_in_group("DialogueManager")[0].start_dialogue(dialogue_resource)
	if post_interact_disable == true:
		queue_free()

func _on_TriggerDialogue_area_entered(area):
	# add however you want the dialogue to be triggered.
	pass
