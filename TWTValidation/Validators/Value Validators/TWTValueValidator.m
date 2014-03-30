//
//  TWTValueValidator.m
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/28/2014.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import <TWTValidation/TWTValueValidator.h>

#import <TWTValidation/TWTValidationErrors.h>

@implementation TWTValueValidator

+ (instancetype)valueValidatorWithClass:(Class)valueClass allowsNil:(BOOL)allowsNil allowsNull:(BOOL)allowsNull
{
    TWTValueValidator *validator = [[self alloc] init];
    validator.valueClass = valueClass;
    validator.allowsNil = allowsNil;
    validator.allowsNull = allowsNull;
    return validator;
}


- (instancetype)copyWithZone:(NSZone *)zone
{
    return [[self class] valueValidatorWithClass:self.valueClass allowsNil:self.allowsNil allowsNull:self.allowsNull];
}


- (NSUInteger)hash
{
    return [super hash] ^ self.valueClass.hash;
}


- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    }
    
    typeof(self) other = object;
    return other.allowsNil == self.allowsNil && other.allowsNull == self.allowsNull && other.valueClass == self.valueClass;
}


- (BOOL)validateValue:(id)value error:(out NSError *__autoreleasing *)outError
{
    NSInteger errorCode = -1;

    if (!value) {
        if (self.allowsNil) {
            return YES;
        }

        errorCode = TWTValidationErrorCodeValueNil;
    } else if ([value isEqual:[NSNull null]]) {
        if (self.allowsNull) {
            return YES;
        }

        errorCode = TWTValidationErrorCodeValueNull;
    } else if (self.valueClass) {
        if ([[value class] isSubclassOfClass:self.valueClass]) {
            return YES;
        }

        errorCode = TWTValidationErrorCodeValueHasIncorrectClass;
    }

    // Construct the error based on the code
    if (outError) {
        NSString *description = nil;
        switch (errorCode) {
            case TWTValidationErrorCodeValueNil:
                description = NSLocalizedString(@"value is nil", @"TWTValidationErrorCodeValueNil error message");
                break;
            case TWTValidationErrorCodeValueNull:
                description = NSLocalizedString(@"value is null", @"TWTValidationErrorCodeValueNull error message");
                break;
            case TWTValidationErrorCodeValueHasIncorrectClass: {
                NSString *descriptionFormat = NSLocalizedString(@"value class (%1$@) is incompatible with required value class (%2$@)",
                                                                @"TWTValidationErrorCodeValueHasIncorrectClass error message");
                description = [NSString stringWithFormat:descriptionFormat, [value class], self.valueClass];
                break;
            }
        }

        *outError = [NSError twt_validationErrorWithCode:errorCode value:value localizedDescription:description];
    }
    
    return NO;
}

@end
