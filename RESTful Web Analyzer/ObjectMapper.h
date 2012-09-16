//
//  ObjectMapper.h
//  RESTful Web Analyzer
//
//  Created by Mario Stief on 9/14/12.
//
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import <RestKit/JSONKit.h>

@interface ObjectMapper : NSObject <RKRequestDelegate> {
//<RKObjectMapperDelegate, RKObjectLoaderDelegate> {
    NSString* url;
    NSString* baseUrl;
    NSString* resourcePath;
    RKResponse* response;
}

/*
@property (nonatomic, retain) NSNumber* id;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* first_name;
@property (nonatomic, retain) NSString* last_name;
@property (nonatomic, retain) NSURL* link;
@property (nonatomic, retain) NSString* username;
@property (nonatomic, retain) NSString* gender;
@property (nonatomic, retain) NSString* locale;
 */

//- (NSDictionary*)elementToPropertyMappings;
- (void)setUrl:(NSString*)url;
- (NSInteger)splitUrl;
- (void)get;
- (void)post;
- (void)put;
- (void)delete;
- (void)head;
- (void)parseJSON:(RKResponse*)response;

@end
