//
//  TWTJSONSchemaObjectASTNode.m
//  TWTValidation
//
//  Created by Jill Cohen on 12/15/14.
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

#import <TWTValidation/TWTJSONSchemaObjectASTNode.h>

#import <TWTValidation/TWTJSONSchemaBooleanValueASTNode.h>
#import <TWTValidation/TWTJSONSchemaKeyValuePairASTNode.h>


@implementation TWTJSONSchemaObjectASTNode

- (instancetype)init
{
    self = [super init];

    if (self) {
        _additionalPropertiesNode = [[TWTJSONSchemaBooleanValueASTNode alloc] initWithValue:YES];
    }

    return self;
}


- (void)acceptProcessor:(id<TWTJSONSchemaASTProcessor>)processor
{
    [processor processObjectNode:self];
}


- (NSSet *)validTypes
{
    return [NSSet setWithObject:TWTJSONSchemaTypeKeywordObject];
}


- (NSMutableArray *)childrenReferenceNodes
{
    NSMutableArray *nodes = [super childrenReferenceNodes];
    [nodes addObjectsFromArray:[self childrenReferenceNodesFromNodeArray:self.propertySchemas]];
    [nodes addObjectsFromArray:[self childrenReferenceNodesFromNodeArray:self.patternPropertySchemas]];
    [nodes addObjectsFromArray:self.additionalPropertiesNode.childrenReferenceNodes];
    [nodes addObjectsFromArray:[self childrenReferenceNodesFromNodeArray:self.propertyDependencies]];

    return nodes;
}


- (TWTJSONSchemaASTNode *)typeSpecificChecksForKey:(NSString *)key referencePath:(NSMutableArray *)path
{
    if ([key isEqualToString:TWTJSONSchemaKeywordProperties]) {
        return [self nodeForPathComponents:path fromKeyValuePairNodeArray:self.propertySchemas];
    }
    if ([key isEqualToString:TWTJSONSchemaKeywordPatternProperties]) {
        return [self nodeForPathComponents:path fromKeyValuePairNodeArray:self.patternPropertySchemas];
    }
    if ([key isEqualToString:TWTJSONSchemaKeywordAdditionalProperties]) {
        return [self.additionalPropertiesNode nodeForPathComponents:path];
    }
    if ([key isEqualToString:TWTJSONSchemaKeywordDependencies]) {
        return [self nodeForPathComponents:path fromKeyValuePairNodeArray:self.propertyDependencies];
    }

    return nil;
}


- (TWTJSONSchemaASTNode *)nodeForPathComponents:(NSMutableArray *)path fromKeyValuePairNodeArray:(NSArray *)array
{
    NSString *key = path.firstObject;

    for (TWTJSONSchemaKeyValuePairASTNode *subnode in array) {
        if ([subnode.key isEqualToString:key]) {
            return [subnode nodeForPathComponents:path];
        }
    }

    return nil;
}

@end
