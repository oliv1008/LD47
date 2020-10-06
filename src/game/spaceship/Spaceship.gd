extends KinematicBody2D

var orbited = false
var positionToFollow
var lastPositionToFollow
const MOVE_SPEED = 500
var velocity = Vector2()
var applied_forces = Vector2()
const ACCELERATION = 0.03
var planete
var speed = 0
var movement = Vector2(0, 0)
var direction_tangent = 1
var thrusters_playing = false
var just_reseted:bool = false

func _physics_process(delta):
	if orbited == false:
		physics_process_in_movement(delta)
	
	if orbited == true:
		physics_process_in_orbit(delta)
			
func physics_process_in_movement(delta):
	if Input.is_action_pressed("space"):
		$AnimationPlayer.play("Moving")
		if thrusters_playing == false:
			SoundManager.play_se("res://assets/son/Sound effects/thrusters.wav")
			thrusters_playing = true
		$trail/Particles2D.emitting = true
		$trail2/Particles2D.emitting = true
		speed += ACCELERATION
		speed = clamp(speed, 0, 1)
	else:
		$AnimationPlayer.play("Idle")
		$trail/Particles2D.emitting = false
		$trail2/Particles2D.emitting = false
		stop_thrusters()
	var movedir = Vector2(1,0).rotated(rotation)
	velocity = speed * movedir
	movement = ((velocity * MOVE_SPEED)+ applied_forces) * delta 
	look_at(position + movement)
	var collision = move_and_collide(movement)
	if collision != null:
		set_physics_process(false)
		$AnimationPlayer.play("Death")
	applied_forces = Vector2(0,0)
	if Input.is_action_just_pressed("R"):
		just_reseted = true
		Events.emit_signal("camera_turbo_mode")
		Events.emit_signal("reset")
	
func physics_process_in_orbit(delta):
	$AnimationPlayer.play("Idle")
	$trail/Particles2D.emitting = false
	$trail2/Particles2D.emitting = false
	speed = 0
	self.position = positionToFollow.global_position
	var vect = position.direction_to(planete.position)
	var tangent = vect.tangent() * 50
	
	var position_to_look_at = position + tangent * direction_tangent
	look_at(position_to_look_at)
	
	if Input.is_action_just_pressed("space"):
		orbited = false
		lastPositionToFollow = positionToFollow
		positionToFollow = null
		movement = ((tangent.normalized() * MOVE_SPEED/2)+ applied_forces) * delta 
		var collision = move_and_collide(movement)
		if collision != null:
			set_physics_process(false)
			$AnimationPlayer.play("Death")
		speed = 0.5
		Events.emit_signal("player_leave_orbit")
	
	if Input.is_action_just_pressed("R"):
		just_reseted = true
		Events.emit_signal("camera_turbo_mode")
		Events.emit_signal("reset")

func death():
	just_reseted = true
	applied_forces = Vector2(0, 0)
	orbited = false
	Events.emit_signal("player_death")

func orbit(planete_param, toFollow , direction):
	if planete_param != planete or just_reseted == true:
		just_reseted = false
		stop_thrusters()
		planete = planete_param
		lastPositionToFollow = positionToFollow
		positionToFollow = toFollow
		direction_tangent = direction
		orbited = true
		Events.emit_signal("player_enter_orbit", planete_param.global_position)

func _on_VisibilityNotifier2D_screen_exited():
	if $AnimationPlayer.current_animation != "Death" and (position.x < get_parent().get_node("LevelLimits/Position2DLeft").position.x or position.x > get_parent().get_node("LevelLimits/Position2DRight").position.x or position.y < get_parent().get_node("LevelLimits/Position2DTop").position.y or position.y > get_parent().get_node("LevelLimits/Position2DBottom").position.y):
		set_physics_process(false)
		$AnimationPlayer.play("Death")

func stop_thrusters():
	if thrusters_playing == true:
		SoundManager.stop("res://assets/son/Sound effects/thrusters.wav")
		thrusters_playing = false

func bruit_explosion():
	SoundManager.play_se("res://assets/son/Sound effects/explosion.wav")
