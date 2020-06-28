shader_type spatial;
render_mode blend_mix, unshaded;

uniform vec4 albedo : hint_color = vec4(1.0,1.0,1.0,1.0);
uniform vec4 Emission : hint_color = vec4(1.0,1.0,1.0,1.0);
uniform float Energy : hint_range(0,10) = 1.0;

void fragment(){
	ALBEDO = albedo.rgb;
	EMISSION = Emission.rgb * Energy;
}