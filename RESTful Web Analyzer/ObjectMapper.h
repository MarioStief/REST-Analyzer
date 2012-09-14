//
//  ObjectMapper.h
//  RESTful Web Analyzer
//
//  Created by Mario Stief on 9/14/12.
//
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface ObjectMapper : NSObject <RKObjectMapperDelegate> {
    NSArray* array;
}

@property (nonatomic, retain) NSArray* array;

@end
