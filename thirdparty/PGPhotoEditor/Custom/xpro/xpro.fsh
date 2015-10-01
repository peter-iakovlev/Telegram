uniform sampler2D inputImageTexture2; //map
uniform sampler2D inputImageTexture3; //vignette_map_plus_darker

vec4 filter(vec4 color) {

    vec3 texel = color.rgb;

    vec2 tc = (2.0 * texCoord) - 1.0;
    float d = dot(tc, tc);

    vec2 lookup;
    vec3 sampled;
    lookup.y = .5;
    lookup.x = texel.r;
    sampled.r = texture2D(inputImageTexture3, lookup).r;
    lookup.x = texel.g;
    sampled.g = texture2D(inputImageTexture3, lookup).g;
    lookup.x = texel.b;
    sampled.b = texture2D(inputImageTexture3, lookup).b;

    float value = smoothstep(0.0, 1.25, pow(d, 1.35)/1.65);
    texel = mix(texel, sampled, value);

    texel = vec3(
        texture2D(inputImageTexture2, vec2(texel.r, 0.5)).r,
        texture2D(inputImageTexture2, vec2(texel.g, 0.5)).g,
        texture2D(inputImageTexture2, vec2(texel.b, 0.5)).b);

    return vec4(texel, 1.0);

}
