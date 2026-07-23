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


func print_types() -> void:
	var combo_types: Dictionary[int, Vector4]
	for type_1 in DemonManager.DEMON_TYPE_EFFECTIVENESS.keys():
		for type_2 in DemonManager.DEMON_TYPE_EFFECTIVENESS.keys():
			combo_types[type_1 + type_2] = DemonManager.DEMON_TYPE_EFFECTIVENESS[type_1] + DemonManager.DEMON_TYPE_EFFECTIVENESS[type_2]
	for type_1 in combo_types.keys():
		print(type_1, combo_types[type_1])
	print(combo_types.size())
