shader_type canvas_item;

// Base layer colors
uniform sampler2D input_texture: filter_nearest;
uniform vec4 white_color : source_color;
uniform vec4 black_color : source_color;

// Second layer properties
uniform float x_offset2 = 0.0;
uniform float y_offset2 = 8.0;
uniform vec4 white_color2 : source_color;
uniform vec4 black_color2 : source_color;
uniform bool white_color_enabled2 = true;
uniform bool black_color_enabled2 = true;

uniform bool double_scale = false;

// Transformation properties
uniform int moves[10];
uniform int move_count = 0;
uniform float ampl = 32.0;
uniform float period = 8.0;
uniform float y_scroll_factor = 30.0;

vec2 scale_uv(vec2 uv, float x, float y) {
    uv -= 0.5;
    uv *= mat2(vec2(x, 0.0), vec2(0.0, y));
    return uv + 0.5;
}

vec2 apply_transformations(vec2 uv) {
    for (int i = 10; i >= 0; i--) {
        if (i >= move_count) continue;
        
        switch (moves[i]) {
            case 0: // Mirror X
                uv.x = 2.0 * abs(uv.x - 0.5);
                break;
            case 1: // Mirror Y
                uv.y = 2.0 * abs(uv.y - 0.5);
                break;
            case 2: // Double X
                uv.x = uv.x * 2.0;
				if (uv.x > 1.0) { uv.x -= 1.0;}
                break;
            case 3: // Double Y
                uv.y = uv.y * 2.0;
				if (uv.y > 1.0) { uv.y -= 1.0;}
                break;
            case 4: // Tile
                uv = fract(uv);
                break;
        }
    }
    return uv;
}

vec4 get_layer_color(vec4 tex_sample, vec4 white, vec4 black, bool white_enabled, bool black_enabled) {
    bool is_white = tex_sample.r > 0.5;
    vec4 color = is_white ? white : black;
    color.a *= float((is_white && white_enabled) || (!is_white && black_enabled));
    return color;
}

void fragment() {
    // Base UV with vertical scrolling
    vec2 uv_base = UV - vec2(0.0, TIME / y_scroll_factor);
    
    // Calculate second layer animation
    float fract_time = fract(TIME / period);
    vec2 pixel_offset2 = vec2(2.0 * ampl * fract_time, 0.0) + vec2(x_offset2, y_offset2);
    
    // Precompute scale factors
    float scaleX = 16.0;
    float scaleY = 18.0;
	
	if (double_scale) {
		scaleX /= 2.0;
		scaleY /= 2.0;
	}
    
    for (int i = 10; i >= 0; i--) {
        if (i >= move_count) continue;
        if (moves[i] == 2) scaleX /= 2.0;
        else if (moves[i] == 3) scaleY /= 2.0;
		else if (moves[i] == 0) scaleX /= 2.0;
        else if (moves[i] == 1) scaleY /= 2.0;
    }
    
    // Apply transformations to both layers
    vec2 uv1 = apply_transformations(scale_uv(uv_base, scaleX, scaleY));
    vec2 uv2 = apply_transformations(scale_uv(uv_base + pixel_offset2 * TEXTURE_PIXEL_SIZE, scaleX, scaleY));
    
    // Sample and colorize layers
    vec4 tex1 = texture(input_texture, uv1);
    vec4 tex2 = texture(input_texture, uv2);
    
    vec4 col1 = get_layer_color(tex1, white_color, black_color, true, true);
    vec4 col2 = get_layer_color(tex2, white_color2, black_color2, white_color_enabled2, black_color_enabled2);
    
    // Blend layers
    COLOR = mix(col1, col2, col2.a);
}