extends Control

@export var player: Node3D

@onready var ammo_value: Label = %AmmoValue
@onready var ammo_value_format: String = ammo_value.text
@onready var reloading: Label = %Reloading
@onready var reloading_format: String = reloading.text
@onready var coolingdown: Label = %Coolingdown
@onready var coolingdown_format: String = coolingdown.text

func _process(delta: float) -> void:
	var weapon = player.weapon_controller.get_current_weapon()

	ammo_value.text = ammo_value_format % [weapon.data.ammo_count, weapon.data.max_ammo_count]
	reloading.text = reloading_format % [weapon.data.reloading]
	coolingdown.text = coolingdown_format % [weapon.data.cooldown]
