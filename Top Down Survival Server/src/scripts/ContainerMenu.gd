extends Node

var currently_open_menus = {}

onready var inventory = get_parent().get_node("Inventory")


func show_menu_s(player_id: int, container_name: String, container_position: Vector2):
	if not player_id in currently_open_menus:
		var container_id = Database.get_container_id(container_position)

		if container_id:
			var player_uid = Network.players[player_id]["firebase_uid"]
			var inventory_data = Database.get_inventory(player_uid)
			var container_items = Database.get_container_items(container_id)

			rpc_id(player_id, "show_menu", container_name, inventory_data, container_items)
			currently_open_menus[player_id] = container_id


remote func close_menu_s():
	var player_id = get_tree().get_rpc_sender_id()
	currently_open_menus.erase(player_id)


remote func move_item_to_inventory_s(item_id: String, quantity: int):
	var player_id = get_tree().get_rpc_sender_id()
	var player_uid = Network.players[player_id]["firebase_uid"]
	var container_id = currently_open_menus.get(player_id)

	if not container_id:
		return

	var container_quantity = Database.get_container_item_quantity(container_id, item_id)

	if not container_quantity or container_quantity < quantity:
		return

	var new_container_quantity = container_quantity - quantity

	if new_container_quantity:
		Database.update_container_item(container_id, item_id, new_container_quantity)
		rpc_id(player_id, "update_container_item", item_id, new_container_quantity)
	else:
		Database.remove_container_item(container_id, item_id)
		rpc_id(player_id, "remove_container_item", item_id)

	add_inventory_item_s(player_id, item_id, quantity)


remote func move_item_to_container_s(item_id: String, quantity: int):
	var player_id = get_tree().get_rpc_sender_id()
	var player_uid = Network.players[player_id]["firebase_uid"]
	var container_id = currently_open_menus.get(player_id)

	if not container_id:
		return

	var player_quantity = Database.get_item_quantity(player_uid, item_id)

	if not player_quantity or player_quantity < quantity:
		return

	var container_quantity = Database.get_container_item_quantity(container_id, item_id)

	if container_quantity:
		var new_container_quantity = quantity + container_quantity
		Database.update_container_item(container_id, item_id, new_container_quantity)
		rpc_id(player_id, "update_container_item", item_id, new_container_quantity)
	else:
		Database.add_container_item(container_id, item_id, quantity)
		rpc_id(player_id, "add_container_item", item_id, quantity)

	remove_inventory_item_s(player_id, item_id, quantity)


func add_inventory_item_s(player_id: int, item_id: String, quantity: int):
	var player_uid = Network.players[player_id]["firebase_uid"]
	var current_quantity = Database.get_item_quantity(player_uid, item_id)

	if current_quantity:
		current_quantity += quantity
		rpc_id(player_id, "update_inventory_item", item_id, current_quantity)
	else:
		rpc_id(player_id, "add_inventory_item", item_id, quantity)

	inventory.add_item_s(player_id, item_id, quantity)


func remove_inventory_item_s(player_id: int, item_id: String, quantity: int):
	var player_uid = Network.players[player_id]["firebase_uid"]
	var current_quantity = Database.get_item_quantity(player_uid, item_id)

	if current_quantity:
		current_quantity -= quantity

		if current_quantity > 0:
			rpc_id(player_id, "update_inventory_item", item_id, current_quantity)
		else:
			rpc_id(player_id, "remove_inventory_item", item_id)

	inventory.remove_item_s(player_id, item_id, quantity)
