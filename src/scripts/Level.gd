extends Node2D

const MAX_CHUNK_WIDTH = 4
const MIN_CHUNK_WIDTH = 2
const BLOCK_SIZE = 8
const LEVEL_GRID = [
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],]
const LEVEL_OFFSET = Vector2(96, 64)
const SPAWNER_OFFSET = 3

var level_left = 0
var level_right = 23

var time_to_next_break = 7000
var difficulty_ramp = 0.97
var last_break = 0

onready var temp_grid = LEVEL_GRID.duplicate(true)
onready var blocks = $Blocks
onready var block_scene = load("res://Block.tscn")
onready var chunk_scene = load("res://Chunk.tscn")
onready var spawner_1 = $EnemySpawner_1
onready var spawner_2 = $EnemySpawner_2

func _enter_tree():
	time_to_next_break = 7000
	last_break = OS.get_ticks_msec()
	level_left = 0
	level_right = 23

func update_level(grid : Array):
	if spawner_1 && spawner_2:
		spawner_1.position.x = (level_left + SPAWNER_OFFSET) * BLOCK_SIZE
		spawner_2.position.x = (level_right - SPAWNER_OFFSET) * BLOCK_SIZE
	
	
	for block in blocks.get_children():
		block.queue_free()
	for i in len(grid):
		for j in len(grid[i]):
			if grid[i][j]:
				var block = block_scene.instance()
				block.position = Vector2(j * BLOCK_SIZE, i * BLOCK_SIZE) - LEVEL_OFFSET
				blocks.call_deferred("add_child", block);

func generate_chunk():
	var start_pos = level_left
	if randi() % 2:
		start_pos = level_right
	
	var chunk_width = int(rand_range(MIN_CHUNK_WIDTH, MAX_CHUNK_WIDTH))	
	var chunk_grid = temp_grid.duplicate(true)
	
	#cut out random blocks from chunk_grid	
	for i in len(chunk_grid):
		for j in len(chunk_grid[i]):
			if abs(j - start_pos) > chunk_width:
				chunk_grid[i][j] = 0
			elif start_pos == level_left and j <= level_left:
				chunk_grid[i][j] = temp_grid[i][j]
			elif start_pos == level_right and j >= level_right:
				chunk_grid[i][j] = temp_grid[i][j]
			else:
				var weight = pow(abs(start_pos - j) / chunk_width, 2)
				weight += i / 12
				if randf() * weight * chunk_width > .5:
					chunk_grid[i][j] = 0
	
	#clean up chunk_grid and
	for i in len(chunk_grid):
		for j in len(chunk_grid[i]) - 2:
			if chunk_grid[i][j + 1]:
				if j + 1 == start_pos:
					chunk_grid[i][j + 1] = temp_grid[i][j + 1]
				elif not(chunk_grid[i][j + 2] or chunk_grid[i][j]):
					chunk_grid[i][j + 1] = 0
	
	#cut chunk blocks out of temp_grid
	for i in len(chunk_grid):
		for j in len(chunk_grid[i]):
			if chunk_grid[i][j]:
					temp_grid[i][j] = 0
	
	var chunk = chunk_scene.instance()
	chunk.grid = chunk_grid
	chunk.connect("reconnect", self, "_on_reconnect")
	call_deferred("add_child", chunk)
	
	if start_pos == level_left:
		level_left += chunk_width
		chunk.split_direction = -1
	else:
		level_right -= chunk_width
		chunk.split_direction = 1
	
	update_level(temp_grid)

func _ready():
	update_level(LEVEL_GRID)

func update_bounds(grid : Array):
	level_right = 0
	level_left = 23
	for i in len(grid):
		for j in len(grid[i]):
			if grid[i][j]:
				level_right = max(j, level_right)
				level_left = min(j, level_left)

func _on_reconnect(grid : Array):
	for i in len(grid):
		for j in len(grid[i]):
			if grid[i][j]:
				temp_grid[i][j] = LEVEL_GRID[i][j]
	
	update_bounds(temp_grid)
	var time = OS.get_ticks_msec()
	update_level(temp_grid)
	
	print(OS.get_ticks_msec() - time)

func _process(delta):
	var time_since_last_break = OS.get_ticks_msec() - last_break
	
	if time_since_last_break >= time_to_next_break:
		last_break = OS.get_ticks_msec()
		generate_chunk()
		time_to_next_break *= difficulty_ramp