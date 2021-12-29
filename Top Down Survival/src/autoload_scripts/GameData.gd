extends Node

const VERSION_FILE = "res://version.txt"

var item_data: Dictionary
var client_version: String


func _ready():
    var f = File.new()
    f.open(VERSION_FILE, File.READ)
    client_version = f.get_line()
    f.close()


remote func send_item_data(data):
    # Receive the item data from server
    item_data = data
