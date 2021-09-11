extends Control

const INVENTORY_SLOT_SCENE = preload("res://src/scenes/ui_scenes/templates/InventorySlot.tscn")

onready var grid_container = $Background/M/V/ScrollContainer/GridContainer


func open_inventory():
	rpc_id(1, "fetch_inventory_s", Network.local_player_id)
	

func show_inventory():
	visible = true
	
	
func hide_inventory():
	visible = false


func _sort_inv(a, b):
	return int(a["inventory_slot"]) < int(b["inventory_slot"])
	
	
remote func fetch_inventory(inventory_data: Array):
	# Sort inventory data by inventory slot
	inventory_data.sort_custom(self, "_sort_inv")
	
	for item_data in inventory_data:
		# Get item information
		var item_inv_slot = item_data["inventory_slot"]
		var item_id = item_data["item_id"]
		var item_quantity = item_data["quantity"]
		
		var item_name = GameData.item_data[item_id]
		var item_image = load("res://assets/items/%s/%s.png" % item_name)
		
		# Create inventory slot
		# TODO: add quantities
		var new_inv_slot = INVENTORY_SLOT_SCENE.instance()
		var inv_icon = new_inv_slot.get_node("Icon")
		
		new_inv_slot.name = "Inv%s" % item_inv_slot
		inv_icon.texture = item_image
		
		grid_container.add_child(new_inv_slot, true)
		
	# Show inventory menu after adding slots
	show_inventory()
