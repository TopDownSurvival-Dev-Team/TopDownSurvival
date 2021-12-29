extends Node

var network: NetworkedMultiplayerENet
var game_server_api: MultiplayerAPI
const HUB_ADDRESS = "gateway.topdownsurvival.tk"  # Same as gateway address
const HUB_PORT = 8002
const TOKEN_EXPIRE_TIME = 10
var cert = load("res://assets/certificates/TopDownSurvival-Gateway-Cert.crt")

var pending_tokens = {}
var used_tokens = {}

var connection_attempts = 0


func _process(_delta):
    if get_custom_multiplayer() == null:
        return
    if not custom_multiplayer.has_network_peer():
        return
    custom_multiplayer.poll()


func connect_to_hub():
    connection_attempts += 1

    # Create relevant variables
    network = NetworkedMultiplayerENet.new()
    game_server_api = MultiplayerAPI.new()

    # Connect signals
    network.connect("connection_succeeded", self, "_connection_successful")
    network.connect("connection_failed", self, "_connection_failed")
    network.connect("server_disconnected", self, "_hub_disconnected")

    # Setup DTLS encryption
    network.set_dtls_enabled(true)
    network.set_dtls_certificate(cert)

    # Setup custom MultiplayerAPI
    network.create_client(HUB_ADDRESS, HUB_PORT)
    set_custom_multiplayer(game_server_api)
    custom_multiplayer.set_root_node(self)
    custom_multiplayer.set_network_peer(network)


func _connection_successful():
    print("Successfully connected to Game Server Hub!")
    connection_attempts = 0


func _connection_failed():
    if connection_attempts >= 3:
        print("Unable to connect to Game Server Hub, exiting...")
        get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
    else:
        print("Failed to connect to Game Server Hub. Trying again...")
        connect_to_hub()


func _hub_disconnected():
    print("Disconnected from Game Server Hub. Trying to reconnect...")

    # Only try to reconnect if previous connection was successful
    if Network.server_started:
        connect_to_hub()


func verify_token(token: String) -> bool:
    if not token in pending_tokens:
        return false

    # Check whether the token has expired
    var time_diff = OS.get_unix_time() - int(token.right(64))
    if time_diff > TOKEN_EXPIRE_TIME:
        return false

    # Invalidate the token if it's valid
    used_tokens[token] = pending_tokens[token]
    pending_tokens.erase(token)

    return true


func get_user_info(token: String):  # Dictionary or null
    if token in used_tokens.keys():
        var info = used_tokens[token]
        used_tokens.erase(info)
        return info
    return null


remote func receive_verification_info(token: String, player_info: Dictionary):
    # Contains stuff like Firebase UID and player username
    pending_tokens[token] = player_info
    print("Received token: %s" % token)


remote func duplicate_connection():
    # FIXME
    print("Duplicate connection! Exiting...")
    get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
