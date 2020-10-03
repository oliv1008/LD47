extends Node2D

var orbiting = false
export (float) var speed # rotation speed (in radians)
var gaucheDroite = true
var rotate_speed
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	rotate_speed = rng.randfn(0, 0.05)
	set_process(true)
	
func _physics_process(delta):
	if gaucheDroite == true:
		$Pivot.rotation += speed * delta
	else:
		$Pivot.rotation -= speed * delta
	$Sprite.rotation += rotate_speed * delta

func _on_Gravity_body_entered(body):
	if (body.is_in_group("joueur")):
		$Pivot/OrbitPosition.global_position = body.global_position 
		body.orbit($Pivot/OrbitPosition, calculate_rotation_direction(body))
		body.planete = self
		
func calculate_rotation_direction(player):
	var vector_to_planet = player.position.direction_to(position)
	var tangent1 = vector_to_planet.tangent()
	var tangent2 = -vector_to_planet.tangent()
	var player_direction = player.movement.normalized()
	var angle1 = player_direction.angle_to(tangent1)
	var angle2 = player_direction.angle_to(tangent2)
	if abs(angle1) > abs(angle2):
		gaucheDroite = false
		return -1
	else:
		gaucheDroite = true
		return 1
