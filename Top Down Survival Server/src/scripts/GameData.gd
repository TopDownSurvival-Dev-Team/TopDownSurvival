extends Node

const DATA_PATH = "res://data"
const ITEM_DATA_PATH = "%s/item_data.json" % DATA_PATH
const RECIPE_DATA_PATH = "%s/recipe_data" % DATA_PATH
const PLAYER_REACH = 128

var item_data: Dictionary
var recipe_data: Array


func _ready():
	var dir = Directory.new()
	var file = File.new()

	# Item data
	file.open(ITEM_DATA_PATH, File.READ)
	item_data = parse_json(file.get_as_text())
	file.close()

	# Recipe data
	dir.open(RECIPE_DATA_PATH)
	dir.list_dir_begin(true, true)
	var file_name = dir.get_next()

	while file_name != "":
		if not dir.current_is_dir():
			file.open("%s/%s" % [RECIPE_DATA_PATH, file_name], File.READ)

			var recipe_level = file_name.replace("level_", "").replace(".json", "").to_int()
			recipe_data.resize(max(len(recipe_data), recipe_level + 1))
			var recipes = parse_json(file.get_as_text())
			recipe_data[recipe_level] = recipes

			file.close()

		file_name = dir.get_next()

	dir.list_dir_end()

	# Connect signals
	Network.connect("player_joined_game", self, "send_game_data_s")


func send_game_data_s(player_id: int):
	rpc_id(player_id, "send_game_data", item_data, recipe_data, PLAYER_REACH)
