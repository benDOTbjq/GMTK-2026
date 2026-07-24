class_name ID extends RefCounted

enum DemonType {
	FERRIC = 0,
	CELESTIAL = 1,
	INFERNAL = 2,
	SPECTRAL = 3,
	LUCIFERIAN = 4,
	CARNAL = 5,
	ABYSSAL = 6,
	FAEIC = 7,
	ENUM_COUNT = 8,
	NONE = 9
}

enum Item {
	HOLY_WATER = 0,
	SALT = 1,
	IRON = 2,
	PRAYER = 3,
	ENUM_COUNT = 4
}

enum CameraMode {
	TABLE,
	SHELF,
	BOOK
}

enum Page {
	NULL,
	CANDLE,
	DEMON,
	TYPE_CHART,
	PENTAGRAM,
}

enum SFX {
	NULL,
	BOOK_OPEN,
	BOOK_CLOSE,
	PAGE_LEFT,
	PAGE_RIGHT,
	WOOSH,
}

enum Ambience {
	NULL,
	DEFAULT,
}


const SFX_STRING: Dictionary[SFX, String] = {
	SFX.NULL: "NULL",
	SFX.BOOK_OPEN: "BOOK_OPEN",
	SFX.BOOK_CLOSE: "BOOK_CLOSE",
	SFX.PAGE_LEFT: "PAGE_LEFT",
	SFX.PAGE_RIGHT: "PAGE_RIGHT",
	SFX.WOOSH: "WOOSH",
}
