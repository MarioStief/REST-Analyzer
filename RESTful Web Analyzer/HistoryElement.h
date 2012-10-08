//
//  HistoryElement.h
//  REST Analyzer
//
//  Created by Mario Stief on 10/5/12.
//
//

#import <Foundation/Foundation.h>

@interface HistoryElement : NSObject

@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) HistoryElement *previous;
@property (strong, nonatomic) HistoryElement *next;

@end
