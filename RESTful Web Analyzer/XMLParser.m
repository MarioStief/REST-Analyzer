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
    if (_verbose) NSLog(@"processing %@...", elementName);
    actualElement = elementName;
 
    NSArray *keys = [attributeDict allKeys];
    NSArray *values = [attributeDict allValues];
    for (int i = 0; i < [keys count]; i++) {
        //if (_verbose) NSLog(@"add attribute: \"%@: %@ = %@\"", elementName, [keys objectAtIndex:i], [values objectAtIndex:i]);
        
        // Alt: Anzeige mit Attribut
        // alt:
        // NSString *key = [[NSString alloc] initWithFormat:@"%@ (%@)", elementName, [keys objectAtIndex:i]];
        // neu:
        NSString *key = [[NSString alloc] initWithFormat:@"%@", elementName];
        [_keyArray addObject:key];

        
        // Neu: ID
        
        /*
        NSArray *urlComponents = [[NSArray alloc] initWithArray:[[values objectAtIndex:i] pathComponents]];
        NSInteger lastElement;
        if ([[values objectAtIndex:i] hasSuffix:@"/"])
            lastElement = [urlComponents count]-2;
        else
             lastElement = [urlComponents count]-1;
        NSString *lastPathEntry = [[NSString alloc] initWithString:[urlComponents objectAtIndex:lastElement]];
        //NSLog(@"%@",lastPathEntry);
        [_keyArray addObject:[[NSString alloc] initWithFormat:@"%@ /%@", elementName, lastPathEntry]];
        
         */
        // End Neu Key
        
        [_valueArray addObject:[values objectAtIndex:i]];
    }

}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {

    if (![string hasPrefix:@"\n"]) {
        [_keyArray addObject:actualElement];
        [_valueArray addObject:string];
//        [_parsedElementsAsDictionary setValue:string forKey:actualElement];
        //if (_verbose) NSLog(@"add value: \"%@ = %@\"", actualElement, string);
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
