extends Node2D

class_name CargoStorage

signal changed

export var stored_cargo: Array
var locked_indexes =  []
onready var cargo_helper = $"/root/CargoHelper"

func initialize(initial_storage: PoolStringArray):
	for type in initial_storage:
		stored_cargo.append(cargo_helper.create_cargo(type))

	return self

func add(to_add: Cargo):
	stored_cargo[get_empty_space()] = to_add
	storage_updated()
	
func remove_cargo(to_remove: Cargo):
	remove_index(stored_cargo.find(to_remove))
	
func remove_type(type: String):
	remove_index(find_unlocked(type))
	
func remove_index(index: int):
	stored_cargo[index] = null
	storage_updated()

func has(cargo_type: String):
	return find_unlocked(cargo_type) != -1
	
func has_empty_space():
	return get_empty_space() != -1

func get_empty_space():
	return find_unlocked(null)

func find_unlocked(cargo_type):
	for index in range(len(stored_cargo)):
		if !locked_indexes.has(index) \
			and (stored_cargo[index] != null and cargo_type != null \
				and (stored_cargo[index] as Cargo).is_type(cargo_type)) \
			or (stored_cargo[index] == null and cargo_type == null):

			return index

	return -1

func exchange(cargo_type:String, to: CargoStorage):
	var exchanged = false
	if to.has_empty_space():
		var index = find_unlocked(cargo_type)
		if index != -1:
			var c = stored_cargo[index] as Cargo
			to.add(c)
			remove_cargo(c)

		return true
	
	return exchanged

func set_locked(index: int, locked: bool):
	if locked:
		locked_indexes.append(index)
	else:
		locked_indexes.erase(index)

	locked_indexes.sort()
	locked_indexes.invert()

func storage_updated():
	emit_signal("changed")
