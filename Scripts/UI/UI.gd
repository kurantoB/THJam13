extends CanvasLayer

onready var lives_label : Label = get_node("CharacterLives")
onready var coins_label : Label = get_node("Coins")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Player_update_ui(lives, coins):
	lives_label.text = "x" + str(lives)
	coins_label.text = "x " + str(coins)
