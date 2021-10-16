extends Control

const INVENTORY_SLOT_SCENE = preload("res://src/scenes/ui_scenes/templates/InventorySlot.tscn")

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
	
	
func remove_all_items():
	for item in grid_container.get_children():
		grid_container.remove_child(item)
		item.queue_free()


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
		
		var item_name = GameData.item_data[item_id]["name"]
		var image_path = "res://assets/items/%s/%s.png" % [item_name, item_name]
		var item_image = load(image_path)
		
		# Create inventory slot
		# TODO: add quantities
		var new_inv_slot = INVENTORY_SLOT_SCENE.instance()
		var inv_icon = new_inv_slot.get_node("Icon")
		
		new_inv_slot.name = "Inv%s" % item_inv_slot
		inv_icon.texture = item_image
		
		grid_container.add_child(new_inv_slot, true)
		
	# Show inventory menu after adding slots
	_show_inventory()
