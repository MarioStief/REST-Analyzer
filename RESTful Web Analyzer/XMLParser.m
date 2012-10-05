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
    return self;
}

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict {
	
    NSLog(@"processing start element: %@", elementName);
    actualElement = elementName;
 
//    [_keyArray addObjectsFromArray:[attributeDict allKeys]];
    [_valueArray addObjectsFromArray:[attributeDict allValues]];
    NSArray *keys = [attributeDict allKeys];
//    NSArray *values = [attributeDict allValues];
    for (int i = 0; i < [keys count]; i++) {
        NSLog(@"add attribute: \"%@: %@ = %@\"", elementName, [keys objectAtIndex:i], [_valueArray objectAtIndex:i]);
        NSString *key = [[NSString alloc] initWithFormat:@"%@ -> %@", elementName, [keys objectAtIndex:i]];
        [_keyArray addObject:key];
        [_valueArray addObject:[_valueArray objectAtIndex:i]];
    }

}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {

    if (![string hasPrefix:@"\n"]) {
        [_keyArray addObject:actualElement];
        [_valueArray addObject:string];
//        [_parsedElementsAsDictionary setValue:string forKey:actualElement];
        NSLog(@"add value: \"%@ = %@\"", actualElement, string);
    }
}

/*
- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {
    
    NSLog(@"didEndElement: %@ %@ %@", elementName, namespaceURI, qName);

    // The parser hit one of the element values.
    // This syntax is possible because User object
    // property names match the XML user element names

    [_parsedElementsAsDictionary setValue:currentElementValue forKey:elementName];

    NSLog(@"key: %@ value: %@", elementName, currentElementValue);
    
    currentElementValue = nil;

    NSLog(@"%@",_parsedElementsAsDictionary);
}
 */

@end
