//
//  TWTKeyedCollectionValidator.m
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/29/2014.
//  Copyright (c) 2014 Two Toasters, LLC.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <TWTValidation/TWTKeyedCollectionValidator.h>

#import <TWTValidation/TWTCompoundValidator.h>
#import <TWTValidation/TWTValidationErrors.h>
#import <TWTValidation/TWTValidationLocalization.h>


#pragma Key-Value Pair Validator

@interface TWTKeyValuePairValidator ()

@property (nonatomic, strong, readwrite) id key;
@property (nonatomic, strong, readwrite) TWTValidator *valueValidator;

@end


@implementation TWTKeyValuePairValidator

- (instancetype)init
{
    return [self initWithKey:nil valueValidator:nil];
}


- (instancetype)initWithKey:(id)key valueValidator:(TWTValidator *)valueValidator
{
    NSParameterAssert(key);
    self = [super init];
    if (self) {
        _key = key;
        _valueValidator = valueValidator;
    }

    return self;
}


- (NSUInteger)hash
{
    return [super hash] ^ [self.key hash] ^ self.valueValidator.hash;
}


- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    } else if (self == object) {
        return YES;
    }

    typeof(self) other = object;
    return [other.key isEqual:self.key] && [other.valueValidator isEqual:self.valueValidator];
}


- (BOOL)validateValue:(id)value error:(out NSError *__autoreleasing *)outError
{
    return !self.valueValidator || [self.valueValidator validateValue:value error:outError];
}

@end


#pragma mark

@interface TWTKeyedCollectionValidator ()

@property (nonatomic, strong, readwrite) TWTValidator *countValidator;
@property (nonatomic, strong) TWTCompoundValidator *keyAndValidator;
@property (nonatomic, strong) TWTCompoundValidator *valueAndValidator;

@property (nonatomic, copy, readwrite) NSArray *keyValuePairValidators;
@property (nonatomic, strong) NSMapTable *keyValuePairAndValidators;

@end


#pragma mark

@implementation TWTKeyedCollectionValidator

- (instancetype)init
{
    return [self initWithCountValidator:nil keyValidators:nil valueValidators:nil keyValuePairValidators:nil];
}


- (instancetype)initWithCountValidator:(TWTValidator *)countValidator
                         keyValidators:(NSArray *)keyValidators
                       valueValidators:(NSArray *)valueValidators
                keyValuePairValidators:(NSArray *)keyValuePairValidators
{
    self = [super init];
    if (self) {
        _countValidator = countValidator;
        _keyAndValidator = [TWTCompoundValidator andValidatorWithSubvalidators:keyValidators];
        _valueAndValidator = [TWTCompoundValidator andValidatorWithSubvalidators:valueValidators];
        _keyValuePairValidators = [keyValuePairValidators copy];
        
        // Group all our pair validators by their key
        NSMapTable *pairValidatorsByKey = [NSMapTable strongToStrongObjectsMapTable];
        for (TWTKeyValuePairValidator *pairValidator in keyValuePairValidators) {
            NSMutableArray *validators = [pairValidatorsByKey objectForKey:pairValidator.key];
            if (!validators) {
                validators = [[NSMutableArray alloc] init];
                [pairValidatorsByKey setObject:validators forKey:pairValidator.key];
            }
            
            [validators addObject:pairValidator];
        }
        
        _keyValuePairAndValidators = [NSMapTable strongToStrongObjectsMapTable];
        for (id key in pairValidatorsByKey) {
            [_keyValuePairAndValidators setObject:[TWTCompoundValidator andValidatorWithSubvalidators:[pairValidatorsByKey objectForKey:key]]
                                           forKey:key];
        }
    }
    
    return self;
}


- (NSUInteger)hash
{
    return [super hash] ^ self.countValidator.hash ^ self.keyAndValidator.hash ^ self.valueAndValidator.hash ^ self.keyValuePairAndValidators.hash;
}


- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    } else if (self == object) {
        return YES;
    }
    
    typeof(self) other = object;
    return [other.countValidator isEqual:self.countValidator] && [other.keyAndValidator isEqual:self.keyAndValidator] &&
        [other.valueAndValidator isEqual:self.valueAndValidator] && [other.keyValuePairAndValidators isEqual:self.keyValuePairAndValidators];
}


- (NSArray *)keyValidators
{
    return self.keyAndValidator.subvalidators;
}


- (NSArray *)valueValidators
{
    return self.valueAndValidator.subvalidators;
}


- (BOOL)validateValue:(id)keyedCollection error:(out NSError *__autoreleasing *)outError
{
    if (![super validateValue:keyedCollection error:outError]) {
        return NO;
    }

    NSError *countValidationError = nil;
    BOOL countValidated = YES;
    if (self.countValidator) {
        countValidated = [self.countValidator validateValue:@([keyedCollection count]) error:outError ? &countValidationError : NULL];
    }

    BOOL keysValidated = YES;
    BOOL valuesValidated = YES;
    BOOL pairsValidated = YES;
    
    NSMutableArray *keyValidationErrors = outError ? [[NSMutableArray alloc] init] : nil;
    NSMutableArray *valueValidationErrors = outError ? [[NSMutableArray alloc] init] : nil;
    NSMutableArray *pairValidationErrors = outError ? [[NSMutableArray alloc] init] : nil;

    for (id key in keyedCollection) {
        NSError *error = nil;
        if (![self.keyAndValidator validateValue:key error:outError ? &error : NULL]) {
            keysValidated = NO;
            [keyValidationErrors addObjectsFromArray:error.twt_underlyingErrors];
        }
        
        id value = [keyedCollection objectForKey:key];
        error = nil;
        if (![self.valueAndValidator validateValue:value error:outError ? &error : NULL]) {
            valuesValidated = NO;
            [valueValidationErrors addObjectsFromArray:error.twt_underlyingErrors];
        }
        
        TWTCompoundValidator *pairAndValidator = [self.keyValuePairAndValidators objectForKey:key];
        error = nil;
        if (pairAndValidator && ![pairAndValidator validateValue:value error:outError ? &error : NULL]) {
            pairsValidated = NO;
            [pairValidationErrors addObjectsFromArray:error.twt_underlyingErrors];
        }
    }
    
    BOOL validated = countValidated && keysValidated && valuesValidated && pairsValidated;
    if (!validated && outError) {
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithCapacity:7];
        userInfo[TWTValidationFailingValidatorKey] = self;
        userInfo[NSLocalizedDescriptionKey] = TWTLocalizedString(@"TWTKeyedCollectionValidator.validationError");

        if (keyedCollection) {
            userInfo[TWTValidationValidatedValueKey] = keyedCollection;
        }

        if (!countValidated && countValidationError) {
            userInfo[TWTValidationCountValidationErrorKey] = countValidationError;
        }

        if (!keysValidated && keyValidationErrors.count) {
            userInfo[TWTValidationKeyValidationErrorsKey] = [keyValidationErrors copy];
        }

        if (!valuesValidated && valueValidationErrors.count) {
            userInfo[TWTValidationValueValidationErrorsKey] = [valueValidationErrors copy];
        }

        if (!pairsValidated && pairValidationErrors.count) {
            userInfo[TWTValidationKeyValuePairValidationErrorsKey] = [pairValidationErrors copy];
        }

        *outError = [NSError errorWithDomain:TWTValidationErrorDomain code:TWTValidationErrorCodeKeyedCollectionValidatorError userInfo:[userInfo copy]];
    }
    
    return validated;
}

@end
