@tool
class_name EditorTerrainNode 
extends Node3D

## 3D Terrain Node for generating terrain meshes

@export_category("Terrain Configuration")
@export var height_map_texture 	: Texture2D
@export_range(512, 1024, 128) var cell_size : int = 1024
@export var max_height 		: float = 10
@export var clear_stored_meshes	: bool
@export var enable_collision : bool = true
var subdivision_steps : int

@export_category("Texture Slots")
@export var splat_0 : splatResource
@export var splat_1 : splatResource
@export var splat_2 : splatResource

@export_category("Object Scattering")
@export var scatter_map : Texture2D

# Terrain Meshes for exporting
var _terrain_lod_0_mesh : Mesh
var _terrain_lod_1_mesh : Mesh
var _terrain_lod_2_mesh : Mesh
var _terrain_lod_3_mesh : Mesh

# Terrain Mesh instances for instancing
var _terrain_lod_0 : MeshInstance3D
var _terrain_lod_1 : MeshInstance3D
var _terrain_lod_2 : MeshInstance3D
var _terrain_lod_3 : MeshInstance3D

var _terrain_material 		: ShaderMaterial
var _terrain_static_body 	: StaticBody3D

var _export_location = "res://content/terraform/"

# SplatMaps and color channels for edit mode
var _currentSplat	= 0
var _currentChannel = 0
var _active_colour : Color

var _brush_decal : Decal
var _brush_radius = 1

func _ready():
	await get_tree().process_frame
#	Only generate a mesh if the node has no children
	if get_child_count() == 0:
		generate_terrain_mesh()

func _createBlankImage():
	var _img = Image.new().create(256, 256, false, Image.FORMAT_RGBA8)
	_img.fill(Color.BLACK)
	return _img

func generateSplatMap(splatRes : splatResource):
	splatRes.splatMap = ImageTexture.create_from_image(_createBlankImage())
	
func generateScatterMap():
	scatter_map = ImageTexture.create_from_image(_createBlankImage())

func _handleSplatMaps():
	if splat_0 == null:
		splat_0 = splatResource.new()
	if splat_1 == null:
		splat_1 = splatResource.new()
	if splat_2 == null:
		splat_2 = splatResource.new()
	if splat_0 != null && splat_0.splatMap == null:
		generateSplatMap(splat_0)
	if splat_1 != null && splat_1.splatMap == null:
		generateSplatMap(splat_1)
	if splat_2 != null && splat_2.splatMap == null:
		generateSplatMap(splat_2)

func generate_terrain_mesh():
	subdivision_steps = cell_size/128
	if get_child_count() > 0:
		for child in get_children():
			child.free()
	if height_map_texture == null:
		height_map_texture = ImageTexture.create_from_image(_createBlankImage())
	if scatter_map == null:
		scatter_map = ImageTexture.create_from_image(_createBlankImage())
	_handleSplatMaps()
	_configure_material()
	_generate_terrain_meshses()
	_load_terrain_configs()
	_add_children()
	
func generate_collider():
	print("TODO")
	
func _add_children():
	var lod_0_root = StaticBody3D.new()
	lod_0_root.add_child(_terrain_lod_0)
	add_child(lod_0_root)
	add_child(_terrain_lod_1)
	add_child(_terrain_lod_2)
	add_child(_terrain_lod_3)

func _updateSplatMaps():
	var _splats = {
		"splat_0":splat_0.splatMap,
		"splat_1":splat_1.splatMap,
		"splat_2":splat_2.splatMap
	}
	for i in _splats:
		_terrain_material.set_shader_parameter(i, _splats[i])
		
func _update_terrain_material():
	_configure_material()
	_terrain_lod_0.material_override = _terrain_material
	_terrain_lod_1.material_override = _terrain_material
	_terrain_lod_2.material_override = _terrain_material
	_terrain_lod_3.material_override = _terrain_material

func _configure_material():
	_terrain_material = ShaderMaterial.new()
	_terrain_material.shader = preload("res://addons/leonis_terraform/shaders/terrain_shader.gdshader")
