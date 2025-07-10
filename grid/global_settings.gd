extends Node


#block of bits for camera
const camera_max_movement_speed: float = 6
const camera_accel: float = 0.05 # number of seconds to reach top speed  
const camera_deccel: float = 0.025 # number of seconds to drag to stop
const camera_zoom_default: float = 1
const camera_zoom_max: float = 4
const camera_zoom_min: float = 0.5
const camera_zoom_step_amount: float = 0.5
const camera_zoom_speed: float = 0.25

const player_unit_health_bar_color: Array = [60, 180, 90, 200]
const enemy_unit_health_bar_color: Array = [245, 100, 100, 200]
