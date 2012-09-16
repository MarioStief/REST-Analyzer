//
//  ObjectMapper.m
//  RESTful Web Analyzer
//
//  Created by Mario Stief on 9/14/12.
//
//

#import "ObjectMapper.h"

@implementation ObjectMapper

/*- (NSDictionary*)elementToPropertyMappings {
    return [NSDictionary dictionaryWithKeysAndObjects:
            @"id", @"_id",
            @"name", @"_name",
            @"first_name", @"_first_name",
            @"last_name", @"_last_name",
            @"link", @"_link",
            @"username", @"_username",
            @"gender", @"_gender",
            @"locale", @"_locale",
            nil];
}
*/
/*- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    // wird vom RKObjectLoaderDelegate-Protokoll verlangt
}*/

- (void)setUrl:(NSString *)_url {
    url = _url;
}

- (NSInteger)splitUrl {

    /*
     // Test auf valide URL
    //url=@"blaaa";
    NSError *err;
    if (![[[NSURL alloc] initWithString:url] checkResourceIsReachableAndReturnError:&err]) // URL ist nicht valid.
        return 1;
    */
    
    if (![url hasPrefix:@"http://"] && ![url hasPrefix:@"https://"]) // URL beginnt weder mit "http://" noch "https://" -> hänge "http://" davor.
        url = ([[NSString alloc] initWithFormat:@"http://%@", url]);

    // Trennung in BaseURL und ResourceURL
    NSArray* urlComponents = url.pathComponents;
    baseUrl = [NSString stringWithFormat:@"%@//%@",[urlComponents objectAtIndex:0],[urlComponents objectAtIndex:1]];
    if ([urlComponents count] > 2) {
        resourcePath = @"";
        for (int i = 2; i < [urlComponents count]; i++)
            resourcePath = [NSString stringWithFormat:@"%@/%@",resourcePath,[urlComponents objectAtIndex:i]];
    }
    
    // ********** DEBUG!! MUSS UNBEDINGT WIEDER RAUS!! **********
    resourcePath = @"/Mario.Stief";
    // **********************************************************
    
    NSLog(@"BaseURL = \"%@\", ResourcePath =\"%@\"", baseUrl, resourcePath);
    return 0;
}

- (void)get {
    // GET auf die Resource
    [RKClient clientWithBaseURLString:baseUrl];
    [[RKClient sharedClient]get:resourcePath delegate:self];
    /*
    [RKObjectManager setSharedManager:[RKObjectManager managerWithBaseURLString:baseUrl]];  // Shared Manager wird genutzt
    RKObjectManager* manager = [[RKObjectManager alloc] init];                              // Erstelle eine Instanz...
    [manager loadObjectsAtResourcePath:resourcePath delegate:self];                         // ... und nutze diese für die Resource.
    NSLog(@"GET %@%@ (Online: %c)", baseUrl, resourcePath, [manager isOnline]);
    NSLog(@"Found entries: %@",[NSString stringWithFormat:@"%d", [[self elementToPropertyMappings] count]]);
    
    // Debug:
    NSLog(@"Dictionary-Keys: %@",[self elementToPropertyMappings].allKeys);
    NSLog(@"Dictionary-Values: %@",[self elementToPropertyMappings].allValues);
     */
//    NSDictionary* dic = [self dictionaryWithValuesForKeys:[NSArray arrayWithObjects: @"id", @"name", nil]];
//   NSLog(@"Entries in dic: %@",[NSString stringWithFormat:@"%d", [dic count]]);
//    NSLog([dic allValues]);

}

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)_response {
    if ([request isGET]) {
        // Handling GET
        if ([_response isOK]) {
            response = [[RKResponse alloc] init];
            // Success! Let's take a look at the data
            //NSLog(@"Retrieved XML: %@", [response bodyAsString]);
            if ([_response isJSON]) {
                NSLog(@"Response recognized as JSON!");
                response = _response;
                [self parseJSON];
            }
        }
        
    } else if ([request isPOST]) {
        // Handling POST /other.json
        if ([_response isJSON]) {
            NSLog(@"Got a JSON response back from our POST!");
        }
        
    } else if ([request isPUT]) {
        // Handling PUT
        
    } else if ([request isDELETE]) {
        // Handling DELETE /missing_resource.txt
        if ([_response isNotFound]) {
            NSLog(@"The resource path '%@' was not found.", [request resourcePath]);
        }
        
    } else if ([request isHEAD]) {
        // Handling HEAD
    }
}

- (void)parseJSON {
    NSLog(@"Retrieved JSON: %@", [response bodyAsString]);
    
}

@end