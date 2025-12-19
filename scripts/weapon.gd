class_name Weapon extends Node3D

@export var data: WeaponData
@export var fire_point_node_group_name = "fire_point"
@export var owner_on_weapon_reload_method_name = "_on_weapon_reload"
@export var owner_on_weapon_fire_method_name = "_on_weapon_fire"
@export var collider_on_weapon_hit_method_name = "_on_weapon_hit"

func _ready() -> void:
	data.init()

func reload() -> void:
	print("reload")
	data.reload(func():
		if owner.has_method(owner_on_weapon_reload_method_name):
			await owner.get(owner_on_weapon_reload_method_name).call()
		else:
			await get_tree().create_timer(1).timeout)

func fire(origin: Vector3, dir: Vector3, collision_mask: int) -> Array[WeaponHit]:
	if data.should_reload():
		reload()
		return [null]
	if not data.can_fire():
		return [null]

	if not data.fire_strategy:
		return [null]

	var ammount = data.fire()
	var hits: Array[WeaponHit] = []
	for i in ammount:
		var spread_dir = data.get_spread_dir(dir)
		var hit = await data.fire_strategy.fire(self, origin, spread_dir, collision_mask)
		if hit:
			hits.push_back(hit)
			for post in data.post_fire_strategies:
				post.postfire(self, hit)
			if hit.collider.has_method(collider_on_weapon_hit_method_name):
				hit.collider.get(collider_on_weapon_hit_method_name).call(self, hit)

	if owner.has_method(owner_on_weapon_fire_method_name):
		owner.get(owner_on_weapon_fire_method_name).call()

	return hits

func _process(delta: float) -> void:
	data.update_cooldown(delta)

func get_fire_point() -> Node3D:
	for child in get_children():
		if child.is_in_group(fire_point_node_group_name):
			return child
	print(self.name, " does not have a node in group \"", fire_point_node_group_name, "\"")
	return null
