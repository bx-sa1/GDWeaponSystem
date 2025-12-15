class_name WeaponController extends Node3D

@export_category("Key Actions")
@export var weapon_up_action: String = "weapon_up"
@export var weapon_down_action: String = "weapon_down"
@export var fire_action: String = "fire"
@export_category("Settings")
@export_flags_3d_physics var ray_collision_mask = 1
@export var parent_node: Node
@export var weapon_list: Array[Weapon] = []
@export var fire_from_center_of_screen = false

var current_weapon_id: int = -1

signal hit(weapon: Weapon, hit_pos: Vector3, hit_normal: Vector3, collider: Node)
signal weapon_changed(old_weapon: Weapon, new_weapon: Weapon)

func _ready() -> void:
	for weapon in weapon_list:
		weapon.hit.connect(_on_weapon_hit)
	change_weapon(0)

func _process(delta: float) -> void:
	weapon_list[current_weapon_id].update(delta)

func is_weapon_up_pressed() -> bool:
	return Input.is_action_just_pressed(weapon_up_action)

func is_weapon_down_pressed() -> bool:
	return Input.is_action_just_pressed(weapon_down_action)

func is_fire_pressed() -> bool:
	if weapon_list[current_weapon_id].auto:
		return Input.is_action_just_pressed(fire_action)
	else:
		return Input.is_action_pressed(fire_action)

func change_weapon(new_id: int) -> void:
	if new_id < 0:
		new_id = len(weapon_list) - 1
	elif new_id >= len(weapon_list):
		new_id = 0

	var current_weapon = weapon_list[current_weapon_id] if current_weapon_id != -1 else null
	var new_weapon = weapon_list[new_id]
	weapon_changed.emit(current_weapon, new_weapon)

	if current_weapon != null:
		parent_node.remove_child(current_weapon.get_scene_instance())

	parent_node.add_child(new_weapon.get_scene_instance())
	current_weapon_id = new_id

func fire() -> void:
	var weapon = get_current_weapon()
	if weapon.should_reload():
		weapon.reload()
	if not weapon.can_fire():
		return

	weapon.fire(ray_collision_mask, fire_from_center_of_screen)

func get_current_weapon() -> Weapon:
	return weapon_list[current_weapon_id]

func _add_decal_to_world(weapon: Weapon, hitpos: Vector3, hitnormal: Vector3):
	var decal: Node3D = weapon.ammo_hit_decal.instantiate()
	owner.add_child(decal)

	decal.global_position = hitpos + hitnormal * 0.01
	var decal_rotation = Quaternion(decal.global_basis.z, hitnormal)
	decal.quaternion *= decal_rotation

func _on_weapon_hit(weapon: Weapon, hit_pos: Vector3, hit_normal: Vector3, collider: Node) -> void:
	_add_decal_to_world(weapon, hit_pos, hit_normal)
	hit.emit(weapon, hit_pos, hit_normal, collider)
