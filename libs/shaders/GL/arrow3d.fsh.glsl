layout (location = 0) in vec3 v_normal;

layout (location = 0) out vec4 v_FragColor;

layout (binding = 0) uniform UBO
{
  mat4 u_transform;
  mat4 u_normalTransform;
  vec4 u_color;
  vec2 u_texCoordFlipping;
};

// Lit slightly from the front so the rear slopes read darker.
const vec3 lightDir = vec3(0.299, -0.349, 0.888);

void main()
{
  // Deeper edge shading and a soft sheen on the flat top keep bevels readable on dark colours.
  float phongDiffuse = max(0.0, -dot(lightDir, v_normal));
  vec3 color = (phongDiffuse * 0.6 + 0.4) * u_color.rgb;
  color = mix(color, vec3(1.0), 0.12 * smoothstep(0.9, 1.0, -v_normal.z));
  v_FragColor = vec4(color, u_color.a);
}
