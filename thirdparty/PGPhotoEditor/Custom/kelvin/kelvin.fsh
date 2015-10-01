uniform sampler2D inputImageTexture2; //map

vec4 filter(vec4 color) {

    vec3 texel = color.rgb;

    vec2 lookup;
    lookup.y = .5;

    lookup.x = texel.r;
    texel.r = texture2D(inputImageTexture2, lookup).r;

    lookup.x = texel.g;
    texel.g = texture2D(inputImageTexture2, lookup).g;

    lookup.x = texel.b;
    texel.b = texture2D(inputImageTexture2, lookup).b;

    return vec4(texel, 1.0);
}
