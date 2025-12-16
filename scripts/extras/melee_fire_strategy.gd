class_name MeleeFireStrategy extends WeaponFireStrategy

@export var melee_range = 2

func fire(weapon: Weapon, origin: Vector3, dir: Vector3, collision_mask: int) -> WeaponHit:
	var params = PhysicsRayQueryParameters3D.create(origin, origin + dir * melee_range, collision_mask)
	var hit = weapon.get_world_3d().direct_space_state.intersect_ray(params)
	if hit:
		var weapon_hit = WeaponHit.new()
		weapon_hit.position = hit.position
		weapon_hit.normal = hit.normal
		weapon_hit.collider = hit.collider
		return weapon_hit
	else:
		return null
