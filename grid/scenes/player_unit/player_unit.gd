class_name Unit
extends Path2D

signal walk_finished

@export var grid: Resource = preload("res://node res/grid/grid.tres")
#@export var skin: Texture: set = set_skin #control instead with spritesheet
@export var move_range := 6
@export var skin_offset := Vector2.ZERO: set = set_skin_offset
@export var move_speed := 150
@export var character_sprite_dimensions := Vector2(32,32)
@export var entity_class := int(1)
@export var entity_team := int(1)
@export var mp_id = int(1)
@export var health := 10
@export var max_health := 10


@export var cell := Vector2.ZERO: set = set_cell #need to export this to sync via mp_sync node. 
var is_selected := false: set = set_is_selected
var _is_walking := false: set = _set_is_walking
var path_x_movement = Array() #array used for path2d x movement (-1 is left, +1 is right, 0 is no move or up/down. Sprite faces L, so should be flipped if +1, not flipped if -1, and ignored if 0). 

@onready var _sprite: Sprite2D = $unit_path_follow_2d/unit_sprite
@onready var _anim_player: AnimationPlayer = $unit_animation
@onready var _path_follow: PathFollow2D = $unit_path_follow_2d
@onready var _health_bar_anim: ProgressBar = $unit_path_follow_2d/health_bar
@onready var main = get_parent()

func pull_base_texture_for_class_team():
	var rect_x = (entity_team - 1) * character_sprite_dimensions.x
	var rect_y = (entity_class - 1)* character_sprite_dimensions.y
	return Rect2(rect_x, rect_y, character_sprite_dimensions.x, character_sprite_dimensions.y)

func _ready() -> void:
	#set multiplayer authority to ensure export variables (synced) can only be updated by the creating player. Code in game_board to prevent selection unless mp_ids match.
	$mp_sync.set_multiplayer_authority(mp_id)
	
	#setup for path/cell/pos bits
	set_process(false)
	_path_follow.rotates = false
	cell = grid.calculate_grid_coordinates(position)
	position = grid.calculate_map_position(cell)
	
	# health bar setting
	_health_bar_anim.max_value = max_health
	_health_bar_anim.value = health
	
	
	##I can't figure this shit out man, malcolm please do the type variation stuff i stupid
	var player_box = _health_bar_anim.get_theme_stylebox("fill","ProgressBar").duplicate()
	var p_col = GlobalSettings.player_unit_health_bar_color
	player_box.set("fill", Color(p_col[0],p_col[1],p_col[2],p_col[3]))
	var enemy_box = _health_bar_anim.get_theme_stylebox("fill","ProgressBar").duplicate()
	var e_col = GlobalSettings.enemy_unit_health_bar_color
	enemy_box.set("fill", Color(e_col[0],e_col[1],e_col[2],e_col[3]))
	# style box adjustments for player/enemy
	if int(main.mp_id) == int(mp_id):
		_health_bar_anim.set("fill",Color(p_col[0],p_col[1],p_col[2],p_col[3]))
	_health_bar_anim.set("fill",Color(e_col[0],e_col[1],e_col[2],e_col[3]))
	#_health_bar_anim.set("theme_override_styles/fill",col_set)
	
	# sprite setting
	_sprite.texture = ImageTexture.create_from_image(_sprite.texture.get_image())
	_sprite.region_rect = pull_base_texture_for_class_team()
	_sprite.region_enabled = true

	if not Engine.is_editor_hint():
		curve = Curve2D.new()


func _process(delta: float) -> void:
	_path_follow.progress += move_speed * delta
	
	##revisit following block. called every _process frame, which is a bit bad.
	if get_x_turns_from_path_follow() == 1:
		_sprite.flip_h = true
	if get_x_turns_from_path_follow() == -1:
		_sprite.flip_h = false
	
	_anim_player.play("walking")
	if _path_follow.progress_ratio >= 1.0:
		self._is_walking = false
		_path_follow.progress = 0.00001
		position = grid.calculate_map_position(cell)
		curve.clear_points()
		_anim_player.play("idle")
		emit_signal("walk_finished")

func walk_along(path: PackedVector2Array) -> void:
	if path.is_empty():
		return

	curve.add_point(Vector2.ZERO)
	for point in path:
		curve.add_point(grid.calculate_map_position(point) - position)
	cell = path[-1]
	self._is_walking = true
	path_x_movement = get_path_x_turns()

func set_cell(value: Vector2) -> void:
	cell = grid.grid_clamp(value)

func set_is_selected(value: bool) -> void:
	is_selected = value
	if is_selected:
		_anim_player.play("selected")
	else:
		_anim_player.play("idle")

func set_skin_offset(value: Vector2) -> void:
	skin_offset = value
	if not _sprite:
		await self.ready
	_sprite.position = value

func _set_is_walking(value: bool) -> void:
	_is_walking = value
	set_process(_is_walking)

func get_path_x_turns(): #definitely tidy up, basically creates a set of points to figure out whether to flip the sprite or not
	var curve_path_array = Array()
	var origin = Vector2(0,0)
	for point in curve.get_baked_points():
		curve_path_array.append((point.x - origin.x)/abs(point.x - origin.x))
		origin = point
	for x in range(curve_path_array.size()):
		if abs(curve_path_array[x]) != 1:
			curve_path_array[x] = 0
	return curve_path_array

func get_x_turns_from_path_follow():
	return path_x_movement[floor(_path_follow.progress_ratio * path_x_movement.size()-1)]
