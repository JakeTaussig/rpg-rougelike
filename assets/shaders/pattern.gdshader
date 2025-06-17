shader_type canvas_item;

// ====== Layer Colors ======
uniform sampler2D input_texture : filter_nearest;

// Bottom Layer Colors
uniform vec4 bottom_layer_white : source_color = vec4(1.0);
uniform vec4 bottom_layer_black : source_color = vec4(0.0, 0.0, 0.0, 1.0);

// Top Layer Colors & Settings
uniform vec4 top_layer_white : source_color = vec4(0.8, 0.0, 0.0, 1.0);
uniform vec4 top_layer_black : source_color = vec4(0.0, 0.8, 0.0, 1.0);
uniform bool top_white_enabled = false;
uniform bool top_black_enabled = true;

// ====== Layer Positioning ======
uniform float top_layer_x_offset = 0.0;
uniform float top_layer_y_offset = 8.0;

// ====== Transformations ======
const int MAX_TRANSFORMS = 6;
uniform int transformations[MAX_TRANSFORMS];
uniform int transformation_count = 0;

// Transformation Types
const int TRANS_NONE      = 0;
const int TRANS_MIRROR_X  = 1;
const int TRANS_MIRROR_Y  = 2;
const int TRANS_DOUBLE_X  = 3;
const int TRANS_DOUBLE_Y  = 4;
const int TRANS_TILE      = 5;

// ====== Animation & Scrolling ======
uniform float time_scale = 100.0;

uniform bool top_scroll_x_enabled = false;
uniform float top_scroll_x_factor = 10.0;

uniform bool top_scroll_y_enabled = false;
uniform float top_scroll_y_factor = 10.0;

uniform bool global_scroll_enabled = false;
uniform float global_scroll_factor = 10.0;

// ====== Global Settings ======
uniform bool global_double_scale = false;

// ====== Helper Functions ======
vec2 scale_uv(vec2 uv, float scale_x, float scale_y) {
    uv -= 0.5;
    uv *= mat2(vec2(scale_x, 0.0), vec2(0.0, scale_y));
    return uv + 0.5;
}

vec2 apply_transformation(vec2 uv, int type) {
    switch (type) {
        case TRANS_MIRROR_X:  return vec2(2.0 * abs(uv.x - 0.5), uv.y);
        case TRANS_MIRROR_Y:  return vec2(uv.x, 2.0 * abs(uv.y - 0.5));
        case TRANS_DOUBLE_X:
        	float new_x = uv.x * 2.0;
			if (new_x > 1.0) { new_x -= 1.0;}
        	return vec2(new_x, uv.y);
        case TRANS_DOUBLE_Y:
        	float new_y = uv.y * 2.0;
        	if (new_y > 1.0) { new_y -= 1.0;}
        	return vec2(uv.x, new_y);
        case TRANS_TILE:      return fract(uv);
        default:              return uv;
    }
}

vec2 apply_transformations(vec2 uv) {
    // Apply transformations in reverse order
    for (int i = MAX_TRANSFORMS - 1; i >= 0; i--) {
        if (i >= transformation_count) continue;
        uv = apply_transformation(uv, transformations[i]);
    }
    return uv;
}

vec4 get_layer_color(vec4 sample, vec4 white, vec4 black, bool use_white, bool use_black) {
    bool is_white = sample.r > 0.5;
    vec4 color = is_white ? white : black;
    color.a *= float((is_white && use_white) || (!is_white && use_black));
    return color;
}

// ====== Main Shader ======
void fragment() {
    // Base UV with global scrolling
    vec2 base_uv = UV;
    if (global_scroll_enabled) {
        base_uv.y -= TIME * global_scroll_factor / time_scale;
    }

    // Calculate top layer offset
    vec2 texel_size = 1.0 / vec2(textureSize(input_texture, 0));
    vec2 top_offset = vec2(top_layer_x_offset, top_layer_y_offset) * texel_size;

    // Apply scrolling effects to top layer
    if (top_scroll_x_enabled || top_scroll_y_enabled) {
        float scroll_time = fract(TIME / time_scale);
        top_offset.x += 2.0 * top_scroll_x_factor * scroll_time * float(top_scroll_x_enabled) / 2.0;
        top_offset.y += 2.0 * top_scroll_y_factor * scroll_time * float(top_scroll_y_enabled);
    }
	
    // Calculate base scaling factors
    vec2 scale_factors = vec2(16.0, 18.0);
    
    // Apply global scaling options
    if (global_double_scale) {
        scale_factors /= 2.0;
    }
    if (textureSize(input_texture, 0).x >= 32) {
        scale_factors /= 2.0;
    }

    // Apply transformation-dependent scaling
    for (int i = 0; i < MAX_TRANSFORMS; i++) {
        if (i >= transformation_count) break;
        
        int transform = transformations[i];
        if (transform == TRANS_MIRROR_X || transform == TRANS_DOUBLE_X) scale_factors.x /= 2.0;
        if (transform == TRANS_MIRROR_Y || transform == TRANS_DOUBLE_Y) scale_factors.y /= 2.0;
    }

    // Prepare UVs for both layers
    vec2 bottom_uv = apply_transformations(scale_uv(base_uv, scale_factors.x, scale_factors.y));
    vec2 top_uv = apply_transformations(scale_uv(base_uv, scale_factors.x, scale_factors.y) + top_offset);

    // Sample and colorize layers
    vec4 bottom_sample = texture(input_texture, bottom_uv);
    vec4 top_sample = texture(input_texture, top_uv);
    
    vec4 bottom_color = get_layer_color(bottom_sample, bottom_layer_white, bottom_layer_black, true, true);
    vec4 top_color = get_layer_color(top_sample, top_layer_white, top_layer_black, top_white_enabled, top_black_enabled);

    // Blend layers
    COLOR = mix(bottom_color, top_color, top_color.a);
}