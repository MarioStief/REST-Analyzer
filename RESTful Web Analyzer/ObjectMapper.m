//
//  ObjectMapper.m
//  RESTful Web Analyzer
//
//  Created by Mario Stief on 9/14/12.
//
//

#import "ObjectMapper.h"

@implementation ObjectMapper

- (NSDictionary*)elementToPropertyMappings {
    return [NSDictionary dictionaryWithKeysAndObjects:
            @"_string1", @"string1",
            @"_string2", @"string2",
            @"_string3", @"string3",
            @"_string4", @"string4",
            @"_string5", @"string5",
            @"_string6", @"string6",
            @"_string7", @"string7",
            @"_string8", @"string8",
            @"_string9", @"string9",
            @"_string10", @"string10",
            @"_string11", @"string11",
            @"_string12", @"string12",
            nil];
}

@end