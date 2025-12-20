class_name Weapon extends Node3D

@export var data: WeaponData
@export var fire_point_node_group_name = "fire_point"
@export var owner_on_weapon_reload_method_name = "_on_weapon_reload"
@export var owner_on_weapon_fire_method_name = "_on_weapon_fire"
@export var collider_on_weapon_hit_take_damage_method_name = "_on_weapon_hit_take_damage"

func _ready() -> void:
	data.init()

func reload() -> void:
	print("reload")
	data.reload(func():
		if owner.has_method(owner_on_weapon_reload_method_name):
			await owner.get(owner_on_weapon_reload_method_name).call()
		else:
			await get_tree().create_timer(1).timeout)

func fire(origin: Vector3, dir: Vector3, collision_mask: int) -> void:
	if data.should_reload():
		reload()
		return
	if not data.can_fire():
		return

	if not data.fire_strategy:
		return

	var ammount = data.fire()
	for i in ammount:
		var spread_dir = data.get_spread_dir(dir)
		data.fire_strategy.fire(self, origin, spread_dir, collision_mask)
		for post in data.post_fire_strategies:
			post.postfire(self)

	if owner.has_method(owner_on_weapon_fire_method_name):
		owner.get(owner_on_weapon_fire_method_name).call()


func _process(delta: float) -> void:
	data.update_cooldown(delta)

func get_fire_point() -> Node3D:
	for child in get_children():
		if child.is_in_group(fire_point_node_group_name):
			return child
	print(self.name, " does not have a node in group \"", fire_point_node_group_name, "\"")
	return null

func add_decal_to_world(position: Vector3, normal: Vector3):
	var decal: Node3D = data.hit_decal.instantiate()
	get_tree().get_root().add_child(decal)

	decal.global_position = position + normal * 0.01
	var decal_rotation = Quaternion(decal.global_basis.z, normal)
	decal.quaternion *= decal_rotation

func collider_call_take_damage(damage: float, collider: Node, position: Vector3 = Vector3.INF, normal: Vector3 = Vector3.ZERO) -> void:
	if collider.has_method(collider_on_weapon_hit_take_damage_method_name):
		collider.call(collider_on_weapon_hit_take_damage_method_name, self, damage, collider, position, normal)
