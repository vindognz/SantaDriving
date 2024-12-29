extends RigidBody2D

var presentScene = preload("res://scenes/present.tscn")

const SPEED = 3
const MAXt = 0.1

var t = 0.1
var lastRot = 0
var lastDir = Vector2.RIGHT
var friction = 2

var presentDropping = false

func _process(delta: float) -> void:
	
	var direction := Input.get_vector("left", "right", "forward", "reverse")
	
	if Input.is_action_pressed("drift"):
		friction = 0.5
		linear_damp = 1
	else:
		friction = 2
		linear_damp = 5
	
	if Input.is_action_just_pressed("drop-present") and not presentDropping:
		presentDropping = true
		
		dropAPresent()
	
	if presentDropping:
		var thePresent = get_tree().get_nodes_in_group("present")[0]
		
		print(getTargetHouseDist(thePresent))
		
		if thePresent.scale.x <= 0.5:
			presentDropping = false
			thePresent.remove_from_group("present")
			
			
			
			thePresent.queue_free()
			# increase the score by some number based on how far it is from the 'target house'
		
	if direction.length() < 0.1:
		direction = lastDir
	
	direction = direction.normalized()
	apply_force(direction*SPEED/mass)
	
	if lastRot - atan2(direction.y, direction.x) > PI:
		lastRot -= 2*PI
		
	if lastRot - atan2(direction.y, direction.x) < -PI:
		lastRot += 2*PI

	t = min(linear_velocity.length() / 250, 1) * MAXt
	rotation = lastRot * (1-t) + atan2(direction.y, direction.x) * t
	
	lastRot = rotation
	lastDir = direction
	
	applyFriction(direction, linear_velocity, delta)

func applyFriction(direction, velocity, deltaTime):
	apply_force(((direction.rotated(PI / 2).dot(velocity.normalized()) * -friction * velocity.length()) * direction.rotated(PI / 2) * deltaTime)/mass)

func dropAPresent():
	var presentInstance = presentScene.instantiate()
	$BackMarker.add_child(presentInstance)
	presentInstance.add_to_group("present")
	await get_tree().create_timer(0.1).timeout
	presentInstance.reparent($"..")

func getTargetHouseDist(present):
	var targetHouse = get_tree().get_nodes_in_group("targetHouse")[0]
	var pxDistance = present.position.distance_to(targetHouse.position)
	return pxDistance/10