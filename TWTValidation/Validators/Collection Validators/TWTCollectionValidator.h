//
//  TWTCollectionValidator.h
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

#import <TWTValidation/TWTValidator.h>

/*!
 TWTCollectionValidators validate a collection’s count and elements. To iterate over a collection’s elements,
 collection validators used fast enumeration. As such, TWTCollectionValidator is primarily intended for
 arrays, sets, and enumerators. For keyed collections like dictionaries and map tables, use
 TWTKeyedCollectionValidator.

 Collection validators are immutable objects. As such, sending -copy or -copyWithZone: to a collection
 validator will simply return the validator itself.
 */
@interface TWTCollectionValidator : TWTValidator <NSCopying>

/*! 
 @abstract The validator for a collection’s count.
 @discussion If the instance is initialized with a nil count validator, a TWTNumberValidator with a minimum
     of 0 and a maximum of NSUIntegerMax is used.
 */
@property (nonatomic, strong, readonly) TWTValidator *countValidator;

/*! 
 @abstract The validators for a collection’s elements.
 @discussion A collection is only valid if all its elements pass validation by all the element validators.
 */
@property (nonatomic, copy, readonly) NSArray *elementValidators;

/*!
 @abstract Initializes a newly created collection validator with the specified count and element validators.
 @discussion This is the class’s designated initializer.
 @param countValidator The validator to validate a collection’s count. If nil, a TWTNumberValidator with a
     minimum of 0 and a maximum of NSUIntegerMax is used.
 @param elementValidators The validators to use for a collection’s element. If nil, the resulting validator 
     will successfully validate all of a collection’s elements.
 @result An initialized element validator with the specified count and element validators.
 */
- (instancetype)initWithCountValidator:(TWTValidator *)countValidator elementValidators:(NSArray *)elementValidators;

@end
