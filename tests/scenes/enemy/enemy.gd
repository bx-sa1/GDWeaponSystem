extends CharacterController

var health = 100
var max_health  = 100
@onready var healthbar: ProgressBar = %HealthBar

func _ready() -> void:
	healthbar.max_value = max_health
	healthbar.value = health

func _process(delta: float) -> void:
	healthbar.value = health
	if health <= 0:
		queue_free()

func _physics_process(delta: float) -> void:
	move(delta, Vector2(0.0, -1.0))

func _on_weapon_hit(weapon: Weapon, hit: WeaponHit) -> void:
	health -= weapon.data.damage
