const vec3 cubeFaceNormals[6] = vec3[6](vec3(1.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0), vec3(0.0, 0.0, 1.0), vec3(-1.0, 0.0, 0.0), vec3(0.0, -1.0, 0.0), vec3(0.0, 0.0, -1.0));

float hash1(uint n) {
  n = (n << 13U) ^ n;
  n = n * (n * n * 15731U + 789221U) + 1376312589U;
  return float(n & uvec3(0x7fffffffU)) / float(0x7fffffff);
}

vec3 hash3(uint n) {
  n = (n << 13U) ^ n;
  n = n * (n * n * 15731U + 789221U) + 1376312589U;
  uvec3 k = n * uvec3(n, n * 16807U, n * 48271U);
  return vec3(k & uvec3(0x7fffffffU)) / float(0x7fffffff);
}

float getDepth(vec2 p) {
  float t0 = iTime * 0.1;
  float d = sin(p.x * 2.653 + t0) * 0.3;
  d += sin(p.y * 1.951 + t0) * 0.3;
  float l = length(p);
  d += 0.3 * smoothstep(0.96, 1.0, abs(fract(l * 0.1 - iTime * 0.1) * 2.0 - 1.0));
  d += l * l * l * 0.008 * cos(12.0 * atan(p.x, p.y) + iTime);
  d *= smoothstep(10.0, 0.0, l);
  return d;
}

void mainSimulation(out vec4 oPosition, out vec4 oColor, out vec4 oRight, out vec4 oUp, out vec4 oUnused0, out vec4 oUnused1) {
  ivec2 texcoord = ivec2(gl_FragCoord);
  int id = (texcoord.x + texcoord.y * iResolution.x);
  float r = hash1(uint(id));

  if (id < 12) {
    mat4 xf = iControllerTransform[id / 6];
    vec3 scale = vec3(0.025, 0.025, 0.1);
    oPosition = xf * vec4(cubeFaceNormals[id % 6] * scale, 1.0);
    oColor = vec4(vec3(r * 0.75 + 0.25), 1.0);
    oRight = xf * vec4(cubeFaceNormals[(id + 1) % 6] * scale, 0.0);
    oUp = xf * vec4(cubeFaceNormals[(id + 2) % 6] * scale, 0.0);
  }
  else if (id < 20) {
    int i = id - 12;
    int controllerId = i / 4;
    int buttonId = i % 4;
    mat4 xf = iControllerTransform[controllerId];
    oPosition = xf * vec4(0.0, 0.026, 0.022 * float(buttonId), 1.0);
    oColor = vec4(0.4 + 0.6 * iControllerButtons[controllerId][buttonId], 0.0, 0.0, 1.0);
    oRight = xf * vec4(0.01, 0.0, 0.0, 0.0);
    oUp = xf * vec4(0.0, 0.0, 0.009, 0.0);
  }
  else if (id < 20 + 128) {
    int i = id - 20;
    int f = int(iFrame) + i;
    int age = f & 127;
    if (age == 0) {
      mat4 xf = iControllerTransform[i & 1];
      vec3 rv = hash3(uint(i));
      vec3 scale = vec3(0.06, 0.06, 0.21);
      oPosition = xf * vec4((rv - 0.5) * scale, 1.0);
      oColor = vec4(rv, 1.0);
      oRight = xf * vec4(0.02, 0.0, 0.0, 0.0);
      oUp = xf * vec4(0.0, 0.0, 0.02, 0.0);
    }
    else {
      oPosition = texelFetch(iFragData[0], texcoord, 0);
      oColor = texelFetch(iFragData[1], texcoord, 0);
      oRight = texelFetch(iFragData[2], texcoord, 0) * 0.95;
      oUp = texelFetch(iFragData[3], texcoord, 0) * 0.95;
    }
  }
  else {
    float t = iTime + r * 20.0;
    vec2 xy = gl_FragCoord.xy / vec2(iResolution) * 7.0 - 3.5;
    vec2 fp = xy + 0.5 * vec2(cos(t * 0.1), sin(t * 0.1));

    oPosition = vec4(xy.x, 0.0, xy.y, 1.0);
    oPosition.y += getDepth(fp) - 1.0;
    oPosition.z -= 4.0;

    for (int i = 0; i < 2; ++i) {
      vec3 o = oPosition.xyz - iControllerTransform[i][3].xyz;
      oPosition.xyz -= smoothstep(1.0, 0.0, length(o)) * iControllerButtons[i][0] * 2.0 * o;
    }

    vec2 o = vec2(0.0, 0.01);
    vec3 tx = normalize(vec3(o.xy, getDepth(fp + o.xy) - getDepth(fp - o.xy)));
    vec3 ty = normalize(vec3(o.yx, getDepth(fp + o.yx) - getDepth(fp - o.yx)));

    oRight.xyz = tx.xzy * r * 0.1 + 0.005;
    oUp.xyz = ty.xzy * (1.0 - r) * 0.1 + 0.005;

    oColor.rg = vec2(texcoord) / vec2(iResolution);
    oColor.b = r * 0.4;
    float controllerDist = min(distance(oPosition.xyz, iControllerTransform[0][3].xyz), distance(oPosition.xyz, iControllerTransform[1][3].xyz));
    oColor.rgb *= smoothstep(4.0, 2.0, length(fp)) * 1.5 * smoothstep(0.0, 1.0, controllerDist);
    oColor.a = 1.0;
  }
}
