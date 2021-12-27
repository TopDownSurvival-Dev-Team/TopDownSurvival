extends Node

const CLIENT_ID = 897572305356603402

var connected: bool


func _ready():
    connected = Godotcord.init(CLIENT_ID, Godotcord.CreateFlags_NO_REQUIRE_DISCORD) != ERR_CANT_CONNECT


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

    else:
        print_debug("Trying to interact with Discord without connecting!")


func set_activity_game(server_address: String, username: String, current_players: int, max_players: int):
    if connected:
        var activity = GodotcordActivity.new()
        activity.state = "Playing on %s" % server_address
        activity.details = "Logged in as %s" % username
        activity.start = Network.game_start_time
        activity.large_image = "playing"
        activity.large_text = "In Game"
        activity.party_id = server_address
        activity.party_current = current_players
        activity.party_max = max_players
        activity.join_secret = "bro idk what this is supposed to be"
        GodotcordActivityManager.set_activity(activity)

    else:
        print_debug("Trying to interact with Discord without connecting!")
