extends Node

var currently_open_menus = {}

onready var inventory = get_parent().get_node("Inventory")


func show_menu_s(player_id: int, crafting_level: int):
	if not player_id in currently_open_menus:
		var player_uid = Network.players[player_id]["firebase_uid"]
		var inventory_data = Database.get_inventory(player_uid)
		var recipes = GameData.recipe_data[crafting_level]

		rpc_id(player_id, "show_menu", inventory_data, recipes)
		currently_open_menus[player_id] = crafting_level


remote func close_menu_s():
	var player_id = get_tree().get_rpc_sender_id()
	currently_open_menus.erase(player_id)


remote func craft_item_s(item_id: String):
	var player_id = get_tree().get_rpc_sender_id()
	var player_uid = Network.players[player_id]["firebase_uid"]
	var crafting_level = currently_open_menus.get(player_id)

	if crafting_level == null or not item_id in GameData.recipe_data[crafting_level]:
		return

	var required_ingredients = GameData.recipe_data[crafting_level][item_id]
	var has_ingredients = true

	for ingredient in required_ingredients:
		var required_quantity = required_ingredients[ingredient]
		var current_quantity = Database.get_item_quantity(player_uid, ingredient)
		has_ingredients = (has_ingredients and current_quantity >= required_quantity)

		if not has_ingredients:
			return

	# Removed ingredient items from inventory
	for ingredient in required_ingredients:
		var required_quantity = required_ingredients[ingredient]
		remove_item_s(player_id, ingredient, required_quantity)

	# Add crafted item to inventory
	add_item_s(player_id, item_id, 1)


func add_item_s(player_id: int, item_id: String, quantity: int):
	rpc_id(player_id, "add_inventory_item", item_id, quantity)
	inventory.add_item_s(player_id, item_id, quantity)


func remove_item_s(player_id: int, item_id: String, quantity: int):
	var player_uid = Network.players[player_id]["firebase_uid"]
	var current_quantity = Database.get_item_quantity(player_uid, item_id)

	if current_quantity:
		current_quantity -= quantity

		if current_quantity > 0:
			rpc_id(player_id, "update_inventory_item", item_id, current_quantity)
		else:
			rpc_id(player_id, "remove_inventory_item", item_id)

	inventory.remove_item_s(player_id, item_id, quantity)
