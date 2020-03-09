extends KinematicBody2D

const GRAVITY = 400
const SPEED = 10
const UP = Vector2(0, -1)
const DEATH_HEIGHT = 300
const JUMP_POWER = 100

var vel = Vector2(0, 0)
var facing = 0

onready var player = get_tree().get_nodes_in_group("player")[0]
onready var sprite = $AnimatedSprite
onready var audio_player = $AudioStreamPlayer

func _enter_tree():
	player = get_tree().get_nodes_in_group("player")[0]

func kill():
	queue_free()

func _process(delta):
	if position.y > 300:
		queue_free()
	
	if is_on_floor():
		sprite.frame = 0
		audio_player.play()
		vel.y -= JUMP_POWER
		facing = sign((player.position - get_global_position()).x)
	
	vel.x = facing * SPEED
	
	vel.y += GRAVITY * delta
	
	vel = move_and_slide(vel, UP)