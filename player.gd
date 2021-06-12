extends KinematicBody2D

export (int) var acceleration = 100
export (int) var max_force = 1000
export (int) var max_speed = 100
export (int) var jump_speed = -400
export (int) var gravity = 120
export (int) var max_distance = 100

var velocity = Vector2()
var jumping = false
var jumped = false
var boulder = null
var tether = Vector2()
var up_direction = Vector2(0, -1)
var pulled = false

const Chain = preload("res://Chain.tscn")
var chains = []

func _ready():
	if get_parent().has_node("Boulder"):
		print("boulder found")
		boulder = get_parent().get_child(1)
		for i in range(20):
			chains.append(Chain.instance())
			print(chains[i-1])
			add_child(chains[i-1])

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
		chain.set_position(global_position)
		i += 1

func _physics_process(delta):
	if tether.length() > max_distance:
		pulled = true
		
	if tether.length() * 2 < max_distance and is_on_floor():
		pulled = false
	
	if is_on_floor() and not jumped:
		jumping = false
		velocity.y = 0
	
	if abs(velocity.x) > max_speed:
		velocity = velocity.normalized() * max_speed
	
	if pulled:
		velocity += tether
		boulder.apply_central_impulse(tether.normalized() * -1 * pow((tether.length() - max_distance), 2))
	
	var collision = move_and_collide(velocity * delta)
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
		move_and_collide(remaining_movement) # move the sprite along the slope
	
	move_and_slide(Vector2(0,0), up_direction)
	jumped = false
