//
//  TWTJSONSchemaDependencyASTNode.m
//  TWTValidation
//
//  Created by Jill Cohen on 12/16/14.
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

#import <TWTValidation/TWTJSONSchemaDependencyASTNode.h>


@implementation TWTJSONSchemaDependencyASTNode

- (instancetype)initWithKey:(NSString *)key propertySet:(NSSet *)propertySet
{
    NSParameterAssert(key);
    NSParameterAssert(propertySet);

    self = [super init];
    if (self) {
        _key = [key copy];
        _propertySet = [propertySet copy];
    }
    return self;
}


- (instancetype)initWithKey:(NSString *)key valueSchema:(TWTJSONSchemaASTNode *)value
{
    NSParameterAssert(key);
    NSParameterAssert(value);

    self = [super init];
    if (self) {
        _key = [key copy];
        _valueSchema = value;
    }
    return self;
}


- (instancetype)init
{
    return [self initWithKey:nil valueSchema:nil];
}


- (void)acceptProcessor:(id<TWTJSONSchemaASTProcessor>)processor
{
    [processor processDependencyNode:self];
}


- (NSSet *)validTypes
{
    return nil;
}


- (NSMutableArray *)childrenReferenceNodes
{
    if (self.valueSchema) {
        return self.valueSchema.childrenReferenceNodes;
    }

    return [@[ ] mutableCopy];
}


- (TWTJSONSchemaASTNode *)typeSpecificChecksForKey:(NSString *)key referencePath:(NSMutableArray *)path
{
    return (self.valueSchema && [key isEqualToString:self.key]) ? [self.valueSchema nodeForPathComponents:path] : nil;
}

@end
