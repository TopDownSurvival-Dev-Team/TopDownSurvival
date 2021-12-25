extends Node

var item_data: Dictionary
var player_reach: int


remote func send_game_data(_item_data: Dictionary, _player_reach: int):
    item_data = _item_data
    player_reach = _player_reach
