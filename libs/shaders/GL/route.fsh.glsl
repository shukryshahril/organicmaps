// Warning! Beware to use this shader. "discard" command may significally reduce performance.
// Unfortunately some CG algorithms cannot be implemented without discarding fragments from depth buffer.

layout (location = 0) in vec3 v_length;
layout (location = 1) in vec4 v_color;

layout (location = 0) out vec4 v_FragColor;

layout (binding = 0) uniform UBO
{
  mat4 u_modelView;
  mat4 u_projection;
  mat4 u_pivotTransform;
  vec4 u_routeParams;
  vec4 u_color;
  vec4 u_maskColor;
  vec4 u_outlineColor;
  vec4 u_fakeColor;
  vec4 u_fakeOutlineColor;
  vec2 u_fakeBorders;
  vec2 u_pattern;
  vec2 u_angleCosSin;
  float u_arrowHalfWidth;
  float u_opacity;
};

const float kAntialiasingThreshold = 0.92;
const float kOutlineThreshold1 = 0.81;
const float kOutlineThreshold2 = 0.71;
// The driven part stays as a thin trail that fades out over this many route half-widths.
const float kTrailFadeHalfWidths = 40.0;
const float kTrailHalfWidth = 0.4;

void main()
{
  float behind = v_length.z - v_length.x;
  if (behind > 0.0)
  {
    float fade = 1.0 - clamp(behind / (u_routeParams.y * kTrailFadeHalfWidths), 0.0, 1.0);
    float side = abs(v_length.y);
    if (fade <= 0.0 || side > kTrailHalfWidth)
      discard;
    float alpha = 0.85 * fade * (1.0 - smoothstep(kTrailHalfWidth - 0.08, kTrailHalfWidth, side));
    v_FragColor = vec4(mix(u_fakeColor.rgb, u_maskColor.rgb, u_maskColor.a), alpha * u_fakeColor.a);
    return;
  }
  vec2 coefs = step(v_length.xx, u_fakeBorders);
  coefs.y = 1.0 - coefs.y;
  vec4 mainColor = mix(u_color, u_fakeColor, coefs.x);
  mainColor = mix(mainColor, u_fakeColor, coefs.y);
  vec4 mainOutlineColor = mix(u_outlineColor, u_fakeOutlineColor, coefs.x);
  mainOutlineColor = mix(mainOutlineColor, u_fakeOutlineColor, coefs.y);
  vec4 color = mix(mix(mainColor, vec4(v_color.rgb, 1.0), v_color.a), mainColor, step(u_routeParams.w, 0.0));
  color = mix(color, mainOutlineColor, smoothstep(kOutlineThreshold2, kOutlineThreshold1, abs(v_length.y)));
  color.a *= (1.0 - smoothstep(kAntialiasingThreshold, 1.0, abs(v_length.y)));
  color = vec4(mix(color.rgb, u_maskColor.rgb, u_maskColor.a), color.a);
  v_FragColor = color;
}
