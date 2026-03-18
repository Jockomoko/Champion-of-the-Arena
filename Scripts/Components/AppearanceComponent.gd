extends Resource
class_name AppearanceComponent
var style = {
		"body_color": Color.WHITE,
		"hair_color": Color.WHITE,
		"hair_id": 0,
		"eye_id" : 0,
		"mouth_id" : 0
	}

func to_dict() -> Dictionary:
	return {
		"body_color": style["body_color"].to_html(),
		"hair_color": style["hair_color"].to_html(),
		"hair_id": style["hair_id"],
		"eye_id": style["eye_id"],
		"mouth_id": style["mouth_id"]
	}

static func from_dict(data: Dictionary) -> AppearanceComponent:
	var a := AppearanceComponent.new()
	a.style["body_color"] = Color(data["body_color"])
	a.style["hair_color"] = Color(data["hair_color"])
	a.style["hair_id"]    = data["hair_id"]
	a.style["eye_id"]     = data["eye_id"]
	a.style["mouth_id"]   = data["mouth_id"]
	return a

func set_appearance(apperance : Dictionary):
	style["body_color"] = Color(apperance["body_color"]) if apperance.has("body_color") else Color.WHITE
	style["hair_color"] = Color(apperance["hair_color"]) if apperance.has("hair_color") else Color.WHITE
	style["hair_id"]    = apperance.get("hair_id", 0)
	style["eye_id"]     = apperance.get("eye_id", 0)
	style["mouth_id"]   = apperance.get("mouth_id", 0)
