// CRT Shader for retro arcade feel
// Based on classic CRT monitor effects

uniform vec2 screenSize;
uniform float time;
uniform float intensity;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec2 uv = texture_coords;
    vec2 screenUV = uv * screenSize;
    vec4 texColor = Texel(texture, uv);
    
    // Scanlines
    float scanline = sin(screenUV.y * 1.5) * 0.04;
    texColor.rgb -= scanline * intensity;
    
    // Vignette effect
    vec2 vignetteUV = uv * 2.0 - 1.0;
    float vignette = 1.0 - dot(vignetteUV, vignetteUV) * 0.15;
    texColor.rgb *= vignette;
    
    // RGB separation for chromatic aberration
    float aberration = 0.002 * intensity;
    vec2 offset = (uv - 0.5) * aberration;
    vec4 r = Texel(texture, uv + offset);
    vec4 g = Texel(texture, uv);
    vec4 b = Texel(texture, uv - offset);
    texColor.r = mix(texColor.r, r.r, 0.3);
    texColor.b = mix(texColor.b, b.b, 0.3);
    
    // Slight curve distortion
    vec2 cc = uv - 0.5;
    float dist = dot(cc, cc) * 0.15;
    uv = (cc * (1.0 + dist) * 0.98) + 0.5;
    
    // Flicker
    float flicker = 1.0 - (sin(time * 15.0) * 0.005 + cos(time * 27.0) * 0.003) * intensity;
    texColor.rgb *= flicker;
    
    // Brightness boost
    texColor.rgb *= 1.05;
    
    return texColor * color;
}
