extends Control

const INVENTORY_ROW_SCENE = preload("res://src/scenes/ui_scenes/templates/InventoryRow.tscn")

onready var row_container = $V/SC/RowContainer


func _ready():
	# Remove preview slots
	for row in row_container.get_children():
		row_container.remove_child(row)
		row.queue_free()
	
	rpc_id(1, "fetch_inventory_s")
	
	
remote func fetch_inventory(inventory_data: Array):
	for item_info in inventory_data:
		var item_id = item_info["item_id"]
		var item_quantity = item_info["quantity"]
		
		var new_inv_row = INVENTORY_ROW_SCENE.instance()
		new_inv_row.init(item_id, item_quantity)
		row_container.add_child(new_inv_row)
