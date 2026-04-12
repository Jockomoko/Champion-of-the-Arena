shader_type canvas_item;

// ─── LAYER 1 (always active – assign your Cloud.PNG here) ───────────────────
uniform sampler2D cloud_texture_1 : filter_linear_mipmap, repeat_enable;
uniform float     cloud_speed_1   : hint_range(0.0, 0.5)  = 0.025;  // scroll speed
uniform float     cloud_scale_1   : hint_range(0.1, 10.0) = 2.0;    // tile scale (higher = more tiles)
uniform float     cloud_opacity_1 : hint_range(0.0, 1.0)  = 0.90;
uniform vec4      cloud_color_1   : source_color           = vec4(1.0, 1.0, 1.0, 1.0);

// ─── LAYER 2 (optional – leave opacity at 0 to disable) ─────────────────────
uniform sampler2D cloud_texture_2 : filter_linear_mipmap, repeat_enable;
uniform float     cloud_speed_2   : hint_range(0.0, 0.5)  = 0.040;
uniform float     cloud_scale_2   : hint_range(0.1, 10.0) = 1.4;
uniform float     cloud_opacity_2 : hint_range(0.0, 1.0)  = 0.0;   // set > 0 to enable
uniform vec4      cloud_color_2   : source_color           = vec4(0.95, 0.95, 0.95, 1.0);

// ─── LAYER 3 (optional – leave opacity at 0 to disable) ─────────────────────
uniform sampler2D cloud_texture_3 : filter_linear_mipmap, repeat_enable;
uniform float     cloud_speed_3   : hint_range(0.0, 0.5)  = 0.012;
uniform float     cloud_scale_3   : hint_range(0.1, 10.0) = 3.0;
uniform float     cloud_opacity_3 : hint_range(0.0, 1.0)  = 0.0;   // set > 0 to enable
uniform vec4      cloud_color_3   : source_color           = vec4(1.0, 1.0, 1.0, 0.85);

// ─── Vertical fade – clouds fade out toward the bottom of the sky ───────────
// 0 = no fade, 1 = full fade to transparent at the bottom half
uniform float vertical_fade : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	vec4 result = vec4(0.0, 0.0, 0.0, 0.0); // fully transparent base

	// --- Layer 1 ---
	vec2 uv1 = UV * cloud_scale_1 + vec2(TIME * cloud_speed_1, 0.0);
	vec4 c1  = texture(cloud_texture_1, uv1);
	float a1 = c1.a * cloud_opacity_1;
	result.rgb = mix(result.rgb, cloud_color_1.rgb * c1.rgb, a1);
	result.a   = max(result.a, a1);

	// --- Layer 2 (only costs GPU if opacity > 0, branch is free on modern GPUs) ---
	if (cloud_opacity_2 > 0.0) {
		vec2 uv2 = UV * cloud_scale_2 + vec2(0.47, 0.31) + vec2(TIME * cloud_speed_2, 0.0);
		vec4 c2  = texture(cloud_texture_2, uv2);
		float a2 = c2.a * cloud_opacity_2;
		result.rgb = mix(result.rgb, cloud_color_2.rgb * c2.rgb, a2);
		result.a   = max(result.a, a2);
	}

	// --- Layer 3 ---
	if (cloud_opacity_3 > 0.0) {
		vec2 uv3 = UV * cloud_scale_3 + vec2(0.23, 0.65) + vec2(TIME * cloud_speed_3, 0.0);
		vec4 c3  = texture(cloud_texture_3, uv3);
		float a3 = c3.a * cloud_opacity_3;
		result.rgb = mix(result.rgb, cloud_color_3.rgb * c3.rgb, a3);
		result.a   = max(result.a, a3);
	}

	// --- Vertical fade (clouds become transparent near the bottom) ---
	float fade = 1.0 - smoothstep(0.0, 1.0, UV.y * vertical_fade * 2.0);
	result.a *= clamp(fade, 0.0, 1.0);

	COLOR = result;
}
