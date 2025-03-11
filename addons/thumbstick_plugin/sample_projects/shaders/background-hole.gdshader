shader_type canvas_item;

uniform vec2 center = vec2(0.0, 0.0);
uniform float radius = 0.5;
uniform vec4 bg_tint : source_color = vec4(1, 1, 1, 1);

void fragment() {
	vec2 uv = UV;
	float dist = distance(uv, center);

	if (dist < radius) {
		discard;
	}

	vec4 color = texture(TEXTURE, uv);
	color *= bg_tint;
	COLOR = color;
}
