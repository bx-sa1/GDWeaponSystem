extends CharacterController

var health = 100
var max_health  = 100
@onready var healthbar: ProgressBar = %HealthBar
var ext_impulse: Vector3

func _ready() -> void:
	healthbar.max_value = max_health
	healthbar.value = health

func _process(delta: float) -> void:
	healthbar.value = health
	if health <= 0:
		queue_free()

func _physics_process(delta: float) -> void:
	move(delta, Vector2(0.0, -1.0))

func _on_weapon_hit_take_damage(weapon: Weapon, damage: float, col: Node, pos: Vector3, norm: Vector3) -> void:
	health -= weapon.data.damage

func _on_weapon_hit_explosion_impulse(weapon: Weapon, impulse: Vector3) -> void:
	velocity += impulse
	print(impulse)
