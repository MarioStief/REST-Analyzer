//
//  XMLParser.h
//  REST Analyzer
//
//  Created by Mario Stief on 10/2/12.
//
//

#import <Foundation/Foundation.h>

// @class User;

@interface XMLParser : NSObject <NSXMLParserDelegate> {
    NSString *actualElement;
}

@property (nonatomic, retain) NSMutableArray *keyArray;
@property (nonatomic, retain) NSMutableArray *valueArray;
@property (nonatomic) BOOL verbose;

- (XMLParser *) initXMLParser;
- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;

@end