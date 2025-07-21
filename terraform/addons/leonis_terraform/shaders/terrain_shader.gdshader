shader_type spatial;

render_mode vertex_lighting;

//Splat_0
uniform sampler2D splat_0;

uniform sampler2D splat_0_0;
uniform vec2 splat_0_0_uv;

uniform sampler2D splat_0_r;
uniform vec2 splat_0_r_uv;

uniform sampler2D splat_0_g;
uniform vec2 splat_0_g_uv;

uniform sampler2D splat_0_b;
uniform vec2 splat_0_b_uv;


// Mix variables
varying vec3 mix_0_1;
varying vec3 mix_0_2;
varying vec3 mix_0_3;

varying vec2 main_uv;
varying float normal_y;
varying float vert_y;

void vertex(){
	normal_y = NORMAL.y;
	vert_y = VERTEX.y;
}


void fragment() {
	vec3 splat_tex_0 = texture(splat_0, UV).rgb;

//	Splat 0
	vec3 tex_0 = texture(splat_0_0, UV * splat_0_0_uv * 100.0).rgb;
	vec3 tex_1 = texture(splat_0_r, UV * splat_0_r_uv * 100.0).rgb;
	vec3 tex_2 = texture(splat_0_g, UV * splat_0_g_uv * 100.0).rgb;
	vec3 tex_3 = texture(splat_0_b, UV * splat_0_b_uv * 100.0).rgb;

	mix_0_1 = mix(tex_0, tex_1, splat_tex_0.r);
	mix_0_2 = mix(mix_0_1, tex_2, splat_tex_0.g);
	mix_0_3 = mix(mix_0_2, tex_3, splat_tex_0.b);

	ALBEDO = mix_0_3;
	SPECULAR = 0.0;
	METALLIC = 1.0;
	ROUGHNESS = 1.0;
}
