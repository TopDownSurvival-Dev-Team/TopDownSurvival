extends Node

var network = NetworkedMultiplayerENet.new()
var port = 8000
var max_players = 4

var players = {}
var ready_players = []


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
	
	
remote func send_player_info(id, player_data):
	players[id] = player_data
	rset("players", players)
	rpc("update_waiting_room")
	
	
remote func ready_player(id):
	# Ignore if player has already readied up
	if id in ready_players:
		return
		
	ready_players.append(id)
	var ready_count = len(ready_players)
	
	if ready_count != 0 and ready_count == len(players):
		print("All players are ready")
		rpc("start_game")
		
		var world = preload("res://src/scenes/World.tscn").instance()
		get_tree().get_root().add_child(world)
