extends ColorRect

var item_id: String
var item_name: String
var quantity: int
var item_image: Texture

onready var icon = $Icon


func init(_item_id: String, _quantity: int):
	item_id = _item_id
	item_name = GameData.item_data[item_id]["name"]
	quantity = _quantity
	
	# TODO: Add quantity label
	var image_path = "res://assets/items/%s/%s.png" % [item_name, item_name]
	item_image = load(image_path)
	
	
func _ready():
	icon.set_texture(item_image)
