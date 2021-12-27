extends Node

var item_data: Dictionary


remote func send_item_data(data):
    # Receive the item data from server
    item_data = data