#	Set a placeholder default texture when a cell is created/slot is null
	if splat_0.zeroTexture == null:
		var _placeholder_texture = preload("res://addons/leonis_terraform/resources/tex_terrain_blank.png")
		splat_0.zeroTexture = _placeholder_texture
	var _node_shader_params = {
		"splat_0":splat_0.splatMap, "splat_1":splat_1.splatMap, "splat_2":splat_2.splatMap,
#		------------------------------Splat_0 Textures------------------------------
		"splat_0_0":splat_0.zeroTexture, 	"splat_0_0_uv":splat_0.zeroUv,
		"splat_0_r":splat_0.redTexture, 	"splat_0_r_uv":splat_0.redUv,
		"splat_0_g":splat_0.greenTexture, 	"splat_0_g_uv":splat_0.greenUv,
		"splat_0_b":splat_0.blueTexture, 	"splat_0_b_uv":splat_0.blueUv,
#		------------------------------Splat_1 Textures------------------------------
		"splat_1_0":splat_1.zeroTexture, 	"splat_1_0_uv":splat_1.zeroUv,
		"splat_1_r":splat_1.redTexture, 	"splat_1_r_uv":splat_1.redUv,
		"splat_1_g":splat_1.greenTexture, 	"splat_1_g_uv":splat_1.greenUv,
		"splat_1_b":splat_1.blueTexture, 	"splat_1_b_uv":splat_1.blueUv,
#		------------------------------Splat_2 Textures------------------------------
		"splat_2_0":splat_2.zeroTexture, 	"splat_2_0_uv":splat_2.zeroUv,
		"splat_2_r":splat_2.redTexture, 	"splat_2_r_uv":splat_2.redUv,
		"splat_2_g":splat_2.greenTexture, 	"splat_2_g_uv":splat_2.greenUv,
		"splat_2_b":splat_2.blueTexture, 	"splat_2_b_uv":splat_2.blueUv,
	}
	for i in _node_shader_params:
		_terrain_material.set_shader_parameter(i, _node_shader_params[i])

func _generate_lod_mesh(verts : int, height_map_tex : Texture2D) -> ArrayMesh:
	var arr_mesh : ArrayMesh = ArrayMesh.new()
	var surf = SurfaceTool.new()
	var original_img = height_map_tex.get_image()
	var final_y_coord
	surf.begin(Mesh.PRIMITIVE_TRIANGLES)
	for z in range(verts + 1):
		for x in range(verts + 1):
			
			var uv = Vector2(
				float(x) / verts,
				float(z) / verts
			)
			var img_coords = Vector2(
				original_img.get_width() - 1, 
				original_img.get_height() - 1
			)
			var pix_coords = Vector2(
				clamp(int(uv.x * img_coords.x), 0.0, img_coords.x), 
				clamp(int(uv.y * img_coords.y), 0.0, img_coords.y)
			)
			var y = original_img.get_pixel(pix_coords.x, pix_coords.y).r * max_height * 4
			surf.set_uv(uv)
			var vert_vec3 = Vector3(
				x * (cell_size / verts),
				y,
				z * (cell_size / verts)
			)
			surf.add_vertex(vert_vec3)
	
	for z in range(verts):
		for x in range(verts):
			var top_left = z * (verts+1) + x
			var top_right = top_left + 1
			var bottom_left = (z + 1) * (verts+1) + x
			var bottom_right = bottom_left + 1
			var _surf_vertices = [top_left, top_right, bottom_left, top_right, bottom_right, bottom_left]
			for i in _surf_vertices:
				surf.add_index(i)
	surf.generate_normals()
	arr_mesh = surf.commit()
	return arr_mesh
	
func _generate_terrain_meshses():
	if _terrain_lod_0_mesh == null or clear_stored_meshes:
		_terrain_lod_0_mesh = _generate_lod_mesh(256, height_map_texture)
	if _terrain_lod_1_mesh == null or clear_stored_meshes:
		_terrain_lod_1_mesh = _generate_lod_mesh(128, height_map_texture)
	if _terrain_lod_2_mesh == null or clear_stored_meshes:
		_terrain_lod_2_mesh = _generate_lod_mesh(64, height_map_texture)
	if _terrain_lod_3_mesh == null or clear_stored_meshes:
		_terrain_lod_3_mesh = _generate_lod_mesh(16, height_map_texture)

func _load_terrain_configs():
	_config_lod_0()
	_config_lod_1()
	_config_lod_2()
	_config_lod_3()

#------------------------------DRY------------------------------#
func _config_lod_0():
	_terrain_lod_0 = MeshInstance3D.new()
	_terrain_lod_0.name = "TerrainCellLOD0"
	
	_terrain_lod_0.visibility_range_end = cell_size/2 + 128
	_terrain_lod_0.mesh = _terrain_lod_0_mesh
	_terrain_lod_0.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED
	if enable_collision:
		_terrain_lod_0.create_trimesh_collision()
	_terrain_lod_0.material_override = _terrain_material
	_terrain_static_body = _terrain_lod_0.get_child(0)

func _config_lod_1():
	_terrain_lod_1 = MeshInstance3D.new()
	_terrain_lod_1.name = "TerrainCellLOD1"
	_terrain_lod_1.visibility_range_begin = cell_size/2 + 128
	_terrain_lod_1.visibility_range_end = cell_size * 2
	_terrain_lod_1.mesh = _terrain_lod_1_mesh
	_terrain_lod_1.material_override = _terrain_material
	
func _config_lod_2():
	_terrain_lod_2 = MeshInstance3D.new()
	_terrain_lod_2.name = "TerrainCellLOD2"
	_terrain_lod_2.visibility_range_begin = cell_size * 2
	_terrain_lod_2.visibility_range_end = cell_size * 3
	_terrain_lod_2.mesh = _terrain_lod_2_mesh
	_terrain_lod_2.material_override = _terrain_material

