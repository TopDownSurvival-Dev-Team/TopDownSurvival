extends Node

const DEFAULT_IP = "127.0.0.1"
const DEFAULT_PORT = 8000
const LOBBY_SCENE = "res://src/scenes/ui_scenes/Lobby.tscn"
const WORLD_SCENE = "res://src/scenes/game_scenes/World.tscn"

var network: NetworkedMultiplayerENet
var local_player_id = 0
var token: String
var token_verified = false

# "sync" keyword on variables allows the server to change the variable's value
# for a network peer using "rset" function
sync var players = {}


func _ready():
	var _error
	
	_error = get_tree().connect("network_peer_connected", self, "_player_connected")
	_error = get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	
	_error = get_tree().connect("connected_to_server", self, "_connection_successful")
	_error = get_tree().connect("connection_failed", self, "_connection_failed")
	
	_error = get_tree().connect("server_disconnected", self, "_server_disconnected")
	
	
func connect_to_server(address: String, port: int, _token: String):
	token = _token
	
	network = NetworkedMultiplayerENet.new()
	network.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_ZSTD)
	network.create_client(address, port)
	
	get_tree().set_network_peer(network)
	print("Connecting to game server")
	
	
func _player_connected(id):
	print("Player " + str(id) + " has connected")
	
	
func _player_disconnected(id):
	print("Player " + str(id) + " has disconnected")
	
	
func _connection_successful():
	print("Successfully connected to game server")
	rpc_id(1, "verify_token", token)
	
	
func _connection_failed():
	print("Failed to connect to server")
	get_tree().call_group("Lobby", "failed_to_connect_to_game")
	
	
func _server_disconnected():
	if token_verified:
		print("Disconnected from server")
		
		# Go back to lobby
		var lobby_scene = load(LOBBY_SCENE).instance()
		get_tree().get_root().add_child(lobby_scene)
		get_tree().call_group("Lobby", "disconnected_from_server")
		
		# Remove world scene
		var world_scene = get_tree().get_root().get_node("World")
		get_tree().get_root().remove_child(world_scene)
		world_scene.queue_free()
		
	else:
		print("Invalid auth token")
		get_tree().call_group("Lobby", "invalid_token")
	
	
remote func token_verified_successfully():
	print("Token verified")
	token_verified = true
	local_player_id = get_tree().get_network_unique_id()
	
	# Start game world
	print("Starting game")
	var _error = get_tree().change_scene(WORLD_SCENE)
	
	rpc_id(1, "request_game_data", token)
