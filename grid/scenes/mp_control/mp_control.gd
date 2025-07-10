extends Control

@export var address := "127.0.0.1"
@export var port := 8910 #lol
@export var max_players := 4
var peer



#TO DO: Add a _process(delta) function with a delta timer, e.g. global var time: float = 0. each _process, time += delta. @ 5(?; seconds), check multiplayer.is_server() and run dict_server_share()
#on play (start_button_down), check # peers against # MpContolManager.mp_peer dictionary entries, don't run if not equal.
#on play, make server call dict_server_share to ensure everyone's copy is good.
#potential rpc to check # dict entities by id, so we can make sure everyone has an equal #.

func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)

func _on_host_button_down():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 4)
	if error != OK:
		print("Cannot host: " + str(error))
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER) #check enums, works good on small packets but not super efficient > 4kb.
	multiplayer.set_multiplayer_peer(peer)
	
	#add entry.
	add_to_dict_local()
	
	print("Waiting for players.")

func _on_join_button_down():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(address,port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)


func _on_start_button_down():
	if multiplayer.is_server():
		start_game.rpc() #blank RPC calls everyone. 99% of time it'll be rpc(1) (host).
	else: print("YOU ARE NOT THE SERVER SAAR PLEASE WAIT")

func peer_connected(id):
	print("Connected " + str(id))
	#if server, run code to immediately share through what you've got in the dictionary. The host will also call add_to_dict_local(), to and double-ups on ID basis then discarded
	if multiplayer.is_server():
		for i in MpControlManager.mp_peers:
			var new_dict_entry = JSON.stringify(MpControlManager.mp_peers[i])
			var dict_id = MpControlManager.mp_peers[i].id
			rpc("dict_server_share", dict_id, new_dict_entry)
			
func peer_disconnected(id):
	print("Disconnected " + str(id))

func connected_to_server(): #DO NOT CALL ANYTHING IN THE BRACKETS HERE PLEASE GOD BECAUSE IT EXPECTS ARGS ON CALL
	print("connected_to_server")
	var json = JSON.new()
	var data_string = dict_entry()
	var error = json.parse(data_string)
	if error == OK:
		var data = json.data
		print(data)
		rpc_id(1,"dict_add",multiplayer.get_unique_id(),dict_entry())
	else:
		print("JSON error")

	#adding to local
	add_to_dict_local()


func connection_failed(_id):
	print("Couldn't connect")

@rpc("any_peer","call_local")
func start_game():
	var scene = load("res://scenes/main/main.tscn").instantiate()
	var mp_id = multiplayer.get_unique_id()
	scene.mp_id = str(mp_id)
	get_tree().root.add_child(scene)
	self.hide()

@rpc("any_peer","reliable")
func dict_add(id,json):
	if !MpControlManager.mp_peers.has(id):
		var data_json = JSON.new()
		var json_error = data_json.parse(json)
		if json_error == OK:
			var json_to_add = data_json.data
			MpControlManager.mp_peers[id] = json_to_add

@rpc("authority","call_remote","reliable") ##called by server on connect to share existing dictionary items
func dict_server_share(id,json):
	if !MpControlManager.mp_peers.has(id):
		var data_json = JSON.new()
		var json_error = data_json.parse(json)
		if json_error == OK:
			var json_to_add = data_json.data
			MpControlManager.mp_peers[id] = json_to_add

func dict_entry():
	var result: Dictionary = {
		"id": multiplayer.get_unique_id(),
		"name": $mp_name.text,
		"team_index": $team_select.get_selected_id()
	}
	return JSON.stringify(result)

func add_to_dict_local():
	if !MpControlManager.mp_peers.has(multiplayer.get_unique_id()):
		var data_json = JSON.new()
		var json = dict_entry()
		var json_error = data_json.parse(json)
		if json_error == OK:
			var new_dict_entry = data_json.data
			MpControlManager.mp_peers[multiplayer.get_unique_id()] = new_dict_entry
