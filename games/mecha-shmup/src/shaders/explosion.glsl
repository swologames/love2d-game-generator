// Explosion shader effect
// Creates a radial distortion wave from explosion points

uniform vec2 screenSize;
uniform float time;
uniform vec2 explosionPos[10];
uniform float explosionTime[10];
uniform float explosionSize[10];
uniform int explosionCount;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec2 uv = texture_coords;
    vec2 offset = vec2(0.0);
    vec2 actualScreen = texture_coords * screenSize;
    
    // Apply distortion from each active explosion
    for (int i = 0; i < 10; i++) {
        if (i < explosionCount && explosionTime[i] > 0.0) {
            // Calculate distance from explosion center
            vec2 toExplosion = actualScreen - explosionPos[i];
            float dist = length(toExplosion);
            float radius = explosionSize[i] * 150.0;
            
            // Wave parameters
            float lifetime = 0.4;
            float age = lifetime - explosionTime[i];
            float waveRadius = age * 400.0;
            float waveWidth = 80.0;
            
            // Create outward wave
            float distToWave = abs(dist - waveRadius);
            if (distToWave < waveWidth) {
                float waveFactor = 1.0 - (distToWave / waveWidth);
                waveFactor *= (explosionTime[i] / lifetime); // Fade over time
                
                // Normalize direction and apply distortion
                vec2 dir = normalize(toExplosion);
                offset += dir * waveFactor * 0.015 / screenSize;
            }
            
            // Center distortion
            if (dist < radius * 1.5) {
                float centerFactor = 1.0 - (dist / (radius * 1.5));
                centerFactor *= (explosionTime[i] / lifetime);
                offset += normalize(toExplosion) * centerFactor * 0.01 / screenSize;
            }
        }
    }
    
    // Sample texture with distorted UVs
    vec4 texColor = Texel(texture, uv + offset);
    
    // Add bright flash near explosion centers
    for (int i = 0; i < 10; i++) {
        if (i < explosionCount && explosionTime[i] > 0.0) {
            vec2 toExplosion = actualScreen - explosionPos[i];
            float dist = length(toExplosion);
            float radius = explosionSize[i] * 150.0;
            float lifetime = 0.4;
            
            if (dist < radius * 2.0) {
                float flashFactor = 1.0 - (dist / (radius * 2.0));
                flashFactor *= (explosionTime[i] / lifetime);
                flashFactor = pow(flashFactor, 2.0);
                
                // Orange/yellow flash
                texColor.rgb += vec3(1.0, 0.7, 0.3) * flashFactor * 0.3;
            }
        }
    }
    
    // Use time to prevent optimization
    texColor.rgb *= (1.0 + sin(time * 100.0) * 0.0001);
    
    return texColor * color;
}
