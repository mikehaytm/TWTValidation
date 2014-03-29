//
//  TWTCompoundValidator.m
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/28/2014.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import <TWTValidation/TWTCompoundValidator.h>

@implementation TWTCompoundValidator

- (instancetype)init
{
    return [self initWithType:TWTCompoundValidatorTypeAnd subvalidators:@[ ]];
}


- (instancetype)initWithType:(TWTCompoundValidatorType)type subvalidators:(NSArray *)subvalidators
{
    self = [super init];
    if (self) {
        _compoundValidatorType = type;
        _subvalidators = subvalidators ? [subvalidators copy] : @[ ];
    }

    return self;
}


+ (instancetype)andValidatorWithSubvalidators:(NSArray *)subvalidators
{
    return [[self alloc] initWithType:TWTCompoundValidatorTypeAnd subvalidators:subvalidators];
}


+ (instancetype)orValidatorWithSubvalidators:(NSArray *)subvalidators
{
    return [[self alloc] initWithType:TWTCompoundValidatorTypeOr subvalidators:subvalidators];
}


+ (instancetype)mutualExclusionValidatorWithSubvalidators:(NSArray *)subvalidators
{
    return [[self alloc] initWithType:TWTCompoundValidatorTypeMutualExclusion subvalidators:subvalidators];
}


- (instancetype)copyWithZone:(NSZone *)zone
{
    return [[[self class] alloc] initWithType:self.compoundValidatorType subvalidators:self.subvalidators];
}


- (NSUInteger)hash
{
    return [super hash] ^ self.compoundValidatorType ^ self.subvalidators.hash;
}


- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    }
    
    typeof(self) other = object;
    return other.compoundValidatorType == self.compoundValidatorType && [other.subvalidators isEqualToArray:self.subvalidators];
}


- (BOOL)validateValue:(id)value error:(out NSError *__autoreleasing *)outError
{
    // Only collect errors if outError is non-NULL
    NSMutableArray *errors = outError ? [[NSMutableArray alloc] init] : nil;

    NSUInteger validatedCount = 0;
    for (TWTValidator *subvalidator in self.subvalidators) {
        NSError *error = nil;

        // Only pass in an error if outError is non-nil. This will save the subvalidators some work
        if ([subvalidator validateValue:value error:outError ? &error : NULL]) {
            ++validatedCount;
        } else if (error) {
            [errors addObject:error];
        }
    }

    BOOL validated = NO;
    switch (self.compoundValidatorType) {
        case TWTCompoundValidatorTypeAnd:
            validated = validatedCount == self.subvalidators.count;
            break;
        case TWTCompoundValidatorTypeOr:
            validated = validatedCount > 0;
            break;
        case TWTCompoundValidatorTypeMutualExclusion:
            validated = validatedCount == 1;
            break;
    }
    
    if (!validated && outError) {
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
        switch (self.compoundValidatorType) {
            case TWTCompoundValidatorTypeAnd:
                userInfo[NSLocalizedDescriptionKey] = NSLocalizedString(@"one or more subvalidators failed",
                                                                        @"TWTValidationErrorCodeSubvalidatorError and error message");
                break;
            case TWTCompoundValidatorTypeOr:
                userInfo[NSLocalizedDescriptionKey] = NSLocalizedString(@"all subvalidators failed",
                                                                        @"TWTValidationErrorCodeSubvalidatorError or error message");
                break;
            case TWTCompoundValidatorTypeMutualExclusion:
                userInfo[NSLocalizedDescriptionKey] = NSLocalizedString(@"more than one subvalidator passed",
                                                                        @"TWTValidationErrorCodeSubvalidatorError mutual exclusion error message");
                break;
        }
        
        if (errors.count) {
            userInfo[TWTValidatorUnderlyingErrorsKey] = [errors copy];
        }

        *outError = [NSError errorWithDomain:TWTValidatorErrorDomain code:TWTValidationErrorCodeSubvalidatorError userInfo:[userInfo copy]];
    }

    return validated;
}

@end
