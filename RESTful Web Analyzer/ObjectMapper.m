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

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
// wird vom RKObjectLoaderDelegate-Protokoll verlangt
    
}

- (void)setUrl:(NSString *)_url {
    url = _url;
}

- (void)splitUrl {
    // Trennung in BaseURL und ResourceURL
    NSArray* urlComponents = url.pathComponents;
    baseUrl = [NSString stringWithFormat:@"%@//%@",[urlComponents objectAtIndex:0],[urlComponents objectAtIndex:1]];
    if ([urlComponents count] > 2) {
        resourcePath = @"";
        for (int i = 2; i < [urlComponents count]; i++)
            resourcePath = [NSString stringWithFormat:@"%@/%@",resourcePath,[urlComponents objectAtIndex:i]];
    }
    resourcePath = @"/Mario.Stief";
    NSLog(@"BaseURL: %@ + ResourcePath: %@",baseUrl, resourcePath);
}

- (void)mapUrl {
    [RKObjectManager setSharedManager:[RKObjectManager managerWithBaseURL:[[NSURL alloc] initWithString:baseUrl]]];
    //manager = [RKObjectManager objectManagerWithBaseURLString:baseUrl];
    [manager loadObjectsAtResourcePath:resourcePath delegate:self];
    //NSDictionary* dic = [mapper dictionaryWithValuesForKeys:[NSArray arrayWithObjects: @"id", @"name", nil]];
    NSLog(@"Einträge in dic: %@",[NSString stringWithFormat:@"%d", [[self elementToPropertyMappings] count]]);
}

@end