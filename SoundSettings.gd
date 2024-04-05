extends Control

onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")
onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")
onready var music_bar : HScrollBar = get_node("Panel/MarginContainer/VBoxContainer/HBoxContainer/MusicBar")
onready var sfx_bar : HScrollBar = get_node("Panel/MarginContainer/VBoxContainer/HBoxContainer2/SFXBar")

var config = ConfigFile.new()

func _ready():
	if config.load("user://settings.cfg") != OK: # if file doesn't exists / First time opening the game
		change_music_volume(1)
		change_sfx_volume(1)
	else: # if file already exists
		for settings in config.get_sections():
			# Read Music Volume and apply to game
			var music_value = config.get_value(settings, "Music")
			AudioServer.set_bus_volume_db(MUSIC_BUS_ID, linear2db(float(music_value)))
			AudioServer.set_bus_mute(MUSIC_BUS_ID, music_value < .1)
			music_bar.value = float(music_value)
			# Read SFX Volume and apply to game
			var sfx_value = config.get_value(settings, "SFX")
			AudioServer.set_bus_volume_db(SFX_BUS_ID, linear2db(float(sfx_value)))
			AudioServer.set_bus_mute(SFX_BUS_ID, sfx_value < .1)
			sfx_bar.value = float(sfx_value)
	

func change_music_volume(value):
	AudioServer.set_bus_volume_db(MUSIC_BUS_ID, linear2db(value))
	AudioServer.set_bus_mute(MUSIC_BUS_ID, value < .1)
	
	config.set_value("Settings", "Music", value)
	config.save("user://settings.cfg")
	
func change_sfx_volume(value):
	AudioServer.set_bus_volume_db(SFX_BUS_ID, linear2db(value))
	AudioServer.set_bus_mute(SFX_BUS_ID, value < .1)
	
	config.set_value("Settings", "SFX", value)
	config.save("user://settings.cfg")

func _on_MusicBar_value_changed(value):
	change_music_volume(value)

func _on_SFXBar_value_changed(value):
	change_sfx_volume(value)
