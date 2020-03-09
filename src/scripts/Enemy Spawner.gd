extends Node2D

const AVG_TIME_TO_SPAWN = 3
const SPAWN_TIME_VARIANCE = 0.2

var cur_time_to_spawn = 3
var timer = 0

onready var enemy_scene = preload("res://Enemy.tscn")

func ready():
	cur_time_to_spawn = AVG_TIME_TO_SPAWN + SPAWN_TIME_VARIANCE * (randf() * 2 - 1)

func _process(delta):
	timer += delta

	if timer > cur_time_to_spawn:
		timer = 0
		cur_time_to_spawn = AVG_TIME_TO_SPAWN + SPAWN_TIME_VARIANCE * (randf() * 2 - 1)
		spawn_enemy()

func spawn_enemy():
	var enemy = enemy_scene.instance()
	enemy.position = Vector2(0, 0)
	call_deferred("add_child", enemy)