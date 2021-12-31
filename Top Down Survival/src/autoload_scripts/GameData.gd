extends Node

const VERSION_FILE = "res://version.txt"

var client_version: String
var item_data: Dictionary
var player_reach: int


func _ready():
    var f = File.new()
    f.open(VERSION_FILE, File.READ)
    client_version = f.get_line()
    f.close()


remote func send_game_data(_item_data: Dictionary, _player_reach: int):
    item_data = _item_data
    player_reach = _player_reach
