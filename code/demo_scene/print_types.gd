extends RefCounted

# For getting an external list of item efectivenesses 


enum DemonType {
	FERRIC = 1,
	CHTHONIC = 2,
	INFERNAL = 4,
	SPECTRAL = 8,
	LUCIFERIAN = 16,
	PUTREFACTIOUS = 32,
	HADEL = 64,
	THAUMIC = 128,
}

enum ItemType {
	WATER,
	SALT,
	IRON,
	PRAYER,
}

const TYPE_REACTIONS : Dictionary[DemonType, Vector4i] = {
	DemonType.FERRIC: 		Vector4i(1, 0, -1, 0),
	DemonType.CHTHONIC: 	Vector4i(0, -1, 0, 1),
	DemonType.INFERNAL: 	Vector4i(1, -1, 0, 0),
	DemonType.SPECTRAL: 	Vector4i(-1, 0, 0, 1),
	DemonType.LUCIFERIAN: 	Vector4i(0, 1, -1, 0),
	DemonType.PUTREFACTIOUS:Vector4i(0, 1, 0, -1),
	DemonType.HADEL: 		Vector4i(-1, 0, 1, 0),
	DemonType.THAUMIC: 		Vector4i(0, 0, 1, -1),
}


func print_types() -> void:
	var combo_types: Dictionary[int, Vector4]
	for type_1 in TYPE_REACTIONS.keys():
		for type_2 in TYPE_REACTIONS.keys():
			combo_types[type_1 + type_2] = TYPE_REACTIONS[type_1] + TYPE_REACTIONS[type_2]
	for type_1 in combo_types.keys():
		print(type_1, combo_types[type_1])
	print(combo_types.size())
