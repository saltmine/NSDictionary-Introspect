//
//  NSDictionary+Introspect.m
//
//  Created by Chamara Paul on 12/29/14.
//  Copyright (c) 2014 Keep.com. All rights reserved.
//

#import "NSDictionary+Introspect.h"
#import <objc/runtime.h>

static NSString * const CharTypeEncoding = @"c";
static NSString * const IntTypeEncoding = @"i";
static NSString * const ShortTypeEncoding = @"s";
static NSString * const LongTypeEncoding = @"l";
static NSString * const LongLongTypeEncoding = @"q";
static NSString * const UnsignedCharTypeEncoding = @"C";
static NSString * const UnsignedIntTypeEncoding = @"I";
static NSString * const UnsignedShortTypeEncoding = @"S";
static NSString * const UnsignedLongTypeEncoding = @"L";
static NSString * const UnsignedLongLongTypeEncoding = @"Q";
static NSString * const FloatTypeEncoding = @"f";
static NSString * const DoubleTypeEncoding = @"d";
static NSString * const BoolTypeEncoding = @"B";

static const char *getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            NSString *name = [[NSString alloc] initWithBytes:attribute + 1 length:strlen(attribute) - 1 encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding]; //primitive type
        } else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            return "id"; //id type
        } else if (attribute[0] == 'T' && attribute[1] == '@') {
            NSString *name = [[NSString alloc] initWithBytes:attribute + 3 length:strlen(attribute) - 4 encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding]; //object type
        }
    }
    
    return "";
}

@implementation NSObject (Introspect)

+ (NSDictionary *)dictionaryWithPropertiesOfObject:(id)object {
    if (object == NULL) {
        return nil;
    }
    
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList([object class], &count);
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (int i=0; i < count; i++) {
        objc_property_t property = properties[i];
        const char *propertyName = property_getName(property);
        NSString *key = [NSString stringWithCString:propertyName encoding:[NSString defaultCStringEncoding]];
        
        Class classObject = NSClassFromString([key capitalizedString]);
        if (classObject) {
            id subObject = [self dictionaryWithPropertiesOfObject:[object valueForKey:key]];
            dict[key] = subObject;
        } else if ([object isKindOfClass:[NSArray class]]) {
            NSMutableArray *subObject = [NSMutableArray array];
            for (id o in object) {
                [subObject addObject:[self dictionaryWithPropertiesOfObject:o]];
            }
            dict[key] = subObject;
        } else { //Set the value for each property, but we need to check for the correct type: object vs primitive vs whatever
            //For more info: https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
            //But, first let's not save properties of NSObject!!!
            if (![@"debugDescription" isEqualToString:@(propertyName)] &&
                ![@"description" isEqualToString:@(propertyName)] &&
                ![@"hash" isEqualToString:@(propertyName)] &&
                ![@"superclass" isEqualToString:@(propertyName)]) {
                const char *propertyType = getPropertyType(property);
                //printf("propertyType = %s\n", propertyType);
                if ([CharTypeEncoding isEqualToString:@(propertyType)] ||
                    [IntTypeEncoding isEqualToString:@(propertyType)] ||
                    [ShortTypeEncoding isEqualToString:@(propertyType)] ||
                    [LongTypeEncoding isEqualToString:@(propertyType)] ||
                    [LongLongTypeEncoding isEqualToString:@(propertyType)] ||
                    [UnsignedCharTypeEncoding isEqualToString:@(propertyType)] ||
                    [UnsignedIntTypeEncoding isEqualToString:@(propertyType)] ||
                    [UnsignedShortTypeEncoding isEqualToString:@(propertyType)] ||
                    [UnsignedLongTypeEncoding isEqualToString:@(propertyType)] ||
                    [UnsignedLongLongTypeEncoding isEqualToString:@(propertyType)] ||
                    [FloatTypeEncoding isEqualToString:@(propertyType)] ||
                    [DoubleTypeEncoding isEqualToString:@(propertyType)] ||
                    [BoolTypeEncoding isEqualToString:@(propertyType)]) { // primitive types
                    [dict setValue:[object valueForKey:key] forKey:key];
                } else if ([@"NSString" isEqualToString:@(propertyType)]) { //strings
                    if ([object valueForKey:key] != nil) {
                        [dict setValue:[object valueForKey:key] forKey:key];
                    } else {
                        dict[key] = [NSNull null];
                    }
                } else if ([object valueForKey:key] != nil) { //non-nil objects
                    dict[key] = [object valueForKey:key];
                } else if ([object valueForKey:key] == nil) { //nils
                    dict[key] = [NSNull null];
                }
            }
        }
    }
    
    free(properties);
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end
