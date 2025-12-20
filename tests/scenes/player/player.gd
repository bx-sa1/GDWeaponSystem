extends CharacterController

@onready var weapon_controller: WeaponController = %WeaponController


func _ready() -> void:
	get_component(JumpComponent).active_p = func(): return is_on_floor() and Input.is_action_just_pressed("jump")

func _physics_process(delta: float) -> void:

	if weapon_controller.is_fire_pressed("fire"):
		var camera = get_viewport().get_camera_3d()
		var viewport_size = get_viewport().get_size()
		weapon_controller.fire(camera.project_ray_origin(viewport_size/2), camera.project_ray_normal(viewport_size/2))
	if Input.is_action_just_pressed("weapon_up"):
		weapon_controller.change_weapon(weapon_controller.current_weapon_id + 1)
	elif Input.is_action_just_pressed("weapon_down"):
		weapon_controller.change_weapon(weapon_controller.current_weapon_id - 1)

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	move(delta, input_dir)

func _on_weapon_hit_explosion_impulse(weapon: Weapon, impulse: Vector3):
	velocity += impulse
