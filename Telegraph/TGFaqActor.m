#import "TGFaqActor.h"

#import "ActionStage.h"
#import "TGTelegraph.h"

@interface TGFaqActor () <TGRawHttpActor>

@end

@implementation TGFaqActor

+ (void)load
{
    [ASActor registerActorClass:self];
}

+ (NSString *)genericPath
{
    return @"/faq";
}

- (void)execute:(NSDictionary *)__unused options
{
    self.cancelToken = [TGTelegraphInstance doRequestRawHttp:@"https://telegram.org/faq" maxRetryCount:0 acceptCodes:@[@200] actor:self];
}

- (NSArray *)textWithLocationsInsideTags:(NSString *)text tag:(NSString *)tag
{
    NSRange range = [text rangeOfString:[[NSString alloc] initWithFormat:@"<%@", tag]];
    if (range.location == NSNotFound)
        return nil;
    NSRange tagEndRange = [text rangeOfString:@">" options:0 range:NSMakeRange(range.location + range.length, text.length - range.location - range.length)];
    if (tagEndRange.location == NSNotFound)
        return nil;
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSUInteger startOffset = tagEndRange.location + tagEndRange.length;
    NSUInteger contentStartOffset = startOffset;
    
    while (startOffset < text.length)
    {
        NSRange endRange = [text rangeOfString:[[NSString alloc] initWithFormat:@"</%@>", tag] options:0 range:NSMakeRange(startOffset, text.length - startOffset)];
        if (endRange.location == NSNotFound)
            break;
        
        NSString *contentText = [text substringWithRange:NSMakeRange(contentStartOffset, endRange.location - contentStartOffset)];
        [array addObject:@{@"text": contentText, @"location": @(range.location), @"length": @(endRange.location + endRange.length - range.location)}];
        
        range = [text rangeOfString:[[NSString alloc] initWithFormat:@"<%@", tag] options:0 range:NSMakeRange(endRange.location + endRange.length, text.length - endRange.location - endRange.length)];
        if (range.location == NSNotFound)
            break;
        tagEndRange = [text rangeOfString:@">" options:0 range:NSMakeRange(range.location + range.length, text.length - range.location - range.length)];
        if (tagEndRange.location == NSNotFound)
            break;
        
        startOffset = tagEndRange.location + tagEndRange.length;
        contentStartOffset = startOffset;
    }
    
    return array;
}

- (void)httpRequestSuccess:(NSString *)__unused url response:(NSData *)response
{
    NSString *text = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    NSArray *categoryList = [self textWithLocationsInsideTags:text tag:@"h3"];
    
    for (NSUInteger i = 0; i < categoryList.count; i++)
    {
        NSDictionary *category = categoryList[i];
        NSString *title = category[@"text"];
        
        NSString *categoryAnchor = @"";
        NSRange hrefRange = [title rangeOfString:@"href=\"#"];
        if (hrefRange.location != NSNotFound)
        {
            NSRange hrefEndRange = [title rangeOfString:@"\"" options:0 range:NSMakeRange(hrefRange.location + hrefRange.length, title.length - hrefRange.location - hrefRange.length)];
            if (hrefEndRange.location != NSNotFound)
            {
                categoryAnchor = [title substringWithRange:NSMakeRange(hrefRange.location + hrefRange.length, hrefEndRange.location - hrefRange.location - hrefRange.length)];
            }
        }
        
        NSRange tagRange = [title rangeOfString:@">" options:NSBackwardsSearch];
        if (tagRange.location != NSNotFound)
            title = [title substringFromIndex:tagRange.location + 1];
        
        NSUInteger location = [category[@"location"] unsignedIntegerValue] + [category[@"length"] unsignedIntegerValue];
        NSUInteger nextLocation = text.length;
        if (i + 1 < categoryList.count)
            nextLocation = [categoryList[i + 1][@"location"] unsignedIntegerValue];
        
        NSMutableArray *subcategories = [[NSMutableArray alloc] init];
        
        NSString *categoryText = [text substringWithRange:NSMakeRange(location, nextLocation - location)];
        NSArray *subcategoryList = [self textWithLocationsInsideTags:categoryText tag:@"h4"];
        for (NSUInteger j = 0; j < subcategoryList.count; j++)
        {
            NSDictionary *subcategory = subcategoryList[j];
            NSString *subcategoryTitle = subcategory[@"text"];
            
            NSString *subcategoryAnchor = @"";
            NSRange hrefRange = [subcategoryTitle rangeOfString:@"href=\"#"];
            if (hrefRange.location != NSNotFound)
            {
                NSRange hrefEndRange = [subcategoryTitle rangeOfString:@"\"" options:0 range:NSMakeRange(hrefRange.location + hrefRange.length, subcategoryTitle.length - hrefRange.location - hrefRange.length)];
                if (hrefEndRange.location != NSNotFound)
                {
                    subcategoryAnchor = [subcategoryTitle substringWithRange:NSMakeRange(hrefRange.location + hrefRange.length, hrefEndRange.location - hrefRange.location - hrefRange.length)];
                }
            }
            
            NSRange tagRange = [subcategoryTitle rangeOfString:@">" options:NSBackwardsSearch];
            if (tagRange.location != NSNotFound)
                subcategoryTitle = [subcategoryTitle substringFromIndex:tagRange.location + 1];
            
            NSUInteger subcategoryLocation = [subcategory[@"location"] unsignedIntegerValue];
            NSUInteger subcategoryLength = [subcategory[@"length"] unsignedIntegerValue];
            NSUInteger nextSubcategoryLocation = subcategoryLocation + subcategoryLength;
            if (j + 1 < subcategoryList.count)
                nextSubcategoryLocation = [subcategoryList[j + 1][@"location"] unsignedIntegerValue];
            else if (i + 1 < categoryList.count)
            {
                nextSubcategoryLocation = nextLocation - location;
            }
            else
            {
                NSRange endRange = [categoryText rangeOfString:@"</div>"];
                if (endRange.location != NSNotFound)
                    nextSubcategoryLocation = endRange.location;
            }
            
            NSString *subcategoryText = [categoryText substringWithRange:NSMakeRange(subcategoryLocation + subcategoryLength, nextSubcategoryLocation - subcategoryLocation - subcategoryLength)];
            subcategoryText = [subcategoryText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([subcategoryText hasSuffix:@"<hr>"])
            {
                subcategoryText = [subcategoryText substringToIndex:subcategoryText.length - @"<hr>".length];
                subcategoryText = [subcategoryText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];                
            }
            
            [subcategories addObject:@{@"title": subcategoryTitle, @"anchor": subcategoryAnchor, @"text": subcategoryText}];
        }
        
        [result addObject:@{@"title": title, @"anchor": categoryAnchor, @"subcategories": subcategories}];
    }
    
    [ActionStageInstance() actionCompleted:self.path result:result];
}

- (void)httpRequestFailed:(NSString *)__unused url
{
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

@end
