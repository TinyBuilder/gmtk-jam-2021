extends KinematicBody2D

export (int) var acceleration = 100
export (int) var max_force = 1700
export (int) var max_speed = 100
export (int) var jump_speed = -400
export (int) var gravity = 50
export (int) var max_distance = 200

var velocity = Vector2()
var jumping = false
var jumped = false
var boulder = null
var tether = Vector2()
var up_direction = Vector2(0, -1)
var pulled = false
var pulling = false
var push_power = 0
var pushing = false

const Chain = preload("res://Chain.tscn")
var chains = []

func _ready():
	if get_parent().has_node("Boulder"):
		print("boulder found")
		boulder = get_parent().get_child(1)
		boulder.set_friction(1)
		for i in range(20):
			chains.append(Chain.instance())
			print(chains[i-1])
			add_child(chains[i-1])

func kill():
	pass

func get_input():
	var right = Input.is_action_pressed('ui_right')
	var left = Input.is_action_pressed('ui_left')
	var jump = Input.is_action_just_pressed('ui_select')
	
	if velocity.x != 0 and not pulled:
		velocity.x -= velocity.x / abs(velocity.x) * acceleration
	
	if right:
		velocity.x += acceleration
	if left:
		velocity.x -= acceleration
	if jump and not jumping and is_on_floor():
		jumped = true
		jumping = true
		velocity.y = jump_speed
	else:
		velocity.y += gravity

func _process(delta):
	get_input()
	tether = boulder.global_position - global_position
	var i = 1
	for chain in chains:
		chain.set_position(tether / 20 * i)
		i += 1

func _physics_process(delta):
#	if tether.length() > max_distance and boulder.get_linear_velocity().length() > max_speed:
#		pulled = true
#	elif tether.length() > max_distance:
#		pulling = true
#
	if abs(velocity.x) > max_speed and not pulled:
		velocity = velocity.normalized() * max_speed
#
	if is_on_floor() and not jumped:
		jumping = false
		velocity.y = 0
#
#	if pulled:
#		velocity += tether
#
#	if pulling:
#		boulder.apply_central_impulse(tether.normalized() * -1 * max_force)
#		velocity.x = 0
#
	var collision = move_and_collide(velocity * delta, false)

	if collision and collision.collider == boulder and not pulled and is_on_floor():
		pushing = true
	
	if collision:
		
		# get collision info
		var normal = collision.normal
		var remainder = collision.remainder
		var horizontal_movement = abs(remainder.x)

		# reset y vel so it doesn't keep accumulating
		velocity.y = Vector2(0, velocity.y).slide(normal).y
		
		# get movement vector along slope
		var remaining_movement = remainder.slide(normal) # get projection of remainder on slope
		remaining_movement = remaining_movement.normalized()  # normalize projection
		remaining_movement *= horizontal_movement # scale projection to horizontal distance
		collision = move_and_collide(remaining_movement, false) # move the sprite along the slope
		
		if collision and collision.collider == boulder and not pulled and is_on_floor():
			pushing = true
	
	if pushing:
		push_power += 10
		if push_power > max_force:
			push_power = max_force
		boulder.apply_central_impulse(tether.normalized() * push_power)
	else:
		push_power -= 5
	
	move_and_slide(Vector2(0,0), up_direction)
	jumped = false
	pushing = false
	pulled = false
	pulling = false
