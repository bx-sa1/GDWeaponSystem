class_name EnemySpawner extends Node3D

const enemy = preload("res://enemy.tscn")

var timer := Timer.new()

func _ready() -> void:
	timer.autostart = true
	timer.wait_time = randf_range(0.0, 20.0)
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

func _on_timer_timeout() -> void:
	add_child(enemy.instantiate())
	timer.wait_time = randf_range(0.0, 20.0)
