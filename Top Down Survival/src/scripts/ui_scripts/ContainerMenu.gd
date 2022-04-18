extends Control

const CONTAINER_ROW_SCENE = preload("res://src/scenes/ui_scenes/templates/ContainerRow.tscn")

onready var inventory_container = $H/Inventory/SC/V
onready var container_container = $H/Container/SC/V


func _ready():
	# Clear preview items
	clear_all_items()


func _input(event: InputEvent):
	if visible and event.is_action_pressed("ui_cancel"):
		close_menu()


func close_menu():
	rpc_id(1, "close_menu_s")
	visible = false

 
func clear_all_items():
	for node in inventory_container.get_children():
		inventory_container.remove_child(node)
		node.queue_free()

	for node in container_container.get_children():
		container_container.remove_child(node)
		node.queue_free()


remote func show_menu(container_name: String, inventory_data: Array, container_items: Array):
	clear_all_items()

	for item_info in inventory_data:
		var item_id = item_info["item_id"]
		var item_quantity = item_info["quantity"]
		add_inventory_item(item_id, item_quantity)

	for item_info in container_items:
		var item_id = item_info["item_id"]
		var item_quantity = item_info["quantity"]
		add_container_item(item_id, item_quantity)

	visible = true



remote func add_inventory_item(item_id: String, quantity: int):
	var new_inv_row = CONTAINER_ROW_SCENE.instance()
	new_inv_row.init(item_id, quantity)
	inventory_container.add_child(new_inv_row)
	new_inv_row.connect("on_item_move", self, "on_item_move_to_container")


remote func remove_inventory_item(item_id: String):
	var inv_row = inventory_container.get_node("Item%s" % item_id)
	inventory_container.remove_child(inv_row)
	inv_row.queue_free()


remote func update_inventory_item(item_id: String, quantity: int):
	var inv_row = inventory_container.get_node("Item%s" % item_id)
	inv_row.set_quantity(quantity)



remote func add_container_item(item_id: String, quantity: int):
	var new_cont_row = CONTAINER_ROW_SCENE.instance()
	new_cont_row.init(item_id, quantity)
	container_container.add_child(new_cont_row)
	new_cont_row.connect("on_item_move", self, "on_item_move_to_inventory")


remote func remove_container_item(item_id: String):
	var cont_row = container_container.get_node("Item%s" % item_id)
	container_container.remove_child(cont_row)
	cont_row.queue_free()


remote func update_container_item(item_id: String, quantity: int):
	var cont_row = container_container.get_node("Item%s" % item_id)
	cont_row.set_quantity(quantity)



func on_item_move_to_inventory(item_id: String, quantity: int):
	pass  # TODO


func on_item_move_to_container(item_id: String, quantity: int):
	pass  # TODO
