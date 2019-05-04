shader_type canvas_item;

uniform float brightness = 1.5;
//uniform float offset = 1.0;
uniform sampler2D uv_offset_texture : hint_black;

void fragment() {
	vec4 offset = texture(uv_offset_texture, UV);
	float noisey = (offset.r - 0.5) * 0.05;
	float noisex = (offset.g - 0.5) * 0.05;
	COLOR = textureLod(SCREEN_TEXTURE, SCREEN_UV + vec2(noisex, noisey), 0.0);
//	float b = sin(SCREEN_UV.x*200.0);
//	float b = sin(UV.x*100.0);
//	COLOR.rgb = vec3(SCREEN_UV.x);
//    COLOR.rgb = c*(2.0-b);
//    COLOR = texture(uv_offset_texture, UV);
}