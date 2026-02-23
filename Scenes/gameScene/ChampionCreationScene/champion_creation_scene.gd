extends Node2D

const STATS_COMPONENT  = preload("uid://cuxf7gcv3feum")
const STATS_CHANGER = preload("uid://ijsge7t485at")
@onready var champion_1Vbox: VBoxContainer = $Control/MarginContainer/VBoxContainer/BodyContainer/Champion1_margincontainer/TextureRect/ChampionsContainer/MarginContainer/Champion1_stats
@onready var champion_2Vbox: VBoxContainer = $Control/MarginContainer/VBoxContainer/BodyContainer/Champion2_margincontainer2/TextureRect/ChampionsContainer/MarginContainer/Champion2_stats
@onready var stat_point_champion_1_txt: AutoSizeLabel = $Control/MarginContainer/VBoxContainer/BodyContainer/Champion1_margincontainer/TextureRect/stat_point_champion1_txt
@onready var stat_point_champion_2_txt: AutoSizeLabel = $Control/MarginContainer/VBoxContainer/BodyContainer/Champion2_margincontainer2/TextureRect/stat_point_champion2_txt


const path := Globals.SAVED_CHAMPION_PATH

var NewTeamComponent = TeamComponent.new()

var stats_point_champion1 = NewTeamComponent.stats_points
var stats_point_champion2 = NewTeamComponent.stats_points
var min_stat_point = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	stat_point_champion_1_txt.text = str(stats_point_champion1)
	stat_point_champion_2_txt.text = str(stats_point_champion2)
	
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
		
		statChanger1.stat_added.connect(_on_stat_added_champion1)
		statChanger1.stat_removed.connect(_on_stat_removed_champion1)
		
		# Make it fill the VBoxContainer completely
		statChanger1.size_flags_horizontal = Control.SIZE_FILL | Control.SIZE_EXPAND
		statChanger1.size_flags_vertical   = Control.SIZE_FILL | Control.SIZE_EXPAND
		
		champion_1Vbox.add_child(statChanger1)

		# Champion 2 stat button
		var statChanger2 = STATS_CHANGER.instantiate()
		statChanger2.setup(stat_name, value)
		
		statChanger2.stat_added.connect(_on_stat_added_champion2)
		statChanger2.stat_removed.connect(_on_stat_removed_champion2)
		
		statChanger2.size_flags_horizontal = Control.SIZE_FILL | Control.SIZE_EXPAND
		statChanger2.size_flags_vertical   = Control.SIZE_FILL | Control.SIZE_EXPAND
		
		champion_2Vbox.add_child(statChanger2)

# Helper function to safely clear a VBoxContainer
func _clear_vbox(vbox: VBoxContainer) -> void:
	for child in vbox.get_children():
		child.queue_free()  # safely removes the child after the current frame

func get_all_stats_from_VBoxContainer(vbox: VBoxContainer) -> Dictionary:
	var stats: Dictionary = {}

	for child: Stat_Changer in vbox.get_children():
		stats[child.stat_name_txt.text] = int(child.stat_amout_txt.text)

	# Convert dictionary → JSON string
	return stats


func _on_save_btn_pressed() -> void:
	
	if stats_point_champion1 > 0 || stats_point_champion2 > 0 :
		print("Must use all stat points")
		return
	
	var updated_data : Dictionary = {
		"champion1": get_all_stats_from_VBoxContainer(champion_1Vbox),
		"champion2": get_all_stats_from_VBoxContainer(champion_2Vbox)
	}
	
	var file := FileAccess.open(path, FileAccess.WRITE_READ)
	
	if file == null:
		print("Failed to open save file")
		return
	file.store_string(JSON.stringify(updated_data, "\t"))
	file.close()
	
	get_tree().change_scene_to_file("res://Scenes/gameScene/start meny/StartScene.tscn")


func _on_exit_btn_pressed() -> void:
	get_tree().quit()

func _on_stat_added_champion1(stat_changer_class : Stat_Changer):
	if stats_point_champion1 < 1 :
		return
	stats_point_champion1 -= 1
	stat_changer_class.amount += 1
	stat_changer_class._apply()
	stat_point_champion_1_txt.text = str(stats_point_champion1)

func _on_stat_removed_champion1(stat_changer_class : Stat_Changer):
	if stat_changer_class.amount <= min_stat_point :
		return
	stats_point_champion1 += 1
	stat_changer_class.amount -= 1
	stat_changer_class._apply()
	stat_point_champion_1_txt.text = str(stats_point_champion1)
	
func _on_stat_added_champion2(stat_changer_class : Stat_Changer):
	if stats_point_champion2 < 1 :
		return
	stats_point_champion2 -= 1
	stat_changer_class.amount += 1
	stat_changer_class._apply()
	stat_point_champion_2_txt.text = str(stats_point_champion2)

func _on_stat_removed_champion2(stat_changer_class : Stat_Changer):
	if stat_changer_class.amount <= min_stat_point :
		return
	stats_point_champion2 += 1
	stat_changer_class.amount -= 1
	stat_changer_class._apply()
	stat_point_champion_2_txt.text = str(stats_point_champion2)
