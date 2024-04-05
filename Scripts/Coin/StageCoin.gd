extends Node

var CoinAppearance = preload("res://Scenes/Coin/CoinAppearance.tscn")
var Constants = preload("res://Scripts/Constants.gd")

func _init():
	var c_a = CoinAppearance.instance()
	add_child(c_a)

func _on_Area2D_area_entered(area):
	if area is Player:
		area.call("add_coin")
		queue_free()
		get_node("/root/Scene/SFX/Coin").play()
