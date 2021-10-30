extends Node2D
class_name Item

var item_id: String
var quantity: int


func init(scene_name: String, _item_id: String, _quantity: int):
	name = scene_name
	item_id = _item_id
	quantity = _quantity
	
	
remote func pick_up_s():
	var id = get_tree().get_rpc_sender_id()
	
	# Remove item from scene
	var scene_id = name.split("-")[1].to_int()
	get_tree().call_group("World", "despawn_item_s", item_id, scene_id)
	
	# Update player inventory
	# FIXME: call_group doesn't work
	get_tree().call_group("Inventory", "add_item_s", id, item_id, quantity)
