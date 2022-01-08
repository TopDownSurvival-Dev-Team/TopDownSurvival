extends Node


func show_menu_s(player_id: int, crafting_level: int):
    var player_uid = Network.players[player_id]["firebase_uid"]
    var recipes = GameData.recipe_data[crafting_level]
    var inventory_data = Database.get_inventory(player_uid)
    rpc_id(player_id, "show_menu", inventory_data, recipes)
