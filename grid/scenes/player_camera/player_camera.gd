extends Camera2D

var camera_zoom_tween: Tween = null

var max_zoom = Vector2(GlobalSettings.camera_zoom_max,GlobalSettings.camera_zoom_max)
var min_zoom = Vector2(GlobalSettings.camera_zoom_min,GlobalSettings.camera_zoom_min)
var zoom_default = Vector2(GlobalSettings.camera_zoom_default,GlobalSettings.camera_zoom_default)
var zoom_step_amount = Vector2(GlobalSettings.camera_zoom_step_amount,GlobalSettings.camera_zoom_step_amount)
var zoom_speed = GlobalSettings.camera_zoom_speed
var max_speed = GlobalSettings.camera_max_movement_speed
var accel = GlobalSettings.camera_accel #seconds to reach top speed
var deccel = GlobalSettings.camera_deccel

@onready var grid: Resource = preload("res://node res/grid/grid.tres")

#vectorise camera speed and input
var input_vector = Vector2()
var vector_speed = Vector2()
var vector_movement = Vector2.ZERO
var vector_movement_magnitude = float()

func input_vector_get():
	input_vector = Vector2.ZERO
	if Input.is_action_pressed("camera_d"):
		input_vector.x += 1
	if Input.is_action_pressed("camera_a"):
		input_vector.x -= 1
	if Input.is_action_pressed("camera_s"):
		input_vector.y += 1
	if Input.is_action_pressed("camera_w"):
		input_vector.y -= 1

func vector_movement_get(d):
	if (input_vector.x == 0 and input_vector.y ==0): #no x/y, drag
		if vector_movement_magnitude > 0:
			vector_movement_magnitude -= (d / deccel)
		elif vector_movement_magnitude < 0:
			vector_movement_magnitude = 0
	else: vector_movement_magnitude += (d / accel) #some x/y, accel velocity
	vector_movement_magnitude = clamp(vector_movement_magnitude,0,max_speed) # clamp max
	vector_movement = input_vector * vector_movement_magnitude #set movement to vector * magnitude
	if (vector_movement.x != 0 and vector_movement.y != 0):
		vector_movement = vector_movement / 1.4142 #yes it's a magic number, generic form of 2x/sqrt(2x^2)

func _process(delta) -> void:
	input_vector_get()
	vector_movement_get(delta)
	if input_vector:
		move_local_x(vector_movement.x)
		move_local_y(vector_movement.y)
	
	
	if Input.is_action_just_pressed("mouse_wheel_up"):
		if get_zoom() < max_zoom:
			if camera_zoom_tween == null or not camera_zoom_tween.is_running():
				camera_zoom_tween = create_tween()
				camera_zoom_tween.tween_property(self, "zoom", get_zoom() * (zoom_default + zoom_step_amount), zoom_speed).set_trans(Tween.TRANS_CUBIC)
				print(get_zoom() + zoom_step_amount)
	elif Input.is_action_just_pressed("mouse_wheel_down"):
		if get_zoom() > min_zoom:
			if camera_zoom_tween == null or not camera_zoom_tween.is_running():
				camera_zoom_tween = create_tween()
				camera_zoom_tween.tween_property(self, "zoom", get_zoom() / (zoom_default + zoom_step_amount), zoom_speed).set_trans(Tween.TRANS_CUBIC)
				print(get_zoom() - zoom_step_amount)

func _ready(): #set camera pos in middle of screen when ready
	self.position = (grid.size * grid._half_cell_size)
	self.zoom = min_zoom
