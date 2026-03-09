extends Resource
class_name AppearanceComponent

var body_color: Color = Color.WHITE
var hair_color: Color = Color.BROWN
var hair_id: int = 0 
var eye_id : int = 0
var mouth_id : int = 0

func to_dict() -> Dictionary:
	return {
		"body_color": body_color.to_html(),
		"hair_color": hair_color.to_html(),
		"hair_id": hair_id,
		"eye_id" : eye_id,
		"mouth_id" : mouth_id
	}

static func from_dict(data: Dictionary) -> AppearanceComponent:
	var a = AppearanceComponent.new()
	a.body_color = Color(data["body_color"])
	a.hair_color = Color(data["hair_color"])
	a.hair_id = data["hair_id"]
	a.eye_id = data["eye_id"]
	a.mouth_id = data["mouth_id"]
	return a

func load_apperance(apperance : Dictionary):
	body_color = apperance["body_color"]
	hair_color = apperance["hair_color"]
	hair_id = apperance["hair_id"]
	eye_id = apperance["eye_id"]
	mouth_id = apperance["mouth_id"]
