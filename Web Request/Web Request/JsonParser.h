//
//  JsonParser.h
//  iStadium
//
//  Created by Jinhui Li on 12/28/14.
//  Copyright (c) 2014 Half Road Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define HTTP_METHOD_POST @"POST"


@protocol JsonParserDelegate <NSObject, NSURLConnectionDelegate>

@required

- (void) onErrorOccursOrJsonInvalid: (NSError *) error;

@optional

- (void) onBeginJsonRequest;
- (void) onEndJsonRequest;

@end


@interface JsonParser : NSObject

@property (strong, nonatomic) id <JsonParserDelegate> delegate;

+ (JsonParser *) sharedInstance : (id <JsonParserDelegate>) aDelegate;

#pragma start mark - JSON Invocation via URL Data

- (id) parseJson: (NSString *) url;

- (void) parseJson: (NSString *) url OnJsonParseCompletionEventHandler: (void (^) (id returnValue)) onJsonParseCompletionEventHandler;

- (id) parseJson: (NSString *) url TimeoutInterval: (CGFloat) timeoutInterval Target: (id) target OnTimeIntervalReachesEventHandler: (void (^) (NSTimer *timer)) onTimeIntervalReachesEventHandler;

- (void) parseJson: (NSString *) url OnJsonParseCompletionEventHandler: (void (^) (id returnValue)) onJsonParseCompletionEventHandler TimeoutInterval: (CGFloat) timeoutInterval Target: (id) target OnTimeIntervalReachesEventHandler: (void (^) (NSTimer *timer)) OnTimeIntervalReachesEventHandler;

- (void) parseJson: (NSString *) url OnJsonParseCompletionEventHandler: (void (^) (id returnValue)) onJsonParseCompletionEventHandler OnErrorEventHandler: (void (^) (id <NSCopying> sender, NSError *error)) onErrorEventHandler;

- (void) parseJson: (NSString *) url OnJsonParseCompletionEventHandler: (void (^) (id returnValue)) onJsonParseCompletionEventHandler TimeoutInterval: (CGFloat) timeoutInterval Target: (id) target OnTimeIntervalReachesEventHandler: (void (^) (NSTimer *timer)) OnTimeIntervalReachesEventHandler OnErrorEventHandler: (void (^) (id <NSCopying> sender, NSError *error)) onErrorEventHandler;

- (id) parseJson: (NSString *) url OnErrorEventHandler: (void (^) (id <NSCopying> sender, NSError *error)) onErrorEventHandler;

- (id) parseJson: (NSString *) url JSONReadingOption: (NSJSONReadingOptions) JSONReadingOption;

- (id) parseJson: (NSString *) url JSONReadingOption: (NSJSONReadingOptions) JSONReadingOption OnErrorEventHandler: (void (^) (id <NSCopying> sender, NSError *error))  onErrorEventHandler;

- (id) parseJson: (NSString *) url DataReadingOptions: (NSDataReadingOptions) dataReadingOptions JSONReadingOption: (NSJSONReadingOptions) JSONReadingOption OnErrorEventHandler: (void (^) (id <NSCopying> sender, NSError *error)) onErrorEventHandler;

#pragma end mark - JSON Invocation via URL Data

@end
