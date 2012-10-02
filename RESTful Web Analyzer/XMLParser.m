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
    // init array of user objects
    _parsedElementsAsArray = [[NSMutableArray alloc] init];
    return self;
}

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict {
	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (!currentElementValue) {
        // init the ad hoc string with the value
        currentElementValue = [[NSMutableString alloc] initWithString:string];
    } else {
        // append value to the ad hoc string
        [currentElementValue appendString:string];
    }
    NSLog(@"Processing value for : %@", string);
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {
    

    // The parser hit one of the element values.
    // This syntax is possible because User object
    // property names match the XML user element names
    [_parsedElementsAsArray setValue:currentElementValue forKey:elementName];
    NSLog(@"key: %@ value: %@", elementName, currentElementValue);
    
    currentElementValue = nil;
}

@end
