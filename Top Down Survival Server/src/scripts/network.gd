extends Node

var network = NetworkedMultiplayerENet.new()
var port = 8000
var max_players = 4

var players = {}
var ready_players = []

var server_started = false


func _ready():
	# Compression Mode
	network.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_ZSTD)
	
	network.connect("peer_connected", self, "_player_connected")
	network.connect("peer_disconnected", self, "_player_disconnected")
	
	
func start_server():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	server_started = true
	print("Server started!")
	
	
func _player_connected(id):
	print("Player " + str(id) + " has connected")
	
	
func _player_disconnected(id):
	print("Player " + str(id) + " has disconnected")
	
	if id in players.keys():
		get_tree().call_group("World", "despawn_player_s", id)
		get_tree().call_group("Chat Box", "send_leave_message", players[id]["username"])
		
		players.erase(id)
		rset("players", players)
		
		
remote func verify_token(token: String):
	var sender_id = get_tree().get_rpc_sender_id()
	
	if GameServerHub.verify_token(token):
		rpc_id(sender_id, "token_verified_successfully")
	else:
		# Kick out the player if they provide an invalid token
		network.disconnect_peer(sender_id)
	
	
remote func request_game_data(token: String):
	var id = get_tree().get_rpc_sender_id()
	var player_info = GameServerHub.get_user_info(token)
	players[id] = player_info
	rset("players", players)
	
	# Send game data to new player
	GameData.send_game_data(id)
	
	# Send existing players to new player
	get_tree().call_group("World", "send_world_to", id)
	get_tree().call_group("Chat Box", "send_join_message", players[id]["username"])
	
	# Spawn the new player on all clients
	get_tree().call_group("World", "spawn_player_s", id)
