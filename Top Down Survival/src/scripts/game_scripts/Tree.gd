extends StaticBody2D

var health = 100

onready var collision_shape = $CollisionShape2D
onready var health_bar = $HealthBar
onready var health_bar_show_timer = $HealthBarShowTimer

onready var damage_sfx = $DamageSFX
onready var break_sfx = $BreakSFX


func _ready():
    health_bar.visible = false


func request_damage(damage_amount: int):
    if health > 0:
        rpc_id(1, "damage_s", damage_amount)


remote func damage(damage_amount: int):
    # TODO: Add damage animation
    health -= damage_amount

    health_bar.value = health
    health_bar.visible = true
    health_bar_show_timer.start()

    # To not make it sound monotonous
    damage_sfx.pitch_scale = 1 + rand_range(-0.125, 0.125)
    damage_sfx.play()


func destroy():
    visible = false
    collision_shape.set_disabled(true)
    damage_sfx.stop()
    break_sfx.play()


func _on_HealthBarShowTimer_timeout():
    health_bar.visible = false


func _on_BreakSFX_finished():
    if health < 0:
        get_parent().remove_child(self)
        queue_free()