func _config_lod_3():
	_terrain_lod_3 = MeshInstance3D.new()
	_terrain_lod_3.name = "TerrainCellLOD3"
	_terrain_lod_3.visibility_range_begin = cell_size * 3
	_terrain_lod_3.visibility_range_end = cell_size * 6
	_terrain_lod_3.mesh = _terrain_lod_3_mesh
	_terrain_lod_3.material_override = _terrain_material
#---------------------------------------------------------------#

func export_terrain_mesh():
	var _export_mesh_instance = MeshInstance3D.new()
	_export_mesh_instance.name = "ExportedTerraformCell"
	_export_mesh_instance.mesh = _terrain_lod_0_mesh
	var _temp_export_scene = PackedScene.new()
	var _scene = _temp_export_scene.pack(_export_mesh_instance)
	if _scene == OK:
		print("Scene setup complete!")
		var _location = "res://content/terraform/"+ name +"_export.tscn"
#		TODO: Validate save location before saving
		var err = ResourceSaver.save(_temp_export_scene, _location)
		if err == OK:
			print("Scene exported successfully!")
		else:
			print(err)

func _configure_terrain_brush():
	if _brush_decal == null:
		_brush_decal = Decal.new()
	_brush_decal.texture_albedo = preload("res://addons/leonis_terraform/resources/terrain_brush.png")
	_brush_decal.modulate = Color(0.8, 0.8, 0.8, 0.3)
	_brush_decal.size = Vector3(_brush_radius*10, 20, _brush_radius*10)
	_brush_decal.name = "terrainBrush"

func setTerrainBrushRadius(new_radius : int):
	_brush_radius = new_radius
	_brush_decal.size = Vector3(_brush_radius*10, 20, _brush_radius*10)

func _remove_brush():
	for i in get_children():
			if i.name == "terrainBrush":
				i.queue_free()

func _edit_splatmap(edit_active:bool, brush_scale : int):
	_brush_radius = brush_scale
	if edit_active:
	#	Ensure SplatMaps exist before editing
		_handleSplatMaps()
		_configure_terrain_brush()
		_remove_brush()
		add_child(_brush_decal)
	else:
		_remove_brush()

func handleBrushPosition(mouse_position:Vector3):
	_brush_decal.position = mouse_position

func _paint_texture(mouse_position:Vector3, erase_mode : bool, draw_mode : bool, brush_scale : int):
#	Ensure SplatMaps exist before editing
	_handleSplatMaps()
	_brush_radius = brush_scale
	var _brush_offset = _brush_radius*5
	var _node_relative_position = Vector3(
		clamp(mouse_position.x, position.x + _brush_offset, (position.x + cell_size) - _brush_offset),
		mouse_position.y,
		clamp(mouse_position.z, position.z + _brush_offset, (position.z + cell_size) - _brush_offset)
	)
	handleBrushPosition(_node_relative_position)
	var _selected_colour : Color
	if draw_mode:
		var _splatMaps = {0:splat_0, 1:splat_1, 2:splat_2}
		var uv_coords = Vector2((mouse_position.x - position.x)/cell_size, (mouse_position.z - position.z)/cell_size)
		var splat_coords = Vector2(uv_coords.x * 256, uv_coords.y * 256)
		var active_splat : splatResource = _splatMaps[_currentSplat]
		var img = active_splat.splatMap.get_image()
		var new_img = img.duplicate()
		_brush_decal.modulate.a = 0.3
		_selected_colour = Color.BLACK if erase_mode else _active_colour
		
		if _brush_radius == 1:
			new_img.set_pixel(splat_coords.x, splat_coords.y, _selected_colour)
		else:
			for ix in range(-_brush_radius, _brush_radius+1):
				for iy in range(-_brush_radius, _brush_radius+1):
					if (ix * ix) + (iy * iy) <= _brush_radius * _brush_radius:
						var _paint_coords = Vector2(
							clamp(splat_coords.x + ix, 0.0, splat_0.splatMap.get_width()-1),
							clamp(splat_coords.y + iy, 0.0, splat_0.splatMap.get_height() - 1)
						)
						new_img.set_pixel(_paint_coords.x, _paint_coords.y, _selected_colour)
		active_splat.splatMap = ImageTexture.new().create_from_image(new_img)
		_updateSplatMaps()
	else:
		_brush_decal.modulate.a = 0.25
	_brush_decal.visible = false if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else true

func _setCurrentChannel(new_channel:int):
	var _colourChannels = {0:Color.RED, 1:Color.GREEN, 2:Color.BLUE}
	_currentChannel = new_channel
	_active_colour = _colourChannels[_currentChannel]

func _setCurrentSplat(new_splat:int):
	var _splatMaps = {0:splat_0, 1:splat_1, 2:splat_2}
	_currentSplat = new_splat
