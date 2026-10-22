layout(push_constant, std430) uniform Params {
	// See MaterialStorage::store_view_depth_rows().
	vec4 view_z_row;
	vec4 view_w_row;

	ivec2 size;
	float blur_size;
	float blur_scale;

	int blur_steps;
	bool blur_near_active;
	float blur_near_begin;
	float blur_near_end;

	bool blur_far_active;
	float blur_far_begin;
	float blur_far_end;
	bool second_pass;

	bool half_size;
	bool use_jitter;
	float jitter_seed;
	bool use_physical_near;

	bool use_physical_far;
	float blur_size_near;
	float blur_size_far;
	float z_far;
}
params;

float get_view_depth(vec2 p_uv, float p_depth) {
	// Cleared depth is the far plane, which an oblique near plane tilts away from z_far.
	if (p_depth == 0.0) {
		return params.z_far;
	}
	vec4 ndc = vec4(p_uv * 2.0 - 1.0, p_depth, 1.0);
	return -dot(params.view_z_row, ndc) / dot(params.view_w_row, ndc);
}

//used to work around downsampling filter
#define DEPTH_GAP 0.0

const float GOLDEN_ANGLE = 2.39996323;

//note: uniform pdf rand [0;1[
float hash12n(vec2 p) {
	p = fract(p * vec2(5.3987, 5.4421));
	p += dot(p.yx, p.xy + vec2(21.5351, 14.3137));
	return fract(p.x * p.y * 95.4307);
}
