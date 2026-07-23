shader_type spatial;
render_mode cull_front, unshaded;
uniform vec4 outline_color : source_color;
uniform float outline_width = 1.0;

void vertex() {
}

void fragment() {
	ALBEDO = outline_color.rgb;
	if (outline_color.a < 1.0) {
		ALPHA = outline_color.a;
	}
}