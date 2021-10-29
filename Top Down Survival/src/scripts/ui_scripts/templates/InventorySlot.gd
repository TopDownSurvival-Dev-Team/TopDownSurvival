extends Button
class_name InventorySlot

var item_id: String
var item_name: String
var quantity: int
var item_image: Texture

onready var item_icon = $Background/Icon
onready var inventory = find_parent("Inventory")


func init(_item_id: String, _quantity: int):
	item_id = _item_id
	item_name = GameData.item_data[item_id]["name"]
	quantity = _quantity
	
	# TODO: Add quantity label
	var image_path = "res://assets/items/%s/%s.png" % [item_name, item_name]
	item_image = load(image_path)
	
	
func _ready():
	item_icon.set_texture(item_image)
	
	
func set_clickable(value: bool):
	if value:
		mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		mouse_filter = Control.MOUSE_FILTER_IGNORE


func _on_pressed():
	inventory.on_slot_pressed(name)
