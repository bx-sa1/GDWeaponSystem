class_name HitscanFireStrategy extends GunFireStrategy

func fire(weapon: Weapon, origin: Vector3, dir: Vector3, collision_mask: int) -> WeaponHit:
	var cam_hit = _camera_hit_test(weapon, origin, dir, collision_mask)
	var weapon_fire_point = weapon.get_fire_point()
	if not weapon_fire_point:
		return null

	var ray_start = weapon_fire_point.global_position
	var ray_dir = (cam_hit - ray_start).normalized()
	var ray_end = cam_hit+ray_dir*2
	var params = PhysicsRayQueryParameters3D.create(ray_start, ray_end, collision_mask)
	var hit = weapon.get_world_3d().direct_space_state.intersect_ray(params)
	if hit:
		var weapon_hit = WeaponHit.new()
		weapon_hit.position = hit.position
		weapon_hit.normal = hit.normal
		weapon_hit.collider = hit.collider
		return weapon_hit
	else:
		return null
