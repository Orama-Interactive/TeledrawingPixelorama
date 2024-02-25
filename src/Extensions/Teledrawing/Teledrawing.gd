extends AcceptDialog

var menu_item_index: int
var port := 18819
var ip := "::1"

@onready var network_options := $NetworkOptions as VBoxContainer
@onready var disconnect_button := %Disconnect as Button


func _enter_tree() -> void:
	menu_item_index = ExtensionsApi.menu.add_menu_item(ExtensionsApi.menu.EDIT, "Teledrawing", self)
	multiplayer.connected_to_server.connect(handle_connect)
	multiplayer.peer_connected.connect(new_user_connected)


func _exit_tree() -> void:
	handle_disconnect()
	ExtensionsApi.menu.remove_menu_item(ExtensionsApi.menu.EDIT, menu_item_index)


func menu_item_clicked() -> void:
	popup_centered()
	ExtensionsApi.dialog.dialog_open(true)


func handle_connect() -> void:
	for child: Control in network_options.get_children():
		child.visible = child == disconnect_button
	ExtensionsApi.signals.signal_project_data_changed(project_data_changed)


func handle_disconnect() -> void:
	for child: Control in network_options.get_children():
		child.visible = child != disconnect_button
	multiplayer.multiplayer_peer = null
	ExtensionsApi.signals.signal_project_data_changed(project_data_changed, true)


## Should run only on the server
func new_user_connected(peer_id: int) -> void:
	if not multiplayer.is_server():
		return
	var project = ExtensionsApi.project.current_project
	var project_data: Dictionary = project.serialize()
	var images_data: Array = []
	for frame in project.frames:
		for cel in frame.cels:
			var cel_image: Image = cel.get_image()
			if is_instance_valid(cel_image) and cel.get_class_name() == "PixelCel":
				images_data.append(cel_image.get_data())
	receive_new_project.rpc_id(peer_id, project_data, images_data)


@rpc("authority", "call_remote", "reliable")
func receive_new_project(project_data: Dictionary, images_data: Array) -> void:
	var new_project = ExtensionsApi.project.new_empty_project()
	new_project.deserialize(project_data)
	var image_index := 0
	for frame in new_project.frames:
		for cel in frame.cels:
			if cel.get_class_name() != "PixelCel":
				continue
			var image_data: PackedByteArray = images_data[image_index]
			var image := Image.create_from_data(
				new_project.size.x, new_project.size.y, false, Image.FORMAT_RGBA8, image_data
			)
			cel.image_changed(image)
			image_index += 1
	ExtensionsApi.project.current_project = new_project
	ExtensionsApi.general.get_canvas().camera_zoom()


func project_data_changed(project: RefCounted) -> void:
	var data := {}
	var cels: Array = project.selected_cels
	for cel_indices in cels:
		var frame_index: int = cel_indices[0]
		var layer_index: int = cel_indices[1]
		var cel = project.frames[frame_index].cels[layer_index]
		if cel.get_class_name() != "PixelCel":
			continue
		var image: Image = cel.image
		data[cel_indices] = image.get_data()
	receive_changes.rpc(data)


@rpc("any_peer", "call_remote", "reliable")
func receive_changes(data: Dictionary) -> void:
	for cel_indices in data:
		var project = ExtensionsApi.project.current_project
		var frame_index: int = cel_indices[0]
		var layer_index: int = cel_indices[1]
		var cel = project.frames[frame_index].cels[layer_index]
		if cel.get_class_name() != "PixelCel":
			continue
		var image: Image = cel.image
		var image_data: PackedByteArray = data[cel_indices]
		image.set_data(
			image.get_width(), image.get_height(), image.has_mipmaps(), image.get_format(), image_data
		)
		ExtensionsApi.general.get_canvas().update_texture(layer_index, frame_index, project)


func _on_create_server_pressed() -> void:
	var server := ENetMultiplayerPeer.new()
	server.create_server(port, 32)
	multiplayer.multiplayer_peer = server
	handle_connect()


func _on_join_server_pressed() -> void:
	var client := ENetMultiplayerPeer.new()
	client.create_client(ip, port)
	multiplayer.multiplayer_peer = client


func _on_disconnect_pressed() -> void:
	handle_disconnect()


func _on_ip_line_edit_text_changed(new_text: String) -> void:
	ip = new_text


func _on_port_line_edit_text_changed(new_text: String) -> void:
	if new_text.is_valid_int():
		port = new_text.to_int()


func _on_visibility_changed() -> void:
	if not visible:
		ExtensionsApi.dialog.dialog_open(false)