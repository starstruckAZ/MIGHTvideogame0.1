extends Node

signal sequence_completed

var current_scene = 0
var scenes = []
var can_skip = false
var current_node = null  # Track current displayed node for proper cleanup
var button_container = null  # Track button container separately

func _ready():
	# Hide any global UI elements (health bars, energy bars, score)
	hide_game_ui()
	
	# Initialize scenes array with the cutscene texts
	scenes = [
		"Honor, duty, and the blade—these are all I have ever known. The wind whispers through the trees, carrying the scent of home. But tonight… something feels different.",
		"A forbidden ritual… a force beyond my understanding. The ground trembles as the sky rips open. My blade is drawn, but against what?",
		"Light—blinding, searing. The world bends and breaks. My breath catches as I am torn from everything I know.",
		"Silence. Cold steel where trees once stood. A world unfamiliar, yet filled with danger. Where… am I?",
		"Metal warriors without honor. They do not breathe, they do not feel. Yet they hunt… and I am their prey.",
		"If this world seeks to break me, it will fail. I am samurai. I will find my way home… or die with my blade in hand."
	]
	
	# Start with logo intro without UI
	show_logo_intro()

func hide_game_ui():
	# More direct approach to hiding the GameHUD autoload
	if get_node_or_null("/root/GameHUD") != null:
		print("Found and hiding root GameHUD")
		get_node("/root/GameHUD").visible = false
	
	# Try to find specific UI elements by name that are visible in the screenshot
	var ui_elements = ["HealthBar", "ScoreBar", "EnergyBar", "HealthLabel", "ScoreLabel", "EnergyLabel"]
	for element_name in ui_elements:
		# Try multiple paths where these might exist
		var paths = [
			"/root/GameHUD/" + element_name,
			"/root/" + element_name,
			"../" + element_name,
			"/root/GameHUD/UI/" + element_name
		]
		
		for path in paths:
			var node = get_node_or_null(path)
			if node != null:
				print("Found and hiding UI element: " + path)
				node.visible = false
	
	# Also try to hide any CanvasLayer that might contain UI elements
	for i in range(get_tree().root.get_child_count()):
		var child = get_tree().root.get_child(i)
		if child is CanvasLayer and child.name != "IntroSequence" and child.name != self.name:
			print("Found and hiding CanvasLayer: " + child.name)
			child.visible = false
	
	# Fallback to try finding any UI control with these names
	for i in range(get_tree().root.get_child_count()):
		var root_child = get_tree().root.get_child(i)
		find_and_hide_ui_recursively(root_child)

func cleanup_current():
	if button_container:
		button_container.queue_free()
		button_container = null
	if current_node:
		current_node.queue_free()
		current_node = null

func show_logo_intro():
	cleanup_current()
	
	var logo = TextureRect.new()
	var logo_path = "res://Assets/LogoIntro.png"
	print("Loading logo image: " + logo_path)
	logo.texture = load(logo_path)
	logo.expand_mode = 1  # EXPAND_USE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	logo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(logo)
	current_node = logo
	
	# Fade in
	var tween = create_tween()
	tween.tween_property(logo, "modulate:a", 1.0, 1.0)
	
	# Wait 3 seconds then fade out
	await get_tree().create_timer(3.0).timeout
	tween = create_tween()
	tween.tween_property(logo, "modulate:a", 0.0, 1.0)
	await tween.finished
	
	# Show start screen instead of going directly to cutscenes
	show_start_screen()

func show_start_screen():
	cleanup_current()
	
	var start_screen = TextureRect.new()
	var start_screen_path = "res://Assets/StartScreen.png"
	print("Loading start screen image: " + start_screen_path)
	start_screen.texture = load(start_screen_path)
	start_screen.expand_mode = 1  # EXPAND_USE_SIZE
	start_screen.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	start_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(start_screen)
	current_node = start_screen
	
	# Create a more reliable button setup using CanvasLayer to ensure UI is always visible
	var canvas = CanvasLayer.new()
	add_child(canvas)
	
	# Create start and exit buttons
	button_container = VBoxContainer.new()
	button_container.size = Vector2(200, 120)
	button_container.position = Vector2((get_viewport().size.x - 200) / 2, get_viewport().size.y * 0.7)
	
	var start_button = Button.new()
	start_button.text = "Start Game"
	start_button.custom_minimum_size = Vector2(200, 50)
	# Connect using deferred call to avoid timing issues
	start_button.connect("pressed", _on_start_button_pressed.bind())
	
	var exit_button = Button.new()
	exit_button.text = "Exit"
	exit_button.custom_minimum_size = Vector2(200, 50)
	exit_button.connect("pressed", _on_exit_button_pressed.bind())
	
	button_container.add_child(start_button)
	button_container.add_child(exit_button)
	canvas.add_child(button_container)

func _on_start_button_pressed():
	print("Start button pressed") # Debug print
	cleanup_current()
	start_cutscenes()

func _on_exit_button_pressed():
	get_tree().quit()

