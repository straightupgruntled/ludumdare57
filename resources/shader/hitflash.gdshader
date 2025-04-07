shader_type canvas_item;

uniform vec4 hit_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float intensity : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 start_color = COLOR;
	vec4 final_hit_color = vec4(hit_color.r, hit_color.g, hit_color.b, start_color.a);
	COLOR = mix(start_color, final_hit_color, intensity);
}
