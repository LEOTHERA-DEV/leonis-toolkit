@tool
extends EditorPlugin

var _terraingen_menu_controls
var _terraingen_mode_option_control
var _splatedit_menu_controls
var _splatchannel_options

var _brush_controls
var _brush_scale

var _paint_mode := false
var _mouse_drag := false
var _draw := false
var _erase := false
var current_cam
var _curren_mouse_pos

var _obj

func _enter_tree():
	
#	Controls and options for Terrain Gen
	_terraingen_menu_controls = MenuButton.new()
	_terraingen_menu_controls.text = "Terraform"
	
	_terraingen_mode_option_control = OptionButton.new()
	_terraingen_mode_option_control.text = "Current Mode"
	
	_splatedit_menu_controls = OptionButton.new()
	_splatedit_menu_controls.text = "Current Splat"
	
	_splatchannel_options = OptionButton.new()
	_splatchannel_options.text = "Channel"
	
	_brush_controls = SpinBox.new()
	_brush_controls.step = 1
	_brush_controls.min_value = 1
	_brush_controls.max_value = 10
	_brush_controls.tooltip_text = "Current Brush Size"
	
	var _terraingen_pop = _terraingen_menu_controls.get_popup()
	_terraingen_pop.add_item("Update Terrain Cell", 1)
	_terraingen_pop.add_item("Update Terrain Material", 2)
	_terraingen_pop.add_item("Set Collision Shape", 3)
	_terraingen_pop.add_item("Export Mesh", 4)
	
	var _splatedit_pop = _splatedit_menu_controls.get_popup()
	_splatedit_pop.add_item("Splat 0", 0)
	_splatedit_pop.add_item("Splat 1", 1)
	_splatedit_pop.add_item("Splat 2", 2)
	
	var _channel_pop = _splatchannel_options.get_popup()
	_channel_pop.add_item("Red", 0)
	_channel_pop.add_item("Green", 1)
	_channel_pop.add_item("Blue", 2)
	
	var _mode_pop = _terraingen_mode_option_control.get_popup()
	_mode_pop.add_item("Select Mode", 0)
	_mode_pop.add_item("Texture Paint Mode", 1)
	_mode_pop.add_item("Object Paint Mode", 2)
	_mode_pop.add_item("Foliage Paint Mode", 3)
	
	_terraingen_pop.connect("id_pressed", _on_terrain_option_pressed)
	_mode_pop.connect("id_pressed", _on_mode_selected)
	_splatedit_pop.connect("id_pressed", _on_splat_map_pressed)
	_channel_pop.connect("id_pressed", _on_channel_selected)
	_brush_controls.connect("value_changed", _on_brush_scale_changed)
	
#	Create custom nodes
	add_custom_type("TerraformCell", "Node3D", preload("res://addons/leonis_terraform/scripts/terrain_generator.gd"), null)

func _on_brush_scale_changed(val):
	_brush_scale = val
	if _obj and _obj.has_method("setTerrainBrushRadius"):
		_obj.call("setTerrainBrushRadius", _brush_controls.value)
	
func _on_mode_selected(id: int):
	_brush_scale = _brush_controls.value
	if _splatchannel_options.get_parent():
		remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, _splatchannel_options)
	if _brush_controls.get_parent():
		remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, _brush_controls)
	var _is_paint_mode = id == 1
	var _is_scatter_mode = id == 2
	if _is_paint_mode:
		add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, _splatchannel_options)
		add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, _brush_controls)
	elif _is_scatter_mode:
		add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, _brush_controls)
	else:
		if _splatchannel_options.get_parent():
			remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, _splatchannel_options)
		if _brush_controls.get_parent():
			remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, _brush_controls)
	if _obj and _obj.has_method("_edit_splatmap"):
		_obj.call("_edit_splatmap", _is_paint_mode, _brush_scale)
	_paint_mode = _is_paint_mode

func _forward_3d_gui_input(viewport_camera: Camera3D, event: InputEvent) -> int:
	if _paint_mode and _obj:
		if event is InputEventMouseMotion:
			_curren_mouse_pos = event.position
			_handle_gui_paint(viewport_camera, event, false)
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			var m_event := event as InputEventMouseButton
			_erase = m_event.ctrl_pressed
			if event.is_pressed():
				current_cam = viewport_camera
				_mouse_drag = true
				_draw = true
				
				_handle_gui_paint(viewport_camera, event, true)
				return EditorPlugin.AFTER_GUI_INPUT_STOP
			else:
				current_cam = null
				_mouse_drag = false
				_draw = false
		elif event is InputEventMouseMotion and _mouse_drag:
			_curren_mouse_pos = event.position
			_handle_gui_paint(viewport_camera, event, true)
			return EditorPlugin.AFTER_GUI_INPUT_STOP
	return EditorPlugin.AFTER_GUI_INPUT_PASS

func _handle_gui_paint(viewport_camera: Camera3D, event: InputEvent, draw) -> void:
	var mouse_coords = event.position
	var from = viewport_camera.project_ray_origin(event.position)
	var to = from + viewport_camera.project_ray_normal(event.position) * 1000
	var sp_state = get_tree().get_root().world_3d.direct_space_state
	var params := PhysicsRayQueryParameters3D.create(from, to)
	var result = sp_state.intersect_ray(params)
	
	if result:
		_obj.call("setTerrainBrushRadius", _brush_controls.value)
		_obj.call("_paint_texture", result.position, _erase, draw, _brush_controls.value)

func _on_splat_map_pressed(id: int):
	if _obj and _obj.has_method("_setCurrentSplat"):
		_obj.call("_setCurrentSplat", id)

func _on_channel_selected(id: int):
	if _obj and _obj.has_method("_setCurrentChannel"):
		_obj.call("_setCurrentChannel", id)

func _on_terrain_option_pressed(id : int):
	match id:
		1:
			if _obj and _obj.has_method("generate_terrain_mesh"):
				_obj.call("generate_terrain_mesh")
		2:
			if _obj and _obj.has_method("_update_terrain_material"):
				_obj.call("_update_terrain_material")
		3:
			if _obj and _obj.has_method("generate_collider"):
				_obj.call("generate_collider")
		4:
			if _obj and _obj.has_method("export_terrain_mesh"):
				_obj.call("export_terrain_mesh")

func _edit(object : Object):
	_remove_controls()
	if object is EditorTerrainNode:
		_obj = object
		add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, _terraingen_menu_controls)
		add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, _terraingen_mode_option_control)
		_terraingen_mode_option_control.select(0)
		_splatchannel_options.select(0)
		if _obj and _obj.has_method("_setCurrentChannel"):
			_obj.call("_setCurrentChannel", 0)
	else:
		_remove_controls()

func _handles(object):
	return object is EditorTerrainNode || object is EditorHeightGenNode

func _remove_controls():
	if _terraingen_mode_option_control.get_parent():
		remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, _terraingen_mode_option_control)
	if _terraingen_menu_controls.get_parent():
		remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, _terraingen_menu_controls)
	if _splatchannel_options.get_parent():
		remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, _splatchannel_options)
	if _brush_controls.get_parent():
		remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, _brush_controls)

func setBrushPosition(event: InputEvent):
	if event is InputEventMouseMotion:
		var mouse_pos = event.position
		_obj.call("handleBrushPosition", mouse_pos)

func _process(delta: float) -> void:
	if _mouse_drag and current_cam:
		var motion_event := InputEventMouseMotion.new()
		motion_event.position = _curren_mouse_pos
		_handle_gui_paint(current_cam, motion_event, true)

func _exit_tree():
	if _paint_mode:
		if _obj and _obj.has_method("_edit_splatmap"):
			_obj.call("_edit_splatmap", false, 1)
		_paint_mode = false
	_remove_controls()
