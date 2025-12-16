class_name WeaponFireStrategy extends Resource

class WeaponHit:
	var position: Vector3
	var normal: Vector3
	var collider: Node

func fire(weapon: Weapon, origin: Vector3, dir: Vector3, collision_mask: int) -> WeaponHit:
	return null
