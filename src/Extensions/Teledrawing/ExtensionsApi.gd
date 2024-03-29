# gdlint: ignore=max-public-methods
extends Node

# use these variables in your extension to access the api
var general := GeneralAPI.new()
var menu := MenuAPI.new()
var dialog := DialogAPI.new()
var panel := PanelAPI.new()
var theme := ThemeAPI.new()
var tools := ToolAPI.new()
var project := ProjectAPI.new()
var signals := SignalsAPI.new()


# The Api Methods Start Here
func get_api_version() -> int:
	# Returns the api version of pixelorama
	return 2


class GeneralAPI:
	# Version And Config
	func get_pixelorama_version() -> String:
		# Returns the version of pixelorama
		return "0.11.0"

	func get_config_file() -> ConfigFile:
		# config_file contains all the settings (Brushes, sizes, preferences, etc...)
		return ConfigFile.new()

	# Nodes
	func get_global():
		# Returns the Global autoload used by pixelorama
		pass

	func get_extensions_node() -> Node:
		# Returns the Extensions Node (the parent of the extension's Main.tscn)
		return Node.new()

	func get_canvas():
		# Returns the canvas
		pass


class MenuAPI:
	enum { FILE, EDIT, SELECT, IMAGE, VIEW, WINDOW, HELP }

	func add_menu_item(menu_type: int, item_name: String, item_metadata, item_id := -1) -> int:
		# item_metadata is usually a popup node you want to appear when you click the item_name
		# that popup should also have an (menu_item_clicked) function inside it's script
		# "item_idx" of the added entry is returned
		return 0

	func remove_menu_item(menu_type: int, item_idx: int) -> void:
		# removes an entry at "item_idx" from the menu_type (FILE, EDIT, SELECT, IMAGE, VIEW, WINDOW, HELP)
		pass


class DialogAPI:
	func show_error(text: String) -> void:
		# shows an alert dialog with the given "text"
		# useful for displaying messages like "Incompatible API" etc...
		pass

	func get_dialogs_parent_node() -> Node:
		# returns the node that is the parent of the dialog used in pixelorama
		return Node.new()

	func dialog_open(open: bool) -> void:
		# Tell pixelorama that a dialog is being opened
		pass


class PanelAPI:
	func set_tabs_visible(visible: bool) -> void:
		# sets the visibility of tabs
		pass

	func get_tabs_visible() -> bool:
		# get the visibility of tabs
		return false

	func add_node_as_tab(node: Node) -> void:
		# Adds a "node" as a tab
		pass

	func remove_node_from_tab(node: Node) -> void:
		# Removes the "node" from the DockableContainer
		pass


class ThemeAPI:
	func add_theme(theme: Theme) -> void:
		# Adds a theme
		pass

	func find_theme_index(theme: Theme) -> int:
		# Returns index of a theme in preferences
		return 0

	func get_theme() -> Theme:
		# Returns the current theme
		return Theme.new()

	func set_theme(idx: int) -> bool:
		# Sets a theme located at a given "idx" in preferences
		# If theme set successfully then return true, else false
		return false

	func remove_theme(theme: Theme) -> void:
		# Remove a theme from preferences
		pass


class ToolAPI:
	# Tool methods
	func add_tool(
		tool_name: String,
		display_name: String,
		scene: String,
		layer_types: PackedInt32Array = [],
		extra_hint := "",
		shortcut: String = "",
		extra_shortcuts: PackedStringArray = [],
		insert_point := -1
	) -> void:
		# Adds a tool with the above detail
		pass

	func remove_tool(tool_name: String) -> void:
		# Removes a tool with name "tool_name"
		# and assign Pencil as left tool, Eraser as right tool
		pass


class ProjectAPI:
	var current_project

	func get_current_cel_info() -> Dictionary:
		# As there are more than one types of cel in Pixelorama,
		# An extension may try to use a GroupCel as a PixelCel (if it doesn't know the difference)
		# So it's encouraged to use this function to access cels

		# type can be "GroupCel", "PixelCel", "Cel3D", and "BaseCel"
		return {"cel": null, "type": ""}

	func get_cel_info_at(project, frame: int, layer: int) -> Dictionary:
		# frames from left to right, layers from bottom to top
		# frames/layers start at "0"
		# and end at (project.frames.size() - 1) and (project.layers.size() - 1) respectively
		return {"cel": null, "type": ""}


class SignalsAPI:
	func signal_pixelorama_opened(callable: Callable, is_disconnecting := false) -> void:
		return

	## Connects/disconnects a signal to [param callable], that emits
	## when pixelorama is about to close.
	func signal_pixelorama_about_to_close(callable: Callable, is_disconnecting := false) -> void:
		return

	# PROJECT RELATED SIGNALS
	## Connects/disconnects a signal to [param callable], that emits
	## whenever a new project is created.[br]
	## [b]Binds: [/b]It has one bind of type [code]Project[/code] which is the newly created project
	func signal_project_created(callable: Callable, is_disconnecting := false) -> void:
		return

	## Connects/disconnects a signal to [param callable], that emits
	## after a project is saved.
	func signal_project_saved(callable: Callable, is_disconnecting := false) -> void:
		return

	## Connects/disconnects a signal to [param callable], that emits
	## whenever you switch to some other project.
	func signal_project_switched(callable: Callable, is_disconnecting := false) -> void:
		return

	## Connects/disconnects a signal to [param callable], that emits
	## whenever you select a different cel.
	func signal_cel_switched(callable: Callable, is_disconnecting := false) -> void:
		return

	## Connects/disconnects a signal to [param callable], that emits
	## whenever the project data are being modified.
	func signal_project_data_changed(callable: Callable, is_disconnecting := false) -> void:
		return

	# TOOL RELATED SIGNALS
	## Connects/disconnects a signal to [param callable], that emits
	## whenever a tool changes color.[br]
	## [b]Binds: [/b] It has two bind of type [Color] (indicating new color)
	## and [int] (Indicating button that tool is assigned to, see [enum @GlobalScope.MouseButton])
	func signal_tool_color_changed(callable: Callable, is_disconnecting := false) -> void:
		return

	# TIMELINE RELATED SIGNALS
	## Connects/disconnects a signal to [param callable], that emits
	## whenever timeline animation starts.[br]
	## [b]Binds: [/b] It has one bind of type [bool] which indicated if animation is in
	## forward direction ([code]true[/code]) or backward direction ([code]false[/code])
	func signal_timeline_animation_started(callable: Callable, is_disconnecting := false) -> void:
		return

	## Connects/disconnects a signal to [param callable], that emits
	## whenever timeline animation stops.
	func signal_timeline_animation_finished(callable: Callable, is_disconnecting := false) -> void:
		return

	# UPDATER SIGNALS
	## Connects/disconnects a signal to [param callable], that emits
	## whenever texture of the currently focused cel changes.
	func signal_current_cel_texture_changed(callable: Callable, is_disconnecting := false) -> void:
		return

	## Connects/disconnects a signal to [param callable], that emits
	## whenever preview is about to be drawn.[br]
	## [b]Binds: [/b]It has one bind of type [Dictionary] with keys: [code]exporter_id[/code],
	## [code]export_tab[/code], [code]preview_images[/code], [code]durations[/code]
	## [br] Use this if you plan on changing preview of export
	func signal_export_about_to_preview(callable: Callable, is_disconnecting := false) -> void:
		return
