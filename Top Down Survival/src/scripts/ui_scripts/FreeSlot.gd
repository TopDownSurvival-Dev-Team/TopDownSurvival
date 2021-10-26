extends Node

var item: InventorySlot = null


func _process(delta):
	if item:
		item.set_global_position(item.get_global_mouse_position())
	
	
func set_slot(new_item: InventorySlot):
	var old_item = item
	if old_item:
		remove_child(old_item)
	
	item = new_item
	add_child(new_item)
	
	return old_item
