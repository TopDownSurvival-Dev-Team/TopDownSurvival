extends Control

const JOIN_REQUEST_SCENE = preload("res://src/scenes/ui_scenes/templates/JoinRequest.tscn")


func _ready():
	# Remove preview nodes
	for node in get_children():
		remove_child(node)
		node.queue_free()

	GodotcordActivityManager.connect(
		"activity_join_request", self, "new_join_request"
	)


func new_join_request(username: String, user_id: int):
	print("New join request from %s" % username)
	var join_request = JOIN_REQUEST_SCENE.instance()
	join_request.init(username, user_id)
	add_child(join_request)
