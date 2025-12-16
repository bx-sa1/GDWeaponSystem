class_name Weapon extends Node3D

@export var data: WeaponData

func reload() -> void:
	data.reloading = true
	if owner.has_method("_on_weapon_reload"):
		owner._on_weapon_reload()
	else:
		await get_tree().create_timer(1).timeout
	data.reloading = false

func fire(origin: Vector3, dir: Vector3, collision_mask: int) -> Array[WeaponFireStrategy.WeaponHit]:
	if data.should_reload():
		reload()
		return [null]
	if not data.can_fire():
		return [null]

	var ammount = data.fire()
	var hits: Array[WeaponFireStrategy.WeaponHit] = []
	for i in ammount:
		var spread_dir = data.get_spread_dir(dir)
		var hit = data.fire_strategy.fire(self, origin, spread_dir, collision_mask)
		if hit:
			hits.push_back(hit)
	if owner.has_method("_on_weapon_fire"):
		owner._on_weapon_fire()
	return hits

func _process(delta: float) -> void:
	data.update_cooldown(delta)
