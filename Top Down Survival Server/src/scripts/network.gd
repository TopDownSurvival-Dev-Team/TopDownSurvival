extends Node

var network = NetworkedMultiplayerENet.new()
var port = 8000
var max_players = 4

var players = {}
var ready_players = []


func _ready():
	# Compression Mode
	network.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_ZSTD)
	
	network.connect("peer_connected", self, "_player_connected")
	network.connect("peer_disconnected", self, "_player_disconnected")
	
	
func start_server():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	print("Server started!")
	
	
func _player_connected(id):
	print("Player " + str(id) + " has connected")
	
	
func _player_disconnected(id):
	print("Player " + str(id) + " has disconnected")
	
	if id in players.keys():
		get_tree().call_group("World", "despawn_player_s", id)
		get_tree().call_group("Chat Box", "send_leave_message", players[id]["player_name"])
		
		players.erase(id)
		rset("players", players)
	
	
remote func request_game_data():
	var id = get_tree().get_rpc_sender_id()
	# TODO: get player data from information sent by gateway
	players[id] = {"player_name": "gonna change soon this soon"}
	rset("players", players)
	
	# Send game data to new player
	GameData.send_game_data(id)
	
	# Send existing players to new player
	get_tree().call_group("World", "send_world_to", id)
	get_tree().call_group("Chat Box", "send_join_message", players[id]["player_name"])
	
	# Spawn the new player on all clients
	get_tree().call_group("World", "spawn_player_s", id)
