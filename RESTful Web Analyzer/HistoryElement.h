//
//  HistoryElement.h
//  REST Analyzer
//
//  Created by Mario Stief on 10/5/12.
//
//

#import <Foundation/Foundation.h>

@interface HistoryElement : NSObject

@property (nonatomic) NSString *url;
@property (nonatomic) HistoryElement *previous;
@property (nonatomic) HistoryElement *next;

@end
