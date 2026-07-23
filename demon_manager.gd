extends Node

enum DemonType
{
	FERRIC = 0,
	CHTHONIC = 1,
	INFERNAL = 2,
	SPECTRAL = 3,
	LUCIFERIAN = 4,
	PUTREFACTIOUS = 5,
	HADEL = 6,
	THAUMIC = 7,
	ENUM_COUNT = 8,
	NONE = 9
}

enum ItemType
{
	HOLY_WATER = 0,
	SALT = 1,
	IRON = 2,
	PRAYER = 3,
	ENUM_COUNT = 4
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

static func check_item_effectivness(item_type: ItemType, demon_type_1: DemonType, demon_type_2: DemonType = DemonType.NONE) -> int:
	assert(demon_type_1 != DemonType.NONE and demon_type_1 != DemonType.ENUM_COUNT)
	assert(demon_type_2 != demon_type_1 and demon_type_2 != DemonType.ENUM_COUNT)
	assert(item_type != ItemType.ENUM_COUNT)
	
	var curr_effectivness = EFFECTIVENESS_CHART[demon_type_1 * ItemType.ENUM_COUNT + item_type]
	if demon_type_2 != DemonType.NONE and demon_type_2 != demon_type_1 and demon_type_2 != DemonType.ENUM_COUNT:
		curr_effectivness += EFFECTIVENESS_CHART[demon_type_2 * ItemType.ENUM_COUNT + item_type]
	
	return curr_effectivness
