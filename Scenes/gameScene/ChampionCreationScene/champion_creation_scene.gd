extends Node2D

const STATS_COMPONENT  = preload("uid://cuxf7gcv3feum")
const STATS_CHANGER = preload("uid://ijsge7t485at")
@onready var champion_1Vbox: VBoxContainer = $Control/ColorRect/VBoxContainer/HBoxContainer/Champion1_stats
@onready var champion_2Vbox: VBoxContainer = $Control/ColorRect/VBoxContainer/HBoxContainer/Champion2_stats


var path := "user://test_save.json"
var save_data = { "Success_save": 1}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Booting stat UI...")

	# Clear existing children safely
	_clear_vbox(champion_1Vbox)
	_clear_vbox(champion_2Vbox)

	# Get stats
	var stats := STATS_COMPONENT.new()

	# Loop through each stat and build UI
	for stat_name in stats.base_stats.keys():
		var value = stats.base_stats[stat_name]
		print("Stat: ", stat_name, " Value:", value)

		# Champion 1 stat button
		var statChanger1 = STATS_CHANGER.instantiate()
		statChanger1.setup(stat_name, value)

		# Make it fill the VBoxContainer completely
		statChanger1.size_flags_horizontal = Control.SIZE_FILL | Control.SIZE_EXPAND
		statChanger1.size_flags_vertical   = Control.SIZE_FILL | Control.SIZE_EXPAND
		
		champion_1Vbox.add_child(statChanger1)

		# Champion 2 stat button
		var statChanger2 = STATS_CHANGER.instantiate()
		statChanger2.setup(stat_name, value)
		# Same for second champion
		
		statChanger2.size_flags_horizontal = Control.SIZE_FILL | Control.SIZE_EXPAND
		statChanger2.size_flags_vertical   = Control.SIZE_FILL | Control.SIZE_EXPAND
		
		champion_2Vbox.add_child(statChanger2)


# Helper function to safely clear a VBoxContainer
func _clear_vbox(vbox: VBoxContainer) -> void:
	for child in vbox.get_children():
		child.queue_free()  # safely removes the child after the current frame

func get_all_stats_from_VBoxContainer(vbox: VBoxContainer) -> String:
	var result = "{ \n"
	for child : Stat_Changer in vbox.get_children():
		result += "\t" + child.stat_name_txt.text + "\t" + child.stat_amout_txt.text
		result += "\n"
	result += "} \n"
	return result


func _on_save_btn_pressed() -> void:
	
	var savefiled : String = ""
	savefiled += "champion1\n"
	savefiled += get_all_stats_from_VBoxContainer(champion_1Vbox)
	savefiled += "champion2\n"
	savefiled += get_all_stats_from_VBoxContainer(champion_2Vbox)
	
	var file = FileAccess.open(path, FileAccess.WRITE_READ)
	
	if not file:
		return
		
	file.store_string(savefiled)
	file.close()
	
	get_tree().change_scene_to_file("res://Scenes/gameScene/start meny/StartScene.tscn")


func _on_exit_btn_pressed() -> void:
	get_tree().quit()
