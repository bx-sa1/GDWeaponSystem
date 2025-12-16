@tool
class_name FpsViewmodel extends Node3D

@export_tool_button("Debug Viewmodel") var debug_viewmodel = func():
	if debug_weapon_instance != null:
		add_child(debug_weapon_instance)
		debug_weapon_instance.owner = get_tree().edited_scene_root

@export_tool_button("Remove Debug Viewmodel") var remove_debug_viewmodel = func():
	if debug_weapon_instance != null:
		remove_child(debug_weapon_instance)

@export var weapon_controller: WeaponController

var debug_weapon_instance: Weapon = null

func _ready() -> void:
	if Engine.is_editor_hint():
		if len(weapon_controller.weapon_list) != 0:
			debug_weapon_instance = weapon_controller.weapon_list[0].instantiate()
		else:
			print("FpsViewmodel: No weapons in WeaponController")
