
#####ONLY WORKS IN SP - REMOVE
extends Control

@onready var _team_select: OptionButton = $"Team Select"
@onready var _class_select: OptionButton = $'Class Select'
@export var player_unit_scene: PackedScene
@onready var game_board = get_parent().get_parent()
@export var grid: Resource

var team_selected = int()
var class_selected = int()


func _ready():
	#print(game_board)
	pass
	
func get_team_and_class():
	team_selected = _team_select.get_selected_id()
	class_selected = _class_select.get_selected_id()

func _on_button_pressed():
	spawn_character()

func find_next_open_cell_x():
	var cell_index = Vector2(5,5)
	while game_board.is_occupied(cell_index):
		cell_index.x += 1
	return cell_index

func spawn_character():
	get_team_and_class()
	var character = player_unit_scene.instantiate(PackedScene.GEN_EDIT_STATE_MAIN_INHERITED)
	character.position = find_next_open_cell_x() * grid.cell_size
	character.entity_class = class_selected
	character.entity_team = team_selected
	character.mp_id = game_board.mp_id
	game_board.add_child(character)
	game_board._reinitialize()
