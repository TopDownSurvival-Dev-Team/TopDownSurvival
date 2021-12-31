extends Node

signal player_joined_game(player_id)
signal player_left_game(player_id)

var network = NetworkedMultiplayerENet.new()
var port = 8000
var max_players = 10

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


func _player_connected(id: int):
    print("Player " + str(id) + " has connected")


func _player_disconnected(id: int):
    print("Player " + str(id) + " has disconnected")

    if id in players.keys():
        emit_signal("player_left_game", id)
        players.erase(id)
        rset("players", players)


func get_peer_count() -> int:
    return len(players)


remote func verify_token(token: String):
    var id = get_tree().get_rpc_sender_id()

    if GameServerHub.verify_token(token):
        rpc_id(id, "token_verified_successfully")
    else:
        print("Kicking player %s because their token was invalid" % id)
        network.disconnect_peer(id)


remote func request_game_data(token: String):
    var id = get_tree().get_rpc_sender_id()
    var player_info = GameServerHub.get_user_info(token)

    if player_info:
        players[id] = player_info
        rset("players", players)
        rpc("update_discord_rpc", get_peer_count(), max_players)
        emit_signal("player_joined_game", id)

    else:
        print("Kicking player %s because they did not verify their token" % id)
        network.disconnect_peer(id)
