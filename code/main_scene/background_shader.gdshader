shader_type canvas_item;

uniform sampler2D noise : repeat_enable; 

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float time = TIME * 0.1;
	float r = texture(noise, vec2(SCREEN_UV.x, SCREEN_UV.y + time)).r;
	float g = texture(noise, vec2(SCREEN_UV.x + time, SCREEN_UV.y - time)).g;
	float b = texture(noise, vec2(SCREEN_UV.x - time, SCREEN_UV.y - time)).b;
	COLOR = vec4(0.0, 0.0, 0.0, r * g * b);
}