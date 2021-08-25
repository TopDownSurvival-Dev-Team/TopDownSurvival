extends StaticBody2D

var health = 100

onready var health_bar = $HealthBar
onready var health_bar_show_timer = $HealthBarShowTimer


func _ready():
	health_bar.visible = false
	
	
func request_damage(damage_amount: int):
	rpc_id(1, "damage_s", damage_amount)


remote func damage(damage_amount: int):
	# TODO: Add damage animation
	health -= damage_amount
	
	if health <= 0:
		rpc_id(1, "break_tree_s")
	
	health_bar.value = health
	health_bar.visible = true
	health_bar_show_timer.start()


remote func break_tree():
	get_parent().remove_child(self)
	queue_free()


func _on_HealthBarShowTimer_timeout():
	health_bar.visible = false
