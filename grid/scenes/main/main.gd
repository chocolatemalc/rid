extends Node2D

@export var player_spawn_scene: PackedScene
@onready var game_board = $Game_Board #need to _reinitialize to push to grid after it's all spawned.
@export var mp_id = str(1)

func _ready(): #complete jank, do not change names of mp_spawn_positions nodes
	var index = 0
	var local_dict: Dictionary = MpControlManager.mp_peers
	var local_keys = local_dict.keys()
	local_keys.sort()
	for i in local_keys:
		var current_peer = player_spawn_scene.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE) ## instantiate within gameboard please
		current_peer.entity_team = MpControlManager.mp_peers[i].team_index
		current_peer.mp_id = int(MpControlManager.mp_peers[i].id)
		#current_peer.set_multiplayer_authority(MpControlManager.mp_peers[i].id) innapropriate, define another @export var in character for owner (id). Set here and modify whether it can be selected in movement code
		for spawn_point in get_tree().get_nodes_in_group("mp_spawn"):
			if spawn_point.name == str(index):
				current_peer.global_position = spawn_point.global_position + Vector2(16,16) #magic number, fix spawn pos
		index += 1
		game_board.add_child(current_peer)
		game_board._reinitialize()
