uniform sampler2D inputImageTexture2; //map
uniform sampler2D inputImageTexture3; //glowfield
uniform sampler2D inputImageTexture4; //overlay
uniform sampler2D inputImageTexture5; //colorOverlay

vec4 filter(vec4 color) {
    
    vec3 texel = color.rgb;
    
    // saturation
    
    float luma = dot(texel, vec3(0.2125, 0.7154, 0.0721));
    texel = mix(vec3(luma), texel, 1.2);
    
    // curves
    
    vec2 lookup;
    lookup.y = .5;
    
    lookup.x = texel.r;
    texel.r = texture2D(inputImageTexture2, lookup).r;
    
    lookup.x = texel.g;
    texel.g = texture2D(inputImageTexture2, lookup).g;
    
    lookup.x = texel.b;
    texel.b = texture2D(inputImageTexture2, lookup).b;
    
    ;
    
    // glow
    
    vec3 glowFieldTexel = texture2D(inputImageTexture3, texCoord).rgb;
    texel = vec3(
                 texture2D(inputImageTexture4, vec2(glowFieldTexel.r, texel.r)).r,
                 texture2D(inputImageTexture4, vec2(glowFieldTexel.g, texel.g)).g,
                 texture2D(inputImageTexture4, vec2(glowFieldTexel.b, texel.b)).b
                 );
    
    ;
    
    // color
    
    lookup.x = texel.r;
    texel.r = texture2D(inputImageTexture5, lookup).r;
    
    lookup.x = texel.g;
    texel.g = texture2D(inputImageTexture5, lookup).g;
    
    lookup.x = texel.b;
    texel.b = texture2D(inputImageTexture5, lookup).b;
    
    return vec4(texel, 1.0);
    
}
