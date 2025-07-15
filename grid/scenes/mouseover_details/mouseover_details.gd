extends Control

@export var type: String
@export var health: String
@export var max_health: String

@onready var type_box = $"Container/unit type"
@onready var health_box = $"Container/health"

#func _ready():
	#type_box.text = type
	#health_box.text = str(health,"/",max_health)
