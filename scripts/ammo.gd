class_name Ammo extends RigidBody3D

signal hit(body: Node)

var from_weapon: Weapon
var ttl: Timer

func _ready() -> void:
	add_child(ttl)
	ttl.start()
	ttl.timeout.connect(_on_timer_timeout)
	body_entered.connect(_on_ammo_body_entered)

func _on_ammo_body_entered(body: Node):
	hit.emit(self, body)
	queue_free()

func _on_timer_timeout() -> void:
	queue_free()
