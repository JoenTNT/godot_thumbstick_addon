shader_type canvas_item;
render_mode blend_mix, unshaded;

uniform float height : hint_range(-1.0, 1.0) = 1.0;
uniform float x_slide: hint_range(-1.0, 1.0) = 0.0;

void fragment() {
	vec2 uv = UV * 2.0 - 1.0;
	float y = uv.y;
	vec4 col = COLOR;
	float alpha = 0.0;
	float fixed_top = -height;
	float x_tip = uv.x - x_slide;
	
	if (y > fixed_top && y < 1.0 && abs(x_tip * 2.0) < (y - fixed_top)) {
        alpha = 1.0;
    }
	
	COLOR = vec4(col.r, col.g, col.b, alpha);
}