func start_cutscenes():
	print("Starting cutscenes with text") 
	can_skip = true
	current_scene = 0
	show_next_cutscene()

func show_next_cutscene():
	print("Showing cutscene", current_scene)
	
	# Check if we've gone through all scenes
	if current_scene >= scenes.size():
		print("Cutscenes complete")
		emit_signal("sequence_completed")
		# Load MainLevel.tscn directly
		load_main_level()
		return
	
	cleanup_current()
	
	var container = Control.new()
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(container)
	current_node = container
	
	var cutscene = TextureRect.new()
	var image_path = "res://Assets/Cutscenes/Intro/" + str(current_scene + 1) + ".jpeg"
	print("Loading cutscene image: " + image_path)
	cutscene.texture = load(image_path)
	cutscene.expand_mode = 1  # EXPAND_USE_SIZE
	cutscene.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	cutscene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	container.add_child(cutscene)
	
	# Add a subtle fade-in effect for the image
	cutscene.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(cutscene, "modulate:a", 1.0, 0.5)
	
	# Create a properly positioned container for both panel and text
	var top_container = VBoxContainer.new()
	top_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	top_container.add_theme_constant_override("separation", 0)
	container.add_child(top_container)
	
	# Add an empty margin to push content down
	var margin = Control.new()
	margin.custom_minimum_size = Vector2(0, 120) # Distance from top
	top_container.add_child(margin)
	
	# Add a centered container for the panel
	var panel_container = CenterContainer.new()
	top_container.add_child(panel_container)
	
	# Add a black background panel for text
	var text_panel = Panel.new()
	text_panel.custom_minimum_size = Vector2(900, 180) # Wider and taller to fit all text
	
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0, 0, 0, 0.8) # More opaque black
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_color = Color(0.5, 0.5, 0.5) # Gray border
	panel_style.corner_radius_top_left = 5
	panel_style.corner_radius_top_right = 5
	panel_style.corner_radius_bottom_left = 5
	panel_style.corner_radius_bottom_right = 5
	text_panel.add_theme_stylebox_override("panel", panel_style)
	
	# Add panel to centered container
	panel_container.add_child(text_panel)
	
	# Create label for text
	var text_label = Label.new()
	text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# Create a custom font
	var text_font = SystemFont.new()
	text_font.font_names = ["Courier New", "Courier", "monospace"]
	text_font.font_weight = 700 # Bold
	text_label.add_theme_font_override("font", text_font)
	text_label.add_theme_font_size_override("font_size", 24)
	
	# Style for text - change to white
	text_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0)) # White text
	text_label.add_theme_constant_override("line_spacing", 8) # Keep line spacing
	
	text_label.custom_minimum_size = Vector2(850, 150) # Adjust width to fit text
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART # Enable word wrapping
	
	# Add the label to the panel with some margins
	var label_container = MarginContainer.new()
	label_container.add_theme_constant_override("margin_left", 25)
	label_container.add_theme_constant_override("margin_right", 25)
	label_container.add_theme_constant_override("margin_top", 15)
	label_container.add_theme_constant_override("margin_bottom", 15)
	text_panel.add_child(label_container)
	label_container.add_child(text_label)
	
	# Display text all at once
	text_label.text = scenes[current_scene]
	
	# Create timer for viewing time
	var timer = get_tree().create_timer(7.0) # Give more time to read the full text
	await timer.timeout
	
	# Add a fade out effect
	var fade_tween = create_tween()
	fade_tween.tween_property(container, "modulate:a", 0.0, 0.5)
	await fade_tween.finished
	
	current_scene += 1
	show_next_cutscene()

func _input(event):
	if can_skip and (event.is_action_pressed("ui_accept") 
		or event.is_action_pressed("ui_select") 
		or event.is_action_pressed("attack") 
		or event.is_action_pressed("fire") 
		or event.is_action_pressed("primary_action")):
		print("Skipping sequence")
		can_skip = false
		cleanup_current()
		emit_signal("sequence_completed")
		# Load MainLevel.tscn when skipped too
		load_main_level()

func load_main_level():
	print("Loading MainLevel.tscn")
	var err = get_tree().change_scene_to_file("res://MainLevel.tscn")
	if err != OK:
		print("Error loading MainLevel.tscn: " + str(err))
	else:
		print("Successfully changed to MainLevel.tscn")

func find_and_hide_ui_recursively(node):
	if node == null or not is_instance_valid(node):
		return
		
	# Check if this is a UI element we want to hide
	var ui_names = ["health", "score", "energy", "hud", "bar", "ui"]
	var node_name_lower = node.name.to_lower()
	
	var should_hide = false
	for ui_name in ui_names:
		if ui_name in node_name_lower:
			should_hide = true
			break
	
	if should_hide:
		print("Found and hiding UI element by name: " + node.name)
		node.visible = false
		return  # Don't need to check children if we hide the parent
	
	# Recurse into children
	for i in range(node.get_child_count()):
		find_and_hide_ui_recursively(node.get_child(i))
