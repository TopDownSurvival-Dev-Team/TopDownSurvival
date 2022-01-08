extends Node

var currently_open_menus = {}


func show_menu_s(player_id: int, crafting_level: int):
    var player_uid = Network.players[player_id]["firebase_uid"]
    var recipes = GameData.recipe_data[crafting_level]
    var inventory_data = Database.get_inventory(player_uid)

    rpc_id(player_id, "show_menu", inventory_data, recipes)
    currently_open_menus[player_id] = crafting_level


remote func close_menu_s():
    var player_id = get_tree().get_rpc_sender_id()
    currently_open_menus.erase(player_id)
