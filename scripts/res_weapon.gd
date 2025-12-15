class_name Weapon extends Resource

enum WeaponType { PROJECTILE, HITSCAN }
@export var name: String
@export var scene: PackedScene
@export var ammo_scene: PackedScene
@export var ammo_hit_decal: PackedScene

@export_category("Stats")
@export var type: WeaponType
@export var max_ammo_count: int
# How fast the ammunition moves, only realy useful for projectile weapons
@export var ammo_speed: float
# How many ammunitions to fire at once
@export var fire_ammount: int
# How far ammunitions can go
@export var fire_range: float
# How many times you can shoot per second
@export var fire_rate: float
@export var spread: float
@export var auto: bool
@export var damage: float
@export var reload_time: float

var ammo_count: int = max_ammo_count
var cooldown: bool = false
var t_cooldown: float
var reloading: bool = false
var t_reloading: float
var _exclude_ammos_from_cam_hit_test: Array[RID] = []

var scene_instance: Node3D

signal coolingdown(weapon: Weapon)
signal reloaded(weapon: Weapon)
signal fired(weapon: Weapon)
signal hit(weapon: Weapon, hit_pos: Vector3, hit_normal: Vector3, collider: Node)

func get_scene_instance() -> Node3D:
	if scene_instance == null:
		scene_instance = scene.instantiate()
	return scene_instance

func is_coolingdown() -> bool:
	return cooldown

func reload() -> void:
	if scene_instance.is_inside_tree():
		reloading = true

func should_reload() -> bool:
	return ammo_count == 0

func is_reloading() -> bool:
	return reloading

func fire(collision_mask: int, fire_from_center_of_screen: bool) -> void: # return how much is acctually fire
	if not scene_instance.is_inside_tree():
		return

	ammo_count -= fire_ammount
	cooldown = true
	var fire_ammount = fire_ammount - ammo_count if ammo_count < 0 else fire_ammount
	if ammo_count <= 0:
		ammo_count = 0
	else:
		fired.emit(self)


	var ray_origin: Vector3
	var ray_dir: Vector3
	if fire_from_center_of_screen:
		var camera = scene_instance.get_viewport().get_camera_3d()
		var viewport_size = scene_instance.get_viewport().get_size()
		ray_origin = camera.project_ray_origin(viewport_size/2)
		ray_dir = camera.project_ray_normal(viewport_size/2)
	else:
		ray_origin = scene_instance.global_position
		ray_dir = scene_instance.global_basis.z

	for i in fire_ammount:
		var spread_ray_dir = Quaternion.from_euler(Vector3(
			_calc_rand_spread_angle(spread),
			_calc_rand_spread_angle(spread),
			_calc_rand_spread_angle(spread))) * ray_dir

		var hit_point = _camera_hit_test(collision_mask, ray_origin, spread_ray_dir)
		if type == Weapon.WeaponType.HITSCAN:
			_fire_hitscan(collision_mask, hit_point)
		elif type == Weapon.WeaponType.PROJECTILE:
			_fire_projectile(collision_mask, hit_point)

func _camera_hit_test(collision_mask: int, ray_origin: Vector3, ray_dir: Vector3) -> Vector3:
	var ray_end = ray_origin+ray_dir*1000
	var params = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	params.exclude = _exclude_ammos_from_cam_hit_test
	params.collision_mask = collision_mask
	var intersect = scene_instance.get_world_3d().direct_space_state.intersect_ray(params)
	if intersect != {}:
		return intersect.position
	else:
		return ray_end


func _fire_hitscan(collision_mask: int, camera_collision_point: Vector3):
	var inst = scene_instance
	var fire_origin = inst.global_transform.origin
	var fire_dir = (camera_collision_point - fire_origin).normalized()
	var params = PhysicsRayQueryParameters3D.create(fire_origin, camera_collision_point+fire_dir*2)
	params.collision_mask = collision_mask
	var intersect = scene_instance.get_world_3d().direct_space_state.intersect_ray(params)
	if intersect != {}:
		hit.emit(self, intersect.position, intersect.normal, intersect.collider)


func _fire_projectile(collision_mask: int, camera_collision_point: Vector3):
	var ammo = ammo_scene.instantiate()
	if not ammo is Ammo:
		print("Ammo is not Ammo type")
		return

	var inst = scene_instance
	var fire_origin = inst.global_transform.origin
	var fire_dir = (camera_collision_point - fire_origin).normalized()

	scene_instance.owner.add_child(ammo)
	var ammo_rid = ammo.get_rid()
	ammo.from_weapon = self
	ammo.set_linear_velocity(fire_dir * ammo_speed)
	_exclude_ammos_from_cam_hit_test.push_back(ammo_rid)
	ammo.tree_exited.connect(_on_ammo_tree_exited.bind(ammo_rid))
	ammo.hit.connect(_on_ammo_hit)

func _calc_rand_spread_angle(spread: float) -> float:
	return randf_range(-deg_to_rad(spread), deg_to_rad(spread))

func _on_ammo_tree_exited(rid: RID):
	_exclude_ammos_from_cam_hit_test.erase(rid)

func _on_ammo_hit(ammo: Ammo, body: Node):
	hit.emit(self, ammo.global_position, body.global_basis.z, body) #TODO:check

func can_fire() -> bool:
	return cooldown == false and reloading == false

func update(delta: float) -> void:
	if should_reload():
		reload()
	if cooldown:
		t_cooldown += delta
		if t_cooldown >= 1.0/fire_rate:
			cooldown = false
			t_cooldown = 0
			coolingdown.emit(self)
	if reloading:
		t_reloading += delta
		if t_reloading >= reload_time:
			ammo_count = max_ammo_count
			reloading = false
			t_reloading = 0
			reloaded.emit(self)

func get_handle_marker() -> Marker3D:
	var marker = get_scene_instance().get_node("handle_marker")
	return marker
