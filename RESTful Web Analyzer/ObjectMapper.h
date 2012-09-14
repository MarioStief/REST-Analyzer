//
//  ObjectMapper.h
//  RESTful Web Analyzer
//
//  Created by Mario Stief on 9/14/12.
//
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface ObjectMapper : NSObject <RKObjectMapperDelegate, RKObjectLoaderDelegate> {
    RKObjectManager* manager;
    NSString* url;
    NSString* baseUrl;
    NSString* resourcePath;
    NSString* string1;
    NSString* string2;
    NSString* string3;
    NSString* string4;
    NSString* string5;
    NSString* string6;
    NSString* string7;
    NSString* string8;
    NSString* string9;
    NSString* string10;
    NSString* string11;
    NSString* string12;
}

@property (nonatomic, retain) NSArray* array;

- (NSDictionary*)elementToPropertyMappings;
- (void)setUrl:(NSString*)url;
- (void)splitUrl;
- (void)mapUrl;

@end
