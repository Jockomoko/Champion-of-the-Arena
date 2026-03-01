extends Resource
class_name AppearanceComponent

@export var body_color: Color = Color.WHITE
@export var hair_color: Color = Color.BROWN
@export var hair_id: int = 0 
var eye_id : int = 0
var mouth_id : int = 0

func to_dict() -> Dictionary:
	return {
		"body_color": body_color.to_html(),
		"hair_color": hair_color.to_html(),
		"hair_style": hair_id
	}

static func from_dict(data: Dictionary) -> AppearanceComponent:
	var a = AppearanceComponent.new()
	a.body_color = Color(data["body_color"])
	a.hair_color = Color(data["hair_color"])
	a.hair_id = data["hair_id"]
	return a
