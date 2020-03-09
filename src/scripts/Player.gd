extends KinematicBody2D

const UP = Vector2(0, -1)
const GRAVITY = 600
const SPEED = 130
const FRICTION = 15
const JUMP_FORCE = 260
const AIR_FRICTION_MULT = 0.3
const SHOT_RANGE = 150
const DEATH_HEIGHT = 300

var vel = Vector2(0, 0)
var aim_vector = Vector2(0, 0)
var attach_point = Vector2(0, 0)

onready var reticle = $Reticle
onready var sprite = $AnimatedSprite
onready var hook_sprite = get_node("Reticle/Reticle_sprite")
onready var level = null

onready var kill_enemy = $kill_enemy
onready var jump = $jump
onready var shoot = $shoot

func _ready():
	set_process(true)

func _enter_tree():
	level = null
	get_node("../Camera2D").reset()

func _process(delta):
	for i in get_slide_count() - 1:
		if get_slide_collision(i).collider in get_tree().get_nodes_in_group("compressor"):
			owner.reset()
	
	if position.y > DEATH_HEIGHT:
		owner.reset()
	
	var temp_friction = FRICTION
	if !is_on_floor():
		temp_friction *= AIR_FRICTION_MULT
		
	var temp_aim_vector = get_aim_vector()
	if temp_aim_vector != Vector2(0, 0):
		aim_vector = temp_aim_vector
	
	reticle.set_rotation(aim_vector.angle())
	
	vel.y += GRAVITY * delta
	vel.x += (get_input_vector().x * SPEED - vel.x) * temp_friction * delta
	
	if Input.is_action_just_pressed("jump") && is_on_floor():
		jump.play()
		vel.y -= JUMP_FORCE
	if len(get_tree().get_nodes_in_group("hook")) != 0:
		hook_sprite.hide()
		attach_point = get_tree().get_nodes_in_group("hook")[0].get_global_position()
		if Input.is_action_just_pressed("shoot"):
			get_tree().get_nodes_in_group("hook")[0].queue_free()
	else:
		hook_sprite.show()
		if Input.is_action_just_pressed("shoot"):
			fire_hook()
	
	#animations and sprite flipping
	if !is_on_floor():
		sprite.play("Jump")
	else:
		if get_input_vector().x == 0 :
			sprite.play("Idle")
		else:
			sprite.play("Run")
	if get_aim_vector().x > 0:
		sprite.set_flip_h(false)
	elif get_aim_vector().x < 0:
		sprite.set_flip_h(true)
	
	vel = move_and_slide(vel, UP)

func fire_hook():
	shoot.play()
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(position, position + aim_vector * SHOT_RANGE, [self])
	
	if result:
		if result.collider in get_tree().get_nodes_in_group("chunk"):
			var chunk = result.collider.get_node("../..")
			chunk.attach(result.position)
		elif result.collider in get_tree().get_nodes_in_group("enemy"):
			kill_enemy.play()
			result.collider.kill()
			owner.hook_pos = position + aim_vector * SHOT_RANGE
		else:
			owner.hook_pos = position + aim_vector * SHOT_RANGE
	else:
		owner.hook_pos = position + aim_vector * SHOT_RANGE

func get_aim_vector():
	var aim_vec = Vector2(0, 0)
	if Input.is_action_pressed("aim_right"):
		aim_vec.x += 1
	if Input.is_action_pressed("aim_left"):
		aim_vec.x -= 1
	if Input.is_action_pressed("aim_up"):
		aim_vec.y -= 1
	if Input.is_action_pressed("aim_down"):
		aim_vec.y += 1
	
	return aim_vec
	

func get_input_vector():
	var input_vec = Vector2(0, 0)
	if Input.is_action_pressed("move_left"):
		input_vec.x -= 1
	if Input.is_action_pressed("move_right"):
		input_vec.x += 1
	
	return input_vec

func _on_Area2D_body_entered(body):
	if body in get_tree().get_nodes_in_group("block"):
		owner.reset()
