extends Control

export var preview: bool = false
var item_id: String
var quantity: int

onready var info_label = $H/Info
onready var icon = $H/Icon


func init(_item_id: String, _quantity: int):
	item_id = _item_id
	quantity = _quantity
	
	
func _ready():
	if preview:
		return
	
	var item_name = GameData.item_data[item_id]["name"]
	info_label.text = "%s (x%s)" % [item_name, quantity]
	
	var image_path = "res://assets/items/%s/%s.png" % [item_name, item_name]
	var image = load(image_path)
	icon.texture = image
