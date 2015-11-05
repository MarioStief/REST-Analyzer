//
//  HistoryElement.m
//  REST Analyzer
//
//  Created by Mario Stief on 10/5/12.
//
//

#import "HistoryElement.h"

@implementation HistoryElement

// ******************** Begin URL Processing ********************

- (NSString*)getPart:(NSString*)part {
    
    // string empty -> stays empty
    if ([_url isEqualToString:@""])
        return @"";
    
    // string empty -> stays empty
    if ([_url isEqualToString:@"http://"])
        return @"http://";
    
    // string empty -> stays empty
    if ([_url isEqualToString:@"https://"])
        return @"https://";
    
    // URL beginnt weder mit "http://" noch "https://" -> hänge "http://" davor.
    if (![_url hasPrefix:@"http://"] && ![_url hasPrefix:@"https://"])
        _url = ([[NSString alloc] initWithFormat:@"http://%@", _url]);
    
    // URL endet mit "/" -> weg damit.
    if ([_url hasSuffix:@"/"]) {
        if ([part isEqualToString:@"highestDir"])
            // url already is a dir. job done.
            return _url;
        _url = [_url substringToIndex:[_url length]-1];
    }
    
    // Splitting URL in BaseURL and Resource
    NSArray *urlComponents = [[NSArray alloc] initWithArray:[_url pathComponents]];
    NSString *baseUrl = [NSString stringWithFormat:@"%@//%@",[urlComponents objectAtIndex:0],[urlComponents objectAtIndex:1]];
    
    if ([part isEqualToString:@"baseUrl"]) {
        // only base url is requested; job done.
        return [[NSString alloc] initWithFormat:@"%@/",baseUrl];
    }
    
    if ([urlComponents count] > 2) {
        //
        NSMutableString *resourcePath = [[NSMutableString alloc] init];
        int i = 2; // while instead of for: i will be needed outside this loop.
        while (i < [urlComponents count]-1) {
            [resourcePath appendFormat:@"/%@",[urlComponents objectAtIndex:i]];
            i++;
        }
        if ([part isEqualToString:@"prevPath"] || [part isEqualToString:@"highestDir"]) {
            // previous Path requested. This is it.
            // Also the highest dir if it was NOT the full url.
            if ([resourcePath isEqualToString:[[NSString alloc] init]])
                // resource ath is empty, prevPath is base url. return with / at the end
                return [[NSString alloc] initWithFormat:@"%@/",baseUrl];
            else
                // longer then base url
                return [[NSString alloc] initWithFormat:@"%@%@/",baseUrl,resourcePath];
        }
        // else: full Path requested. Add last url component.
        [resourcePath appendFormat:@"/%@",[urlComponents objectAtIndex:i]];
    }
    return [[NSString alloc] initWithFormat:@"%@",_url];
}



// ******************** End URL Processing ********************

@end
