extends Node

var network = NetworkedMultiplayerENet.new()
var port = 8000
var max_players = 4


func _ready():
	network.connect("peer_connected", self, "_player_connected")
	network.connect("peer_disconnected", self, "_player_disconnected")
	start_server()
	
	
func start_server():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	print("Server started!")
	
	
func _player_connected(id):
	print("Player " + str(id) + " has connected")
	
	
func _player_disconnected(id):
	print("Player " + str(id) + " has disconnected")
