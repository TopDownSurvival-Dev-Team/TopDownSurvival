extends Node

const DATA_PATH = "res://data"
var item_data: Dictionary


func _ready():
    # Read item data
    var file = File.new()
    var item_data_path = "%s/item_data.json" % DATA_PATH
    file.open(item_data_path, File.READ)
    item_data = parse_json(file.get_as_text())
    file.close()

    # Connect signals
    Network.connect("player_joined_game", self, "send_game_data")


func send_game_data(player_id: int):
    rpc_id(player_id, "send_item_data", item_data)
