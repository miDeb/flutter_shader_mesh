#include <flutter/runtime_effect.glsl>
#define MAX_POINTS 16

uniform vec2 u_size;
uniform vec2 u_points[MAX_POINTS];
uniform vec4 u_colors[MAX_POINTS];

out vec4 frag_color;

void main() {
    vec2 pixel = FlutterFragCoord() / u_size;

    float closest_distance = length(u_points[0] - pixel);

    for (int i = 1; i < MAX_POINTS; i++) {
      if (u_points[i] == vec2(-1)) {
          break;
      }
      closest_distance = min(closest_distance, length(u_points[i] - pixel));
    }

    float sum = 0;
    vec4 color;
    for (int i = 0; i < MAX_POINTS; i++) {
        if (u_points[i] == vec2(-1)) {
            break;
        }

        float distance = length(u_points[i] - pixel);
        float fraction_of_closest_distance = distance / closest_distance;

        float color_fraction = 1 / fraction_of_closest_distance;

        // apply a curve to reduce the impact of far-away colors
        color_fraction = pow(color_fraction, 3);

        sum += color_fraction;
        color += u_colors[i] * color_fraction;
        
  }

  frag_color = color / sum;
}