extends Node

var item: InventorySlot = null


func _process(delta):
	if item:
		item.set_global_position(item.get_global_mouse_position() - item.rect_size / 2)
	
	
func set_slot(new_item: InventorySlot):
	var old_item = item
	if old_item:
		old_item.clickable = true
		remove_child(old_item)
	
	item = new_item
	if new_item:
		item.clickable = false
		add_child(new_item)
	
	return old_item
