uniform sampler2D inputImageTexture2; //map
uniform sampler2D inputImageTexture3; //curvesmap
uniform sampler2D inputImageTexture4; //vignette_map_plus_darker
uniform sampler2D inputImageTexture5; //overlay_map
uniform sampler2D inputImageTexture6; //blowout_map

const mat3 saturate = mat3(
                           1.210300,
                           -0.089700,
                           -0.091000,
                           -0.176100,
                           1.123900,
                           -0.177400,
                           -0.034200,
                           -0.034200,
                           1.265800);
const vec3 rgbPrime = vec3(0.25098, 0.14640522, 0.0);
const vec3 desaturate = vec3(.3, .59, .11);

vec4 filter(vec4 color) {

    vec3 texel = color.rgb;


    vec2 lookup;
    lookup.y = 0.5;

    lookup.x = texel.r;
    texel.r = texture2D(inputImageTexture3, lookup).r;

    lookup.x = texel.g;
    texel.g = texture2D(inputImageTexture3, lookup).g;

    lookup.x = texel.b;
    texel.b = texture2D(inputImageTexture3, lookup).b;

    vec3 result = texture2D(inputImageTexture5, vec2(dot(desaturate, texel), 0.5)).rgb;

    texel = saturate * mix(texel, result, .5);

    vec2 tc = (2.0 * texCoord) - 1.0;
    float d = dot(tc, tc);

    vec3 sampled;

    lookup.x = texel.r;
    sampled.r = texture2D(inputImageTexture4, lookup).r;

    lookup.x = texel.g;
    sampled.g = texture2D(inputImageTexture4, lookup).g;

    lookup.x = texel.b;
    sampled.b = texture2D(inputImageTexture4, lookup).b;

    float value = smoothstep(0.0, 1.25, pow(d, 1.35)/1.65);
    texel = mix(texel, sampled, value);

    lookup.x = texel.r;
    sampled.r = texture2D(inputImageTexture6, lookup).r;
    lookup.x = texel.g;
    sampled.g = texture2D(inputImageTexture6, lookup).g;
    lookup.x = texel.b;
    sampled.b = texture2D(inputImageTexture6, lookup).b;

    texel = mix(sampled, texel, value);

    vec4 map_lookup_redgreen = texture2D(inputImageTexture2, texel.xy);
    lookup.x = texel.b;
    vec4 map_lookup_blue = texture2D(inputImageTexture2, lookup);

    vec4 final = vec4(map_lookup_redgreen.r, map_lookup_redgreen.g, map_lookup_blue.b, 1.0);

    return final;

}
