extends Node2D

@onready var spawnregion: NavigationRegion2D = $spawnreg
@onready var nav_region: NavigationRegion2D = $Navigation

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

@export var random_buildings: Array[PackedScene] = [
	preload("res://Scenes/map/spawnables/box.tscn"),
	preload("res://Scenes/map/spawnables/wall.tscn"),
	preload("res://Scenes/map/spawnables/square.tscn"),
	preload("res://Scenes/map/spawnables/tri.tscn")
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Map.gd ready!")
	
func generate_map() -> void:
	if random_buildings.is_empty():
		print("empty random buildings")
		return
	
	var randcount: int = rng.randi_range(125, 150)
	for i in randcount:
		var randoms: PackedScene = random_buildings.pick_random()
		var building: Node2D = randoms.instantiate()
		$Navigation.add_child(building)
		
		var atts: int = 0
		while atts < 150:
			var random_pos: Vector2 = Vector2(rng.randf_range(-3000, 3000), rng.randf_range(-3000, 3000))
			
			building.position = random_pos
			building.rotate(rng.randi_range(0, 360))
			await get_tree().physics_frame
			
			var hitbox: Area2D = building.get_node("Hitbox")
			var hit: bool = false
			
			if !hitbox.get_overlapping_areas().is_empty():
				print("Making contact, finding new pos")
				atts += 1
				continue
			else: 
				print("spawning at " + str(random_pos))
				break
		
		if (atts >= 150):
			# after 150 attempts
			print("Failed after max attempts! Discarding" + str(randoms))
			random_buildings.erase(randoms)
			building.free()
		
		continue
