extends Control

const INVENTORY_SLOT_SCENE = preload("res://src/scenes/ui_scenes/templates/InventorySlot.tscn")

onready var free_slot = $Background/FreeSlot
onready var grid_container = $Background/M/V/ScrollContainer/GridContainer


func _input(event):
	if event.is_action_pressed("toggle_inventory"):
		if visible:
			hide_inventory()
		else:
			open_inventory()
	
	
func open_inventory():
	rpc_id(1, "fetch_inventory_s")
	
	
func _show_inventory():
	visible = true
	
	
func hide_inventory():
	visible = false
	var floating_slot = free_slot.set_slot(null)
	
	if floating_slot:
		if grid_container.get_child_count() != 0:
			var last_slot = grid_container.get_children().back()
			var slot_position = last_slot.name.trim_prefix("Inv").to_int()
			floating_slot.name = "Inv%s" % slot_position
			grid_container.add_child(floating_slot)
			grid_container.move_child(floating_slot, slot_position)
	
	
func remove_all_items():
	for item in grid_container.get_children():
		grid_container.remove_child(item)
		item.queue_free()
	
	
func on_slot_pressed(slot_name: String):
	var slot = grid_container.get_node(slot_name)
	grid_container.remove_child(slot)
	var floating_slot = free_slot.set_slot(slot)
	
	if floating_slot:
		var slot_position = slot_name.trim_prefix("Inv").to_int()
		floating_slot.name = slot_name
		grid_container.add_child(floating_slot)
		grid_container.move_child(floating_slot, slot_position)
	
	
func _sort_inv(a, b):
	return int(a["inventory_slot"]) < int(b["inventory_slot"])
	
	
remote func fetch_inventory(inventory_data: Array):
	remove_all_items()
	
	# Sort inventory data by inventory slot
	inventory_data.sort_custom(self, "_sort_inv")
	
	for item_data in inventory_data:
		# Get item information
		var item_inv_slot = item_data["inventory_slot"]
		var item_id = item_data["item_id"]
		var item_quantity = item_data["quantity"]
		
		# Create inventory slot
		var new_inv_slot = INVENTORY_SLOT_SCENE.instance()
		new_inv_slot.init(item_id, item_quantity)
		new_inv_slot.name = "Inv%s" % item_inv_slot
		
		grid_container.add_child(new_inv_slot, true)
		
	# Show inventory menu after adding slots
	_show_inventory()
	
	
func _on_ExitButton_pressed():
	hide_inventory()
