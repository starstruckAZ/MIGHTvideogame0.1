func jump():
	if is_on_floor():
		velocity.y = -jump_force
		animation_tree["parameters/conditions/is_jumping"] = true
		animation_tree["parameters/conditions/is_falling"] = false
		animation_tree["parameters/conditions/is_running"] = false
		animation_tree["parameters/conditions/is_idle"] = false
		
		# Play jump sound effect
		if get_node_or_null("/root/AudioManager"):
			get_node("/root/AudioManager").play_sound("player_jump", 0.7, 1.0 + randf() * 0.1)

func dash():
	if can_dash and not is_dashing:
		is_dashing = true
		dash_timer = dash_duration
		can_dash = false
		dash_cooldown_timer = dash_cooldown
		
		# Store initial velocity direction for dash
		dash_direction = Vector2(last_direction.x, 0).normalized()
		if dash_direction == Vector2.ZERO:
			dash_direction = Vector2.RIGHT * sprite.scale.x
		
		# Play dash sound effect
		if get_node_or_null("/root/AudioManager"):
			get_node("/root/AudioManager").play_sound("player_dash", 0.8, 1.0)
		
		animation_tree["parameters/conditions/is_dashing"] = true 