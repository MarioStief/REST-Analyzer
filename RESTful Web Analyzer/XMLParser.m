//
//  XMLParser.m
//  REST Analyzer
//
//  Created by Mario Stief on 10/2/12.
//
//

#import "XMLParser.h"

@implementation XMLParser

- (XMLParser *) initXMLParser {
    self = [super init];
    // init array of elements
    _keyArray = [[NSMutableArray alloc] init];
    _valueArray = [[NSMutableArray alloc] init];
    _verbose = NO;
    return self;
}

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict {

    actualElement = elementName;
 
    NSArray *keys = [attributeDict allKeys];
    NSArray *values = [attributeDict allValues];
    for (int i = 0; i < [keys count]; i++) {
        NSString *key = [[NSString alloc] initWithFormat:@"%@ (%@)", elementName, [keys objectAtIndex:i]];
        [_keyArray addObject:key];
        [_valueArray addObject:[values objectAtIndex:i]];
    }

}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {

    if (![string hasPrefix:@"\n"]) {
        [_keyArray addObject:actualElement];
        [_valueArray addObject:string];
    }
}

@end
