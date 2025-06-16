shader_type canvas_item;

// Base layer colors
uniform sampler2D input_texture: filter_nearest;
uniform vec4 bottom_layer_white_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 bottom_layer_black_color : source_color= vec4(0.0, 0.0, 0.0, 1.0);

// Second layer properties
uniform vec4 top_layer_white_color : source_color = vec4(0.8, 0.0, 0.0, 1.0);
uniform vec4 top_layer_black_color : source_color = vec4(0.0, 0.8, 0.0, 1.0);

uniform bool top_layer_white_color_enabled = false;
uniform bool top_layer_black_color_enabled = true;

uniform float top_layer_x_offset = 0.0;
uniform float top_layer_y_offset = 8.0;

// Transformation properties
uniform int transformations[6];
uniform int transformation_count = 0;

// Scroll Properties
uniform float time_scale = 100.0;

uniform bool top_layer_y_scroll_enabled = false;
uniform float top_layer_y_scroll_factor = 10.0;

uniform bool top_layer_x_scroll_enabled = false;
uniform float top_layer_x_scroll_factor = 10.0;

// Global Properties
uniform bool global_scroll_enabled = false;
uniform float global_scroll_factor = 10.0;

uniform bool global_double_scale = false;

vec2 scale_uv(vec2 uv, float x, float y) {
    uv -= 0.5;
    uv *= mat2(vec2(x, 0.0), vec2(0.0, y));
    return uv + 0.5;
}

vec2 apply_transformations(vec2 uv) {
    for (int i = 6; i >= 0; i--) {
        if (i >= transformation_count) continue;

        switch (transformations[i]) {
      case 0: // null
        break;
            case 1: // Mirror X
                uv.x = 2.0 * abs(uv.x - 0.5);
                break;
            case 2: // Mirror Y
                uv.y = 2.0 * abs(uv.y - 0.5);
                break;
            case 3: // Double X
                uv.x = uv.x * 2.0;
        if (uv.x > 1.0) { uv.x -= 1.0;}
                break;
            case 4: // Double Y
                uv.y = uv.y * 2.0;
        if (uv.y > 1.0) { uv.y -= 1.0;}
                break;
            case 5: // Tile
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
    vec2 uv_base = UV - vec2(0.0, (TIME * global_scroll_factor * float(global_scroll_enabled)) / time_scale);

    // Calculate second layer animation
    vec2 pixel_offset2 =  vec2(
    top_layer_x_offset / float(textureSize(input_texture, 0).x),
    top_layer_y_offset / float(textureSize(input_texture, 0).x))
  ;

    float fract_time = fract(TIME / time_scale);
   if (top_layer_x_scroll_enabled) {
      pixel_offset2 += vec2(2.0 * top_layer_x_scroll_factor * fract_time, 0.0);
    }

  if (top_layer_y_scroll_enabled) {
    pixel_offset2 += vec2(0.0, 2.0 * top_layer_y_scroll_factor * fract_time);
  }


    // Precompute scale factors
    float scaleX = 16.0;
    float scaleY = 18.0;

  if (global_double_scale) {
    scaleX /= 2.0;
    scaleY /= 2.0;
  }

  if (textureSize(input_texture, 1)[0] >= 32) {scaleX /= 2.0; scaleY /= 2.0;}

    for (int i = 10; i >= 0; i--) {
        if (i >= transformation_count) continue;
        if (transformations[i] == 3) scaleX /= 2.0;
        else if (transformations[i] == 4) scaleY /= 2.0;
      else if (transformations[i] == 1) scaleX /= 2.0;
        else if (transformations[i] == 2) scaleY /= 2.0;
    }

    // Apply transformations to both layers
    vec2 uv1 = apply_transformations(scale_uv(uv_base, scaleX, scaleY));
    vec2 uv2 = apply_transformations(scale_uv(uv_base, scaleX, scaleY) + (pixel_offset2));

    // Sample and colorize layers
    vec4 tex1 = texture(input_texture, uv1);
    vec4 tex2 = texture(input_texture, uv2);

    vec4 col1 = get_layer_color(tex1, bottom_layer_white_color, bottom_layer_black_color, true, true);
    vec4 col2 = get_layer_color(tex2, top_layer_white_color, top_layer_black_color, top_layer_white_color_enabled, top_layer_black_color_enabled);

    // Blend layers
    COLOR = mix(col1, col2, col2.a);
}