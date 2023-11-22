extends Node2D

class_name LevelBase

@onready var player: Player = $Player
@onready var spawn_point := $SpawnPoint

func _ready() -> void:
	$Items.hide()
	player.reset(spawn_point.position)
