class_name DemonManager extends RefCounted


const DEMON_TYPE_EFFECTIVENESS : Dictionary[ID.DemonType, Vector4i] = {
	ID.DemonType.FERRIC: Vector4i(1, 0, -1, 0),
	ID.DemonType.CHTHONIC: Vector4i(0, -1, 0, 1),
	ID.DemonType.INFERNAL: Vector4i(1, -1, 0, 0),
	ID.DemonType.SPECTRAL: Vector4i(-1, 0, 0, 1),
	ID.DemonType.LUCIFERIAN: Vector4i(0, 1, -1, 0),
	ID.DemonType.PUTREFACTIOUS:Vector4i(0, 1, 0, -1),
	ID.DemonType.HADEL: Vector4i(-1, 0, 1, 0),
	ID.DemonType.THAUMIC: Vector4i(0, 0, 1, -1),
}

const TYPE_TO_STRING : Dictionary[ID.DemonType, String] = {
	ID.DemonType.FERRIC: "FERRIC",
	ID.DemonType.CHTHONIC: "CHTHONIC",
	ID.DemonType.INFERNAL: "INFERNAL",
	ID.DemonType.SPECTRAL: "SPECTRAL",
	ID.DemonType.LUCIFERIAN: "LUCIFERIAN",
	ID.DemonType.PUTREFACTIOUS:"PUTREFACTIOUS",
	ID.DemonType.HADEL: "HADEL",
	ID.DemonType.THAUMIC: "THAUMIC",
}

# 8 demons w/ 4 items = 36
# 0 = normal; -1 = not effective; 1 = very effective
const EFFECTIVENESS_CHART = [
	 1,  0, -1,  0, # FERRIC
	 0, -1,  0,  1, # CHTHONIC
	 1, -1,  0,  0, # INFERNAL
	-1,  0,  0,  1, # SPECTRAL
	 0,  1, -1,  0, # LUCIFERIAN
	 0,  1,  0, -1, # PUTREFACTIOUS
	-1,  0,  1,  0, # HADEL
	 0,  0,  1, -1, # THAUMIC
]

static func check_item_effectivness(item_type: ID.Item, demon_type_1: ID.DemonType, demon_type_2: ID.DemonType = ID.DemonType.NONE) -> int:
	assert(demon_type_1 != ID.DemonType.NONE and demon_type_1 != ID.DemonType.ENUM_COUNT)
	assert(demon_type_2 != demon_type_1 and demon_type_2 != ID.DemonType.ENUM_COUNT)
	assert(item_type != ID.Item.ENUM_COUNT)
	
	var curr_effectivness = EFFECTIVENESS_CHART[demon_type_1 * ID.Item.ENUM_COUNT + item_type]
	if demon_type_2 != ID.DemonType.NONE and demon_type_2 != demon_type_1 and demon_type_2 != ID.DemonType.ENUM_COUNT:
		curr_effectivness += EFFECTIVENESS_CHART[demon_type_2 * ID.Item.ENUM_COUNT + item_type]
	
	return curr_effectivness


static func get_random_demon() -> Dictionary:
	var demon: Dictionary
	demon.type_1 = randi_range(0, ID.DemonType.ENUM_COUNT-1)
	demon.type_2 = randi_range(0, ID.DemonType.ENUM_COUNT-1)
	demon.item_effectiveness = DEMON_TYPE_EFFECTIVENESS[demon.type_1] + DEMON_TYPE_EFFECTIVENESS[demon.type_2]
	return demon
