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
    // an ad hoc string to hold element value
//    NSMutableString *currentElementValue;
    NSString *actualElement;
//    NSMutableArray *parsedElementsAsArray;
    // user object
    // array of user objects
//    NSMutableArray *parsedElementsAsArray;
}

//@property (nonatomic, retain) User *user;
//@property (nonatomic, retain) NSMutableArray *parsedElementsAsArray;
@property (nonatomic, retain) NSMutableArray *keyArray;
@property (nonatomic, retain) NSMutableArray *valueArray;

- (XMLParser *) initXMLParser;

@end