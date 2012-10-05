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
    _parsedElementsAsDictionary = [[NSMutableDictionary alloc] init];
    return self;
}

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict {
	
    NSLog(@"processing start element: %@", elementName);
    actualElement = elementName;
 
    NSArray *keyArray = [attributeDict allKeys];
    NSArray *valueArray = [attributeDict allValues];
    for (int i = 0; i < [keyArray count]; i++) {
        NSLog(@"add attribute: \"%@: %@ = %@\"", elementName, [keyArray objectAtIndex:i], [valueArray objectAtIndex:i]);
        NSString *key = [[NSString alloc] initWithFormat:@"%@: %@", elementName, [keyArray objectAtIndex:i]];
        [_parsedElementsAsDictionary setValue:[valueArray objectAtIndex:i] forKey:key];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    /*
    if (!currentElementValue) {
        // init the ad hoc string with the value
        currentElementValue = [[NSMutableString alloc] initWithString:string];
    } else {
        // append value to the ad hoc string
        [currentElementValue appendString:string];
    }
    */
    
    // 
    if (![string hasPrefix:@"\n"]) {
        [_parsedElementsAsDictionary setValue:string forKey:actualElement];
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
