extends Control
class_name Stat_Changer

@onready var stat_amout_txt: AutoSizeLabel = $VBoxContainer/HBoxContainer/Stat_amout_txt
@onready var stat_name_txt: AutoSizeLabel = $VBoxContainer/Stat_Name_txt


var amount: int
var statName: String


func setup(p_stat_name: String, p_amount: int) -> void:
	statName = p_stat_name
	amount = p_amount

	# Apply immediately if node already ready
	if is_node_ready():
		_apply()


func _ready() -> void:
	_apply()


func _apply() -> void:
	stat_name_txt.text = statName
	stat_amout_txt.text = str(amount)
