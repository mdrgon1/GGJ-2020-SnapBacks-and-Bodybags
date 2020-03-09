extends Node2D

signal reconnect

const BLOCK_SIZE = 8
const OFFSET = Vector2(50, -30)
const ROT_OFFSET = 0.1
const LEVEL_OFFSET = Vector2(96, 64)
const LIFETIME = 5

var grid : Array
var split_direction : int
var target_transform : Transform2D
var transform_lerp = 0
var break_speed = .9
var player : KinematicBody2D
var hook : Node2D
var attached = false

onready var blocks = $Blocks
onready var block_scene = load("res://Block.tscn")
onready var hook_scene = load("res://Hook.tscn")
onready var home_transform = get_transform()

func set_blocks():
	for block in blocks.get_children():
		block.queue_free()
	for i in len(grid):
		for j in len(grid[i]):
			if grid[i][j]:
				var block = block_scene.instance()
				block.position = Vector2(j * BLOCK_SIZE, i * BLOCK_SIZE) - LEVEL_OFFSET
				block.add_to_group("chunk")
				blocks.call_deferred("add_child", block);

func _ready():
	
	var offset = Vector2(OFFSET.x * split_direction, OFFSET.y)
	var rot_offset = ROT_OFFSET * split_direction
	
	target_transform = home_transform
	target_transform = target_transform.rotated(rot_offset)
	target_transform = target_transform.translated(offset)
	
	set_blocks()

func attach(attach_position):
	hook = hook_scene.instance()
	hook.attach_point = attach_position
	call_deferred("add_child", hook)
	attached = true
	player = get_tree().get_nodes_in_group("player")[0]

func _process(delta):
	if attached:
		if hook && player:
			var pull_magnitude = 0.01 * (player.position.distance_to(hook.position))
			transform_lerp -= pull_magnitude * delta
	else:
		transform_lerp += delta * break_speed
	
	if transform_lerp < 0:
		emit_signal("reconnect", grid)
		call_deferred("queue_free")
	if transform_lerp > LIFETIME:
		call_deferred("queue_free")
	set_transform(home_transform.interpolate_with(target_transform, transform_lerp))
	#set_transform(target_transform)