extends Control

var username: String
var user_id: int

onready var label = $H/Label


func init(_username: String, _user_id: int):
	username = _username
	user_id = _user_id
	name = str(_user_id)


func _ready():
	label.set_text("%s wants to join your game" % username)


func _on_Accept_pressed():
	GodotcordActivityManager.send_request_reply(user_id, GodotcordActivity.YES)
	get_parent().remove_child(self)
	queue_free()


func _on_Decline_pressed():
	GodotcordActivityManager.send_request_reply(user_id, GodotcordActivity.NO)
	get_parent().remove_child(self)
	queue_free()
