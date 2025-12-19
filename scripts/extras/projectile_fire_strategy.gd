class_name ProjectileFireStrategy extends GunFireStrategy

@export var projectile: PackedScene
@export var projectile_speed: float

var _projectile_body_entered_result: WeaponHit = null
signal _projectile_body_entered_handled

func fire(weapon: Weapon, origin: Vector3, dir: Vector3, collision_mask: int) -> WeaponHit:
	if not projectile:
		return null


	var p = projectile.instantiate()
	if not p is RigidBody3D:
		print("ProjectileFireStrategy: projectile is not a rigidbody3d")
		return null

	var new_collision_mask = collision_mask & ~p.collision_layer
	var init_hit = _initial_hit_test(weapon, origin, dir, new_collision_mask)

	var from = weapon.get_fire_point().global_position
	var p_dir = (init_hit - from).normalized()

	p.position = from
	p.linear_velocity = p_dir * projectile_speed
	p.body_entered.connect(_on_projectile_hit.bind(projectile, new_collision_mask))
	p.look_at(from + p_dir)

	weapon.get_tree().get_root().add_child(p)
	await p.body_entered
	var res = await _projectile_body_entered_result

	return res

func _on_projectile_hit(body: Node, projectile: RigidBody3D, collision_mask: int):
	var params = PhysicsRayQueryParameters3D.create(projectile.global_position, body.global_position, collision_mask)
	var ray_hit = projectile.get_world_3d().direct_space_state.intersect_ray(params)
	if ray_hit:
		var hit = WeaponHit.new()
		hit.position = ray_hit.position
		hit.normal = ray_hit.normal
		hit.collider = body
		_projectile_body_entered_result = hit
	_projectile_body_entered_handled.emit()
	print("hit")
