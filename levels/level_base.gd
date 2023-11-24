extends Node2D

class_name LevelBase

@onready var player: Player = $Player
@onready var spawn_point := $SpawnPoint

signal score_changed

var item_scene := load("res://items/item.tscn")

var score := 0: set = set_score

func set_score(value: int) -> void:
	score = value
	score_changed.emit(score) 

func _ready() -> void:
	$Items.hide()
	player.reset(spawn_point.position)
	set_camera_limits()
	spawn_items()
	
func set_camera_limits() -> void:
	var map_size = $World.get_used_rect()
	var cell_size = $World.tile_set.tile_size
	$Player/Camera2D.limit_left = (map_size.position.x - 5) * cell_size.x
	$Player/Camera2D.limit_right = (map_size.end.x + 5) * cell_size.x
	
func spawn_items() -> void:
	var item_cells = $Items.get_used_cells(0)
	for cell in item_cells:
		var data = $Items.get_cell_tile_data(0, cell)
		var type = data.get_custom_data("type")
		var item_type := Item.ItemType.CHERRY if type == "cherry" else Item.ItemType.GEM
		var item = item_scene.instantiate()
		add_child(item)
		item.init(item_type	, $Items.map_to_local(cell))
		item.picked_up.connect(self._on_item_picked_up)
	
func _on_item_picked_up() -> void:
	score += 1



func _on_player_died() -> void:
	GameState.restart()
