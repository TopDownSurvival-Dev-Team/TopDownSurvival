extends Node

const CLIENT_ID = 897572305356603402

var connected: bool


func _ready():
    connected = Godotcord.init(CLIENT_ID, Godotcord.CreateFlags_NO_REQUIRE_DISCORD) != ERR_CANT_CONNECT
    print("Connected to Discord Client: %s" % connected)


func _process(_delta):
    if connected:
        Godotcord.run_callbacks()


func set_activity_lobby():
    if connected:
        var activity = GodotcordActivity.new()
        activity.state = "Lobby"
        activity.details = "Deciding which server to join..."
        activity.start = OS.get_unix_time()
        activity.large_image = "main"
        activity.large_text = "Idle in Lobby"
        GodotcordActivityManager.set_activity(activity)


func set_activity_game(server_address: String, server_port: int, username: String, current_players: int, max_players: int):
    var singleplayer = server_address in ["127.0.0.1", "localhost"]

    if connected:
        var activity = GodotcordActivity.new()
        activity.state = "Playing v%s" % GameData.client_version
        activity.details = "Logged in as %s" % username
        activity.start = Network.game_start_time
        activity.large_image = "playing"
        activity.large_text = "Playing v%s" % GameData.client_version
        activity.party_id = "" if singleplayer else server_address
        activity.party_current = -1 if singleplayer else current_players
        activity.party_max = -1 if singleplayer else max_players
        activity.join_secret = "" if singleplayer else "%s:%s:%s" % [server_address, server_port, GameData.client_version]
        GodotcordActivityManager.set_activity(activity)
