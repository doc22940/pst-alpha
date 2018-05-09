precision highp float;

#ifdef VERTEX_SHADER

layout(location = 0) in vec4 a_position;

void main() {
  gl_Position = a_position;
}

#endif

#ifdef FRAGMENT_SHADER

uniform sampler2D u_position;
uniform sampler2D u_position_prev;
uniform sampler2D u_color;
uniform sampler2D u_color_prev;

uniform vec2  u_resolution;
uniform int   u_frame;
uniform float u_time;
uniform float u_time_delta;

layout(location = 0) out vec4 o_position;
layout(location = 1) out vec4 o_color;

void main() {
  ivec2 texcoord = ivec2(gl_FragCoord);

  vec4 pos = texelFetch(u_position, texcoord, 0);
  vec4 pos_prev = texelFetch(u_position_prev, texcoord, 0);

  vec4 color = texelFetch(u_color, texcoord, 0);
  vec4 color_prev = texelFetch(u_color_prev, texcoord, 0);

  vec3 vel = pos.xyz - pos_prev.xyz;
  vel *= 0.9;

  vec3 color_vel = color.rgb - color_prev.rgb;
  color_vel *= 0.9;

  vec2 uv = gl_FragCoord.xy / vec2(u_resolution);

  float z = sin(u_time + uv.x * 5.231) + cos(u_time + uv.y * 5.763);
  z *= 0.5;
  vec3 goal_position = vec3(uv * 2.0 - 1.0, z);
  vec3 goal_color = vec3(sin(z * 10.0) * 0.5 + 0.5, cos(z * 10.0) * 0.5 + 0.5, 0.0);

  vel += (goal_position - pos.xyz) * 0.1;
  color_vel += (goal_color - color.rgb) * 0.1;

  o_position = vec4(pos.xyz + vel, 1.0);
  o_color = vec4(color.rgb + color_vel, 1.0);

  float t = u_time * 0.2;
  o_position = mix(o_position, vec4(0.0, 0.0, 0.0, 1.0), smoothstep(0.9, 1.0, abs(fract(uv.x - uv.y - t) * 2.0 - 1.0)));
  o_color = mix(o_color, vec4(0.0, 0.0, 0.0, 1.0), smoothstep(0.9, 1.0, abs(fract(uv.x - uv.y - t) * 2.0 - 1.0)));
}

#endif