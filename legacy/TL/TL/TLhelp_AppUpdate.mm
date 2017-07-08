#import "TLhelp_AppUpdate.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLhelp_AppUpdate


- (int32_t)TLconstructorSignature
{
    TGLog(@"constructorSignature is not implemented for base type");
    return 0;
}

- (int32_t)TLconstructorName
{
    TGLog(@"constructorName is not implemented for base type");
    return 0;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TGLog(@"TLbuildFromMetaObject is not implemented for base type");
    return nil;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
    TGLog(@"TLfillFieldsWithValues is not implemented for base type");
}


@end

@implementation TLhelp_AppUpdate$help_appUpdate : TLhelp_AppUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x8987f311;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x11b83f18;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLhelp_AppUpdate$help_appUpdate *object = [[TLhelp_AppUpdate$help_appUpdate alloc] init];
    object.n_id = metaObject->getInt32((int32_t)0x7a5601fb);
    object.critical = metaObject->getBool((int32_t)0xafb46cdb);
    object.url = metaObject->getString((int32_t)0xeaf7861e);
    object.text = metaObject->getString((int32_t)0x94f1580d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7a5601fb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.critical;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xafb46cdb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.url;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xeaf7861e, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.text;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x94f1580d, value));
    }
}


@end

@implementation TLhelp_AppUpdate$help_noAppUpdate : TLhelp_AppUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xc45a6536;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xf22462b1;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLhelp_AppUpdate$help_noAppUpdate *object = [[TLhelp_AppUpdate$help_noAppUpdate alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

