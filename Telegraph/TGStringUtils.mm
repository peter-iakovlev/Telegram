#import "TGStringUtils.h"

#import <CommonCrypto/CommonDigest.h>

typedef struct {
    __unsafe_unretained NSString *escapeSequence;
    unichar uchar;
} HTMLEscapeMap;

// Taken from http://www.w3.org/TR/xhtml1/dtds.html#a_dtd_Special_characters
// Ordered by uchar lowest to highest for bsearching
static HTMLEscapeMap gAsciiHTMLEscapeMap[] = {
    // A.2.2. Special characters
    { @"&quot;", 34 },
    { @"&amp;", 38 },
    { @"&apos;", 39 },
    { @"&lt;", 60 },
    { @"&gt;", 62 },
    
    // A.2.1. Latin-1 characters
    { @"&nbsp;", 160 }, 
    { @"&iexcl;", 161 }, 
    { @"&cent;", 162 }, 
    { @"&pound;", 163 }, 
    { @"&curren;", 164 }, 
    { @"&yen;", 165 }, 
    { @"&brvbar;", 166 }, 
    { @"&sect;", 167 }, 
    { @"&uml;", 168 }, 
    { @"&copy;", 169 }, 
    { @"&ordf;", 170 }, 
    { @"&laquo;", 171 }, 
    { @"&not;", 172 }, 
    { @"&shy;", 173 }, 
    { @"&reg;", 174 }, 
    { @"&macr;", 175 }, 
    { @"&deg;", 176 }, 
    { @"&plusmn;", 177 }, 
    { @"&sup2;", 178 }, 
    { @"&sup3;", 179 }, 
    { @"&acute;", 180 }, 
    { @"&micro;", 181 }, 
    { @"&para;", 182 }, 
    { @"&middot;", 183 }, 
    { @"&cedil;", 184 }, 
    { @"&sup1;", 185 }, 
    { @"&ordm;", 186 }, 
    { @"&raquo;", 187 }, 
    { @"&frac14;", 188 }, 
    { @"&frac12;", 189 }, 
    { @"&frac34;", 190 }, 
    { @"&iquest;", 191 }, 
    { @"&Agrave;", 192 }, 
    { @"&Aacute;", 193 }, 
    { @"&Acirc;", 194 }, 
    { @"&Atilde;", 195 }, 
    { @"&Auml;", 196 }, 
    { @"&Aring;", 197 }, 
    { @"&AElig;", 198 }, 
    { @"&Ccedil;", 199 }, 
    { @"&Egrave;", 200 }, 
    { @"&Eacute;", 201 }, 
    { @"&Ecirc;", 202 }, 
    { @"&Euml;", 203 }, 
    { @"&Igrave;", 204 }, 
    { @"&Iacute;", 205 }, 
    { @"&Icirc;", 206 }, 
    { @"&Iuml;", 207 }, 
    { @"&ETH;", 208 }, 
    { @"&Ntilde;", 209 }, 
    { @"&Ograve;", 210 }, 
    { @"&Oacute;", 211 }, 
    { @"&Ocirc;", 212 }, 
    { @"&Otilde;", 213 }, 
    { @"&Ouml;", 214 }, 
    { @"&times;", 215 }, 
    { @"&Oslash;", 216 }, 
    { @"&Ugrave;", 217 }, 
    { @"&Uacute;", 218 }, 
    { @"&Ucirc;", 219 }, 
    { @"&Uuml;", 220 }, 
    { @"&Yacute;", 221 }, 
    { @"&THORN;", 222 }, 
    { @"&szlig;", 223 }, 
    { @"&agrave;", 224 }, 
    { @"&aacute;", 225 }, 
    { @"&acirc;", 226 }, 
    { @"&atilde;", 227 }, 
    { @"&auml;", 228 }, 
    { @"&aring;", 229 }, 
    { @"&aelig;", 230 }, 
    { @"&ccedil;", 231 }, 
    { @"&egrave;", 232 }, 
    { @"&eacute;", 233 }, 
    { @"&ecirc;", 234 }, 
    { @"&euml;", 235 }, 
    { @"&igrave;", 236 }, 
    { @"&iacute;", 237 }, 
    { @"&icirc;", 238 }, 
    { @"&iuml;", 239 }, 
    { @"&eth;", 240 }, 
    { @"&ntilde;", 241 }, 
    { @"&ograve;", 242 }, 
    { @"&oacute;", 243 }, 
    { @"&ocirc;", 244 }, 
    { @"&otilde;", 245 }, 
    { @"&ouml;", 246 }, 
    { @"&divide;", 247 }, 
    { @"&oslash;", 248 }, 
    { @"&ugrave;", 249 }, 
    { @"&uacute;", 250 }, 
    { @"&ucirc;", 251 }, 
    { @"&uuml;", 252 }, 
    { @"&yacute;", 253 }, 
    { @"&thorn;", 254 }, 
    { @"&yuml;", 255 },
    
    // A.2.2. Special characters cont'd
    { @"&OElig;", 338 },
    { @"&oelig;", 339 },
    { @"&Scaron;", 352 },
    { @"&scaron;", 353 },
    { @"&Yuml;", 376 },
    
    // A.2.3. Symbols
    { @"&fnof;", 402 }, 
    
    // A.2.2. Special characters cont'd
    { @"&circ;", 710 },
    { @"&tilde;", 732 },
    
    // A.2.3. Symbols cont'd
    { @"&Alpha;", 913 }, 
    { @"&Beta;", 914 }, 
    { @"&Gamma;", 915 }, 
    { @"&Delta;", 916 }, 
    { @"&Epsilon;", 917 }, 
    { @"&Zeta;", 918 }, 
    { @"&Eta;", 919 }, 
    { @"&Theta;", 920 }, 
    { @"&Iota;", 921 }, 
    { @"&Kappa;", 922 }, 
    { @"&Lambda;", 923 }, 
    { @"&Mu;", 924 }, 
    { @"&Nu;", 925 }, 
    { @"&Xi;", 926 }, 
    { @"&Omicron;", 927 }, 
    { @"&Pi;", 928 }, 
    { @"&Rho;", 929 }, 
    { @"&Sigma;", 931 }, 
    { @"&Tau;", 932 }, 
    { @"&Upsilon;", 933 }, 
    { @"&Phi;", 934 }, 
    { @"&Chi;", 935 }, 
    { @"&Psi;", 936 }, 
    { @"&Omega;", 937 }, 
    { @"&alpha;", 945 }, 
    { @"&beta;", 946 }, 
    { @"&gamma;", 947 }, 
    { @"&delta;", 948 }, 
    { @"&epsilon;", 949 }, 
    { @"&zeta;", 950 }, 
    { @"&eta;", 951 }, 
    { @"&theta;", 952 }, 
    { @"&iota;", 953 }, 
    { @"&kappa;", 954 }, 
    { @"&lambda;", 955 }, 
    { @"&mu;", 956 }, 
    { @"&nu;", 957 }, 
    { @"&xi;", 958 }, 
    { @"&omicron;", 959 }, 
    { @"&pi;", 960 }, 
    { @"&rho;", 961 }, 
    { @"&sigmaf;", 962 }, 
    { @"&sigma;", 963 }, 
    { @"&tau;", 964 }, 
    { @"&upsilon;", 965 }, 
    { @"&phi;", 966 }, 
    { @"&chi;", 967 }, 
    { @"&psi;", 968 }, 
    { @"&omega;", 969 }, 
    { @"&thetasym;", 977 }, 
    { @"&upsih;", 978 }, 
    { @"&piv;", 982 }, 
    
    // A.2.2. Special characters cont'd
    { @"&ensp;", 8194 },
    { @"&emsp;", 8195 },
    { @"&thinsp;", 8201 },
    { @"&zwnj;", 8204 },
    { @"&zwj;", 8205 },
    { @"&lrm;", 8206 },
    { @"&rlm;", 8207 },
    { @"&ndash;", 8211 },
    { @"&mdash;", 8212 },
    { @"&lsquo;", 8216 },
    { @"&rsquo;", 8217 },
    { @"&sbquo;", 8218 },
    { @"&ldquo;", 8220 },
    { @"&rdquo;", 8221 },
    { @"&bdquo;", 8222 },
    { @"&dagger;", 8224 },
    { @"&Dagger;", 8225 },
    // A.2.3. Symbols cont'd  
    { @"&bull;", 8226 }, 
    { @"&hellip;", 8230 }, 
    
    // A.2.2. Special characters cont'd
    { @"&permil;", 8240 },
    
    // A.2.3. Symbols cont'd  
    { @"&prime;", 8242 }, 
    { @"&Prime;", 8243 }, 
    
    // A.2.2. Special characters cont'd
    { @"&lsaquo;", 8249 },
    { @"&rsaquo;", 8250 },
    
    // A.2.3. Symbols cont'd  
    { @"&oline;", 8254 }, 
    { @"&frasl;", 8260 }, 
    
    // A.2.2. Special characters cont'd
    { @"&euro;", 8364 },
    
    // A.2.3. Symbols cont'd  
    { @"&image;", 8465 },
    { @"&weierp;", 8472 }, 
    { @"&real;", 8476 }, 
    { @"&trade;", 8482 }, 
    { @"&alefsym;", 8501 }, 
    { @"&larr;", 8592 }, 
    { @"&uarr;", 8593 }, 
    { @"&rarr;", 8594 }, 
    { @"&darr;", 8595 }, 
    { @"&harr;", 8596 }, 
    { @"&crarr;", 8629 }, 
    { @"&lArr;", 8656 }, 
    { @"&uArr;", 8657 }, 
    { @"&rArr;", 8658 }, 
    { @"&dArr;", 8659 }, 
    { @"&hArr;", 8660 }, 
    { @"&forall;", 8704 }, 
    { @"&part;", 8706 }, 
    { @"&exist;", 8707 }, 
    { @"&empty;", 8709 }, 
    { @"&nabla;", 8711 }, 
    { @"&isin;", 8712 }, 
    { @"&notin;", 8713 }, 
    { @"&ni;", 8715 }, 
    { @"&prod;", 8719 }, 
    { @"&sum;", 8721 }, 
    { @"&minus;", 8722 }, 
    { @"&lowast;", 8727 }, 
    { @"&radic;", 8730 }, 
    { @"&prop;", 8733 }, 
    { @"&infin;", 8734 }, 
    { @"&ang;", 8736 }, 
    { @"&and;", 8743 }, 
    { @"&or;", 8744 }, 
    { @"&cap;", 8745 }, 
    { @"&cup;", 8746 }, 
    { @"&int;", 8747 }, 
    { @"&there4;", 8756 }, 
    { @"&sim;", 8764 }, 
    { @"&cong;", 8773 }, 
    { @"&asymp;", 8776 }, 
    { @"&ne;", 8800 }, 
    { @"&equiv;", 8801 }, 
    { @"&le;", 8804 }, 
    { @"&ge;", 8805 }, 
    { @"&sub;", 8834 }, 
    { @"&sup;", 8835 }, 
    { @"&nsub;", 8836 }, 
    { @"&sube;", 8838 }, 
    { @"&supe;", 8839 }, 
    { @"&oplus;", 8853 }, 
    { @"&otimes;", 8855 }, 
    { @"&perp;", 8869 }, 
    { @"&sdot;", 8901 }, 
    { @"&lceil;", 8968 }, 
    { @"&rceil;", 8969 }, 
    { @"&lfloor;", 8970 }, 
    { @"&rfloor;", 8971 }, 
    { @"&lang;", 9001 }, 
    { @"&rang;", 9002 }, 
    { @"&loz;", 9674 }, 
    { @"&spades;", 9824 }, 
    { @"&clubs;", 9827 }, 
    { @"&hearts;", 9829 }, 
    { @"&diams;", 9830 }
};

// Utility function for Bsearching table above
static int EscapeMapCompare(const void *ucharVoid, const void *mapVoid) {
    const unichar *uchar = (const unichar*)ucharVoid;
    const HTMLEscapeMap *map = (const HTMLEscapeMap*)mapVoid;
    int val;
    if (*uchar > map->uchar) {
        val = 1;
    } else if (*uchar < map->uchar) {
        val = -1;
    } else {
        val = 0;
    }
    return val;
}

@implementation TGStringUtils

+ (void)reset
{
    
}

+ (NSString *)stringByEscapingForURL:(NSString *)string
{
    static NSString * const kAFLegalCharactersToBeEscaped = @"?!@#$^&%*+=,:;'\"`<>()[]{}/\\|~ ";
    
    NSString *unescapedString = [string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (unescapedString == nil)
        unescapedString = string;
    
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)unescapedString, NULL, (CFStringRef)kAFLegalCharactersToBeEscaped, CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
}

+ (NSString *)stringByEncodingInBase64:(NSData *)data
{
    NSUInteger length = [data length];
    NSMutableData *mutableData = [[NSMutableData alloc] initWithLength:((length + 2) / 3) * 4];
    
    uint8_t *input = (uint8_t *)[data bytes];
    uint8_t *output = (uint8_t *)[mutableData mutableBytes];
    
    for (NSUInteger i = 0; i < length; i += 3)
    {
        NSUInteger value = 0;
        for (NSUInteger j = i; j < (i + 3); j++)
        {
            value <<= 8;
            if (j < length)
            {
                value |= (0xFF & input[j]);
            }
        }
        
        static uint8_t const kAFBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        
        NSUInteger idx = (i / 3) * 4;
        output[idx + 0] = kAFBase64EncodingTable[(value >> 18) & 0x3F];
        output[idx + 1] = kAFBase64EncodingTable[(value >> 12) & 0x3F];
        output[idx + 2] = (i + 1) < length ? kAFBase64EncodingTable[(value >> 6)  & 0x3F] : '=';
        output[idx + 3] = (i + 2) < length ? kAFBase64EncodingTable[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:mutableData encoding:NSASCIIStringEncoding];
}

+ (NSString *)stringByUnescapingFromHTML:(NSString *)srcString
{
    NSRange range = NSMakeRange(0, [srcString length]);
    NSRange subrange = [srcString rangeOfString:@"&" options:NSBackwardsSearch range:range];
    NSRange tagSubrange = NSMakeRange(0, 0);
    
    if (subrange.length == 0)
    {
        tagSubrange = [srcString rangeOfString:@"<" options:NSBackwardsSearch range:range];
        if (tagSubrange.length == 0)
            return srcString;
    }
    
    NSMutableString *finalString = [NSMutableString stringWithString:srcString];
    if (subrange.length != 0)
    {
        do
        {
            NSRange semiColonRange = NSMakeRange(subrange.location, NSMaxRange(range) - subrange.location);
            semiColonRange = [srcString rangeOfString:@";" options:0 range:semiColonRange];
            range = NSMakeRange(0, subrange.location);
            // if we don't find a semicolon in the range, we don't have a sequence
            if (semiColonRange.location == NSNotFound)
            {
                continue;
            }
            NSRange escapeRange = NSMakeRange(subrange.location, semiColonRange.location - subrange.location + 1);
            NSString *escapeString = [srcString substringWithRange:escapeRange];
            NSUInteger length = [escapeString length];
            
            // a squence must be longer than 3 (&lt;) and less than 11 (&thetasym;)
            if (length > 3 && length < 11)
            {
                if ([escapeString characterAtIndex:1] == '#')
                {
                    unichar char2 = [escapeString characterAtIndex:2];
                    if (char2 == 'x' || char2 == 'X') {
                        // Hex escape squences &#xa3;
                        NSString *hexSequence = [escapeString substringWithRange:NSMakeRange(3, length - 4)];
                        NSScanner *scanner = [NSScanner scannerWithString:hexSequence];
                        unsigned value;
                        if ([scanner scanHexInt:&value] && 
                            value < USHRT_MAX &&
                            value > 0 
                            && [scanner scanLocation] == length - 4) {
                            unichar uchar = (unichar)value;
                            NSString *charString = [NSString stringWithCharacters:&uchar length:1];
                            [finalString replaceCharactersInRange:escapeRange withString:charString];
                        }
                        
                    }
                    else
                    {
                        // Decimal Sequences &#123;
                        NSString *numberSequence = [escapeString substringWithRange:NSMakeRange(2, length - 3)];
                        NSScanner *scanner = [NSScanner scannerWithString:numberSequence];
                        int value;
                        if ([scanner scanInt:&value] && 
                            value < USHRT_MAX &&
                            value > 0 
                            && [scanner scanLocation] == length - 3)
                        {
                            unichar uchar = (unichar)value;
                            NSString *charString = [NSString stringWithCharacters:&uchar length:1];
                            [finalString replaceCharactersInRange:escapeRange withString:charString];
                        }
                    }
                }
                else
                {
                    for (unsigned i = 0; i < sizeof(gAsciiHTMLEscapeMap) / sizeof(HTMLEscapeMap); ++i)
                    {
                        if ([escapeString isEqualToString:gAsciiHTMLEscapeMap[i].escapeSequence])
                        {
                            [finalString replaceCharactersInRange:escapeRange withString:[NSString stringWithCharacters:&gAsciiHTMLEscapeMap[i].uchar length:1]];
                            break;
                        }
                    }
                }
            }
        } while ((subrange = [srcString rangeOfString:@"&" options:NSBackwardsSearch range:range]).length != 0);
    }
    
    [finalString replaceOccurrencesOfString:@"<br/>" withString:@"\n" options:NSLiteralSearch range:NSMakeRange(0, finalString.length)];
    
    return finalString;
}

+ (NSString *)stringWithLocalizedNumber:(NSInteger)number
{
    return [self stringWithLocalizedNumberCharacters:[[NSString alloc] initWithFormat:@"%d", number]];
}

+ (NSString *)stringWithLocalizedNumberCharacters:(NSString *)string
{
    NSString *resultString = string;
    
    if (TGIsArabic())
    {
        static NSString *arabicNumbers = @"٠١٢٣٤٥٦٧٨٩";
        NSMutableString *mutableString = [[NSMutableString alloc] init];
        for (int i = 0; i < (int)string.length; i++)
        {
            unichar c = [string characterAtIndex:i];
            if (c >= '0' && c <= '9')
                [mutableString replaceCharactersInRange:NSMakeRange(mutableString.length, 0) withString:[arabicNumbers substringWithRange:NSMakeRange(c - '0', 1)]];
            else
                [mutableString replaceCharactersInRange:NSMakeRange(mutableString.length, 0) withString:[string substringWithRange:NSMakeRange(i, 1)]];
        }
        resultString = mutableString;
    }
    
    return resultString;
}

+ (NSString *)md5:(NSString *)string
{
    /*static const char *md5PropertyKey = "MD5Key";
    NSString *result = objc_getAssociatedObject(string, md5PropertyKey);
    if (result != nil)
        return result;*/

    const char *ptr = [string UTF8String];
    unsigned char md5Buffer[16];
    CC_MD5(ptr, [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding], md5Buffer);
    NSString *output = [[NSString alloc] initWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", md5Buffer[0], md5Buffer[1], md5Buffer[2], md5Buffer[3], md5Buffer[4], md5Buffer[5], md5Buffer[6], md5Buffer[7], md5Buffer[8], md5Buffer[9], md5Buffer[10], md5Buffer[11], md5Buffer[12], md5Buffer[13], md5Buffer[14], md5Buffer[15]];
    //objc_setAssociatedObject(string, md5PropertyKey, output, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return output;
}

+ (NSDictionary *)argumentDictionaryInUrlString:(NSString *)string
{
    NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
    NSArray *urlComponents = [string componentsSeparatedByString:@"&"];

    for (NSString *keyValuePair in urlComponents)
    {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        if (pairComponents.count == 2)
        {
            NSString *key = [pairComponents objectAtIndex:0];
            NSString *value = [[[pairComponents objectAtIndex:1] stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [queryStringDictionary setObject:value forKey:key];
        }
    }
    
    return queryStringDictionary;
}

+ (bool)stringContainsEmoji:(NSString *)string
{
    __block bool returnValue = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, __unused NSRange substringRange, __unused NSRange enclosingRange, __unused BOOL *stop)
    {
         const unichar hs = [substring characterAtIndex:0];

         if (0xd800 <= hs && hs <= 0xdbff)
         {
             if (substring.length > 1)
             {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f)
                 {
                     returnValue = YES;
                 }
             }
         } else if (substring.length > 1)
         {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3)
             {
                 returnValue = YES;
             }
             
         } else
         {
             if (0x2100 <= hs && hs <= 0x27ff)
             {
                 returnValue = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07)
             {
                 returnValue = YES;
             } else if (0x2934 <= hs && hs <= 0x2935)
             {
                 returnValue = YES;
             } else if (0x3297 <= hs && hs <= 0x3299)
             {
                 returnValue = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50)
             {
                 returnValue = YES;
             }
         }
        
        if (returnValue && stop != NULL)
            *stop = true;
     }];
    
    return returnValue;
}

+ (NSString *)stringForMessageTimerSeconds:(NSUInteger)seconds
{
    if (seconds < 60)
    {
        int number = seconds;
        
        NSString *format = TGLocalized(@"MessageTimer.Seconds_any");
        if (number == 1)
            format = TGLocalized(@"MessageTimer.Seconds_1");
        else if (number == 2)
            format = TGLocalized(@"MessageTimer.Seconds_2");
        else if (number == 4)
            format = TGLocalized(@"MessageTimer.Seconds_3_10");
        
        return [[NSString alloc] initWithFormat:format, [[NSString alloc] initWithFormat:@"%d", number]];
    }
    else if (seconds < 60 * 60)
    {
        int number = seconds / 60;
        
        NSString *format = TGLocalized(@"MessageTimer.Minutes_any");
        if (number == 1)
            format = TGLocalized(@"MessageTimer.Minutes_1");
        else if (number == 2)
            format = TGLocalized(@"MessageTimer.Minutes_2");
        else if (number == 4)
            format = TGLocalized(@"MessageTimer.Minutes_3_10");
        
        return [[NSString alloc] initWithFormat:format, [[NSString alloc] initWithFormat:@"%d", number]];
    }
    else if (seconds < 60 * 60 * 24)
    {
        int number = seconds / (60 * 60);
        
        NSString *format = TGLocalized(@"MessageTimer.Hours_any");
        if (number == 1)
            format = TGLocalized(@"MessageTimer.Hours_1");
        else if (number == 2)
            format = TGLocalized(@"MessageTimer.Hours_2");
        else if (number == 4)
            format = TGLocalized(@"MessageTimer.Hours_3_10");
        
        return [[NSString alloc] initWithFormat:format, [[NSString alloc] initWithFormat:@"%d", number]];
    }
    else if (seconds < 60 * 60 * 24 * 7)
    {
        int number = seconds / (60 * 60 * 24);
        
        NSString *format = TGLocalized(@"MessageTimer.Days_any");
        if (number == 1)
            format = TGLocalized(@"MessageTimer.Days_1");
        else if (number == 2)
            format = TGLocalized(@"MessageTimer.Days_2");
        else if (number == 4)
            format = TGLocalized(@"MessageTimer.Days_3_10");
        
        return [[NSString alloc] initWithFormat:format, [[NSString alloc] initWithFormat:@"%d", number]];
    }
    else
    {
        int number = seconds / (60 * 60 * 24 * 7);
        
        NSString *format = TGLocalized(@"MessageTimer.Weeks_any");
        if (number == 1)
            format = TGLocalized(@"MessageTimer.Weeks_1");
        else if (number == 2)
            format = TGLocalized(@"MessageTimer.Weeks_2");
        else if (number == 4)
            format = TGLocalized(@"MessageTimer.Weeks_3_10");
        
        return [[NSString alloc] initWithFormat:format, [[NSString alloc] initWithFormat:@"%d", number]];
    }
    
    return @"";
}

+ (NSString *)stringForShortMessageTimerSeconds:(NSUInteger)seconds
{
    if (seconds < 60)
    {
        int number = seconds;
        
        NSString *format = TGLocalized(@"MessageTimer.ShortSeconds_any");
        if (number == 1)
            format = TGLocalized(@"MessageTimer.ShortSeconds_1");
        else if (number == 2)
            format = TGLocalized(@"MessageTimer.ShortSeconds_2");
        else if (number == 4)
            format = TGLocalized(@"MessageTimer.ShortSeconds_3_10");
        
        return [[NSString alloc] initWithFormat:format, [[NSString alloc] initWithFormat:@"%d", number]];
    }
    else if (seconds < 60 * 60)
    {
        int number = seconds / 60;
        
        NSString *format = TGLocalized(@"MessageTimer.ShortMinutes_any");
        if (number == 1)
            format = TGLocalized(@"MessageTimer.ShortMinutes_1");
        else if (number == 2)
            format = TGLocalized(@"MessageTimer.ShortMinutes_2");
        else if (number == 4)
            format = TGLocalized(@"MessageTimer.ShortMinutes_3_10");
        
        return [[NSString alloc] initWithFormat:format, [[NSString alloc] initWithFormat:@"%d", number]];
    }
    else if (seconds < 60 * 60 * 24)
    {
        int number = seconds / (60 * 60);
        
        NSString *format = TGLocalized(@"MessageTimer.ShortHours_any");
        if (number == 1)
            format = TGLocalized(@"MessageTimer.ShortHours_1");
        else if (number == 2)
            format = TGLocalized(@"MessageTimer.ShortHours_2");
        else if (number == 4)
            format = TGLocalized(@"MessageTimer.ShortHours_3_10");
        
        return [[NSString alloc] initWithFormat:format, [[NSString alloc] initWithFormat:@"%d", number]];
    }
    else if (seconds < 60 * 60 * 24 * 7)
    {
        int number = seconds / (60 * 60 * 24);
        
        NSString *format = TGLocalized(@"MessageTimer.ShortDays_any");
        if (number == 1)
            format = TGLocalized(@"MessageTimer.ShortDays_1");
        else if (number == 2)
            format = TGLocalized(@"MessageTimer.ShortDays_2");
        else if (number == 4)
            format = TGLocalized(@"MessageTimer.ShortDays_3_10");
        
        return [[NSString alloc] initWithFormat:format, [[NSString alloc] initWithFormat:@"%d", number]];
    }
    else
    {
        int number = seconds / (60 * 60 * 24 * 7);
        
        NSString *format = TGLocalized(@"MessageTimer.ShortWeeks_any");
        if (number == 1)
            format = TGLocalized(@"MessageTimer.ShortWeeks_1");
        else if (number == 2)
            format = TGLocalized(@"MessageTimer.ShortWeeks_2");
        else if (number == 4)
            format = TGLocalized(@"MessageTimer.ShortWeeks_3_10");
        
        return [[NSString alloc] initWithFormat:format, [[NSString alloc] initWithFormat:@"%d", number]];
    }
    
    return @"";
}

+ (NSArray *)stringComponentsForMessageTimerSeconds:(NSUInteger)seconds
{
    NSString *first = @"";
    NSString *second = @"";
    
    if (seconds < 60)
    {
        int number = seconds;
        
        NSString *format = TGLocalized(@"MessageTimer.Seconds_any");
        if (number == 1)
            format = TGLocalized(@"MessageTimer.Seconds_1");
        else if (number == 2)
            format = TGLocalized(@"MessageTimer.Seconds_2");
        else if (number == 4)
            format = TGLocalized(@"MessageTimer.Seconds_3_10");
        
        NSRange range = [format rangeOfString:@"%@"];
        if (range.location != NSNotFound)
        {
            first = [[NSString alloc] initWithFormat:@"%d", number];
            second = [[format substringFromIndex:range.location + range.length] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
    else if (seconds < 60 * 60)
    {
        int number = seconds / 60;

        NSString *format = TGLocalized(@"MessageTimer.Minutes_any");
        if (number == 1)
            format = TGLocalized(@"MessageTimer.Minutes_1");
        else if (number == 2)
            format = TGLocalized(@"MessageTimer.Minutes_2");
        else if (number == 4)
            format = TGLocalized(@"MessageTimer.Minutes_3_10");
        
        NSRange range = [format rangeOfString:@"%@"];
        if (range.location != NSNotFound)
        {
            first = [[NSString alloc] initWithFormat:@"%d", number];
            second = [[format substringFromIndex:range.location + range.length] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
    else if (seconds < 60 * 60 * 24)
    {
        int number = seconds / (60 * 60);

        NSString *format = TGLocalized(@"MessageTimer.Hours_any");
        if (number == 1)
            format = TGLocalized(@"MessageTimer.Hours_1");
        else if (number == 2)
            format = TGLocalized(@"MessageTimer.Hours_2");
        else if (number == 4)
            format = TGLocalized(@"MessageTimer.Hours_3_10");
        
        NSRange range = [format rangeOfString:@"%@"];
        if (range.location != NSNotFound)
        {
            first = [[NSString alloc] initWithFormat:@"%d", number];
            second = [[format substringFromIndex:range.location + range.length] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
    else if (seconds < 60 * 60 * 24 * 7)
    {
        int number = seconds / (60 * 60 * 24);

        NSString *format = TGLocalized(@"MessageTimer.Days_any");
        if (number == 1)
            format = TGLocalized(@"MessageTimer.Days_1");
        else if (number == 2)
            format = TGLocalized(@"MessageTimer.Days_2");
        else if (number == 4)
            format = TGLocalized(@"MessageTimer.Days_3_10");
        
        NSRange range = [format rangeOfString:@"%@"];
        if (range.location != NSNotFound)
        {
            first = [[NSString alloc] initWithFormat:@"%d", number];
            second = [[format substringFromIndex:range.location + range.length] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
    else
    {
        int number = seconds / (60 * 60 * 24 * 7);
        
        NSString *format = TGLocalized(@"MessageTimer.Weeks_any");
        if (number == 1)
            format = TGLocalized(@"MessageTimer.Weeks_1");
        else if (number == 2)
            format = TGLocalized(@"MessageTimer.Weeks_2");
        else if (number == 4)
            format = TGLocalized(@"MessageTimer.Weeks_3_10");
        
        NSRange range = [format rangeOfString:@"%@"];
        if (range.location != NSNotFound)
        {
            first = [[NSString alloc] initWithFormat:@"%d", number];
            second = [[format substringFromIndex:range.location + range.length] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
    
    return @[first, second];
}

@end

#if defined(_MSC_VER)

#define FORCE_INLINE    __forceinline

#include <stdlib.h>

#define ROTL32(x,y)     _rotl(x,y)
#define ROTL64(x,y)     _rotl64(x,y)

#define BIG_CONSTANT(x) (x)

// Other compilers

#else   // defined(_MSC_VER)

#define FORCE_INLINE __attribute__((always_inline))

static inline uint32_t rotl32 ( uint32_t x, int8_t r )
{
    return (x << r) | (x >> (32 - r));
}

static inline uint64_t rotl64 ( uint64_t x, int8_t r )
{
    return (x << r) | (x >> (64 - r));
}

#define ROTL32(x,y)     rotl32(x,y)
#define ROTL64(x,y)     rotl64(x,y)

#define BIG_CONSTANT(x) (x##LLU)

#endif // !defined(_MSC_VER)

//-----------------------------------------------------------------------------
// Block read - if your platform needs to do endian-swapping or can only
// handle aligned reads, do the conversion here

static FORCE_INLINE uint32_t getblock ( const uint32_t * p, int i )
{
    return p[i];
}

static FORCE_INLINE uint64_t getblock ( const uint64_t * p, int i )
{
    return p[i];
}

//-----------------------------------------------------------------------------
// Finalization mix - force all bits of a hash block to avalanche

static FORCE_INLINE uint32_t fmix ( uint32_t h )
{
    h ^= h >> 16;
    h *= 0x85ebca6b;
    h ^= h >> 13;
    h *= 0xc2b2ae35;
    h ^= h >> 16;
    
    return h;
}

//----------

static FORCE_INLINE uint64_t fmix ( uint64_t k )
{
    k ^= k >> 33;
    k *= BIG_CONSTANT(0xff51afd7ed558ccd);
    k ^= k >> 33;
    k *= BIG_CONSTANT(0xc4ceb9fe1a85ec53);
    k ^= k >> 33;
    
    return k;
}

//-----------------------------------------------------------------------------

static void MurmurHash3_x86_32 ( const void * key, int len,
                         uint32_t seed, void * out )
{
    const uint8_t * data = (const uint8_t*)key;
    const int nblocks = len / 4;
    
    uint32_t h1 = seed;
    
    const uint32_t c1 = 0xcc9e2d51;
    const uint32_t c2 = 0x1b873593;
    
    //----------
    // body
    
    const uint32_t * blocks = (const uint32_t *)(data + nblocks*4);
    
    for(int i = -nblocks; i; i++)
    {
        uint32_t k1 = getblock(blocks,i);
        
        k1 *= c1;
        k1 = ROTL32(k1,15);
        k1 *= c2;
        
        h1 ^= k1;
        h1 = ROTL32(h1,13);
        h1 = h1*5+0xe6546b64;
    }
    
    //----------
    // tail
    
    const uint8_t * tail = (const uint8_t*)(data + nblocks*4);
    
    uint32_t k1 = 0;
    
    switch(len & 3)
    {
        case 3: k1 ^= tail[2] << 16;
        case 2: k1 ^= tail[1] << 8;
        case 1: k1 ^= tail[0];
            k1 *= c1; k1 = ROTL32(k1,15); k1 *= c2; h1 ^= k1;
    };
    
    //----------
    // finalization
    
    h1 ^= len;
    
    h1 = fmix(h1);
    
    *(uint32_t*)out = h1;
}

int32_t murMurHash32(NSString *string)
{
    const char *utf8 = string.UTF8String;
    
    int32_t result = 0;
    MurmurHash3_x86_32((uint8_t *)utf8, strlen(utf8), -137723950, &result);
    
    return result;
}

int32_t murMurHashBytes32(void *bytes, int length)
{
    int32_t result = 0;
    MurmurHash3_x86_32(bytes, length, -137723950, &result);
    
    return result;
}

int32_t phoneMatchHash(NSString *phone)
{
    int length = phone.length;
    char cleanString[length];
    int cleanLength = 0;
    
    for (int i = 0; i < length; i++)
    {
        unichar c = [phone characterAtIndex:i];
        if (c >= '0' && c <= '9')
            cleanString[cleanLength++] = (char)c;
    }
    
    int32_t result = 0;
    if (cleanLength > 8)
        MurmurHash3_x86_32((uint8_t *)cleanString + (cleanLength - 8), 8, -137723950, &result);
    else
        MurmurHash3_x86_32((uint8_t *)cleanString, cleanLength, -137723950, &result);
    
    return result;
}

bool TGIsRTL()
{
    static bool value = false;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        value = ([NSLocale characterDirectionForLanguage:[[NSLocale preferredLanguages] objectAtIndex:0]] == NSLocaleLanguageDirectionRightToLeft);
    });
    
    return value;
}

bool TGIsArabic()
{
    static bool value = false;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
        value = [language isEqualToString:@"ar"];
    });
    return value;
}

bool TGIsLocaleArabic()
{
    static bool value = false;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        NSString *identifier = [[NSLocale currentLocale] localeIdentifier];
        value = [identifier isEqualToString:@"ar"] || [identifier hasPrefix:@"ar_"];
    });
    return value;
}

@implementation NSString (Telegraph)

- (int)lengthByComposedCharacterSequences
{
    return [self lengthByComposedCharacterSequencesInRange:NSMakeRange(0, self.length)];
}

- (int)lengthByComposedCharacterSequencesInRange:(NSRange)range
{
    __block NSInteger length = 0;
    [self enumerateSubstringsInRange:range options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(__unused NSString *substring, __unused NSRange substringRange, __unused NSRange enclosingRange, __unused BOOL *stop)
    {
        if (substring.length != 0)
            length++;
        //TGLog(@"substringRange %@, enclosingRange %@, length %d", NSStringFromRange(substringRange), NSStringFromRange(enclosingRange), length);
    }];
    //TGLog(@"length %d", length);
    
    return length;
}

static unsigned char strToChar (char a, char b)
{
    char encoder[3] = {'\0','\0','\0'};
    encoder[0] = a;
    encoder[1] = b;
    return (char)strtol(encoder,NULL,16);
}

- (NSData *)dataByDecodingHexString
{
    const char *bytes = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSUInteger length = strlen(bytes);
    unsigned char *r = (unsigned char *)malloc(length / 2);
    unsigned char *index = r;
    
    while ((*bytes) && (*(bytes + 1)))
    {
        *index = strToChar(*bytes, *(bytes +1));
        index++;
        bytes+=2;
    }
    
    return [[NSData alloc] initWithBytesNoCopy:r length:length / 2 freeWhenDone:true];
}

@end

@implementation NSData (Telegraph)

- (NSString *)stringByEncodingInHex
{
    const unsigned char *dataBuffer = (const unsigned char *)[self bytes];
    if (dataBuffer == NULL)
        return [NSString string];
    
    NSUInteger dataLength  = [self length];
    NSMutableString *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    
    return hexString;
}

@end
