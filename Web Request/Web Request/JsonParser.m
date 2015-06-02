//
//  JsonParser.m
//  iStadium
//
//  Created by Jinhui Li on 12/28/14.
//  Copyright (c) 2014 Half Road Software Inc. All rights reserved.
//

#import "JsonParser.h"

#define SAFE_PERFORM_WITH_ARG(THE_OBJECT, THE_SELECTOR, THE_ARG) (([THE_OBJECT respondsToSelector:THE_SELECTOR]) ? [THE_OBJECT performSelector:THE_SELECTOR withObject:THE_ARG] : nil)

@implementation NSTimer (WithBlock)

+ (NSTimer *) scheduledTimerWithTimeInterval: (NSTimeInterval) ti Target:(id) target Repeats: (BOOL) repeats OnTimeIntervalReachesEventHandler: (void (^)(NSTimer *)) onTimeIntervalReachesEventHandler
{
	//NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:ti target:target selector:@selector (action:) userInfo:onTimeIntervalReachesEventHandler repeats:repeats];

	__block NSTimer *timer = nil;

	if ([NSThread isMainThread])
	{
		timer = [NSTimer scheduledTimerWithTimeInterval:ti target:self selector:@selector (action:) userInfo:onTimeIntervalReachesEventHandler repeats:repeats];
	}
	else
	{
		dispatch_sync(dispatch_get_main_queue(), ^{

			if ([NSThread isMainThread])
			{
				timer = [NSTimer scheduledTimerWithTimeInterval:ti target:self selector:@selector (action:) userInfo:onTimeIntervalReachesEventHandler repeats: repeats];
			}
		});
	}

	return timer;
}

+ (void) action: (NSTimer*) timer
{
	id callback	= timer.userInfo;

	if (callback)
		((void (^)(NSTimer *)) callback) (timer);
}

+(id)scheduledTimerWithTimeInterval: (NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats
{
	void (^block)() = [inBlock copy];
	id ret = [self scheduledTimerWithTimeInterval:inTimeInterval target:self selector: @selector (executeBlock:) userInfo:block repeats:inRepeats];

	return ret;
}

+(id) timerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats
{
	void (^block)() = [inBlock copy];
	id ret = [self timerWithTimeInterval:inTimeInterval target:self selector: @selector(executeBlock:) userInfo:block repeats:inRepeats];

	return ret;
}

+(void) executeBlock: (NSTimer *) timer;
{
	if([timer userInfo])
	{
		void (^block)() = (void (^)())[timer userInfo];

		block();
	}
}

@end

@implementation JsonParser

@synthesize delegate;

static JsonParser *instance = nil;

+ (JsonParser *) sharedInstance : (id <JsonParserDelegate>) aDelegate
{
	if (!instance)
		instance = [[self alloc] init];

	instance.delegate = aDelegate;

	return instance;
}

#pragma start mark - JSON Invocation via URL Data

- (id) parseJson: (NSString *) url
{
	if ([delegate respondsToSelector:@selector (onBeginJsonRequest)])
	{
		[delegate performSelector:@selector (onBeginJsonRequest)];
	}

	url				= [url stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];

	NSURL *jsonUrl	= [NSURL URLWithString: url];
	NSError *error;
	NSData *data	= [NSData dataWithContentsOfURL: jsonUrl options:NSDataReadingMapped error:&error];

	id result = nil;

	if (error)
	{
		SAFE_PERFORM_WITH_ARG (delegate, @selector (onErrorOccursOrJsonInvalid:), error);
	}
	else
	{
		if (data)
		{
			id jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];

			if (error)
			{
				NSString *string = [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding];
				result = string;
			}
			else
			{
				if ([NSJSONSerialization isValidJSONObject:jsonResponse])
					result = jsonResponse;
			}
		}
		else
		{
			SAFE_PERFORM_WITH_ARG (delegate, @selector (onErrorOccursOrJsonInvalid:), error);
		}
	}

	if ([delegate respondsToSelector:@selector (onEndJsonRequest)])
	{
		[delegate performSelector:@selector (onEndJsonRequest)];
	}

	return result;
}

- (void) parseJson: (NSString *) url OnJsonParseCompletionEventHandler: (void (^) (id))onJsonParseCompletionEventHandler
{
	NSOperationQueue *operationQueue = [NSOperationQueue mainQueue];
	[operationQueue addOperationWithBlock:^{

		id jsonResult = [self parseJson:url];

		onJsonParseCompletionEventHandler (jsonResult);
	}];
}

- (id) parseJson: (NSString *) url TimeoutInterval: (CGFloat) timeoutInterval Target: (id) target OnTimeIntervalReachesEventHandler: (void (^)(NSTimer *timer)) onTimeIntervalReachesEventHandler
{
	[NSTimer scheduledTimerWithTimeInterval: timeoutInterval Target:target Repeats:NO OnTimeIntervalReachesEventHandler:^(NSTimer *nstimer) {

		onTimeIntervalReachesEventHandler (nstimer);
	}];

	id jsonResult = [self parseJson:url];

	return jsonResult;
}

- (void) parseJson: (NSString *) url OnJsonParseCompletionEventHandler: (void (^) (id))onJsonParseCompletionEventHandler TimeoutInterval: (CGFloat) timeoutInterval Target: (id) target OnTimeIntervalReachesEventHandler: (void (^)(NSTimer *timer)) OnTimeIntervalReachesEventHandler
{
	NSOperationQueue *operationQueue = [NSOperationQueue mainQueue];
	[operationQueue addOperationWithBlock:^{

		NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:timeoutInterval Target:target Repeats:NO OnTimeIntervalReachesEventHandler:OnTimeIntervalReachesEventHandler];

		dispatch_queue_t queue = dispatch_queue_create ("MutipleThreadsWithAsyncQueue", NULL);

		dispatch_async (queue, ^{

			id jsonResult = [self parseJson:url];

			if (jsonResult)
			{
				if (timer)
					[timer invalidate];

				onJsonParseCompletionEventHandler (jsonResult);
			}
		});
	}];
}

- (void) parseJson: (NSString *) url OnJsonParseCompletionEventHandler: (void (^)(id))onJsonParseCompletionEventHandler OnErrorEventHandler:(void (^)(id<NSCopying>, NSError *))onErrorEventHandler
{
	NSOperationQueue *operationQueue = [NSOperationQueue mainQueue];
	[operationQueue addOperationWithBlock:^{

		id jsonResult = [self parseJson:url OnErrorEventHandler: onErrorEventHandler];

		onJsonParseCompletionEventHandler (jsonResult);
	}];
}

- (void) parseJson: (NSString *) url OnJsonParseCompletionEventHandler: (void (^) (id))onJsonParseCompletionEventHandler TimeoutInterval: (CGFloat) timeoutInterval Target: (id) target OnTimeIntervalReachesEventHandler: (void (^)(NSTimer *timer)) OnTimeIntervalReachesEventHandler OnErrorEventHandler: (void (^) (id <NSCopying> sender, NSError *error)) onErrorEventHandler
{
	NSOperationQueue *operationQueue = [NSOperationQueue mainQueue];
	[operationQueue addOperationWithBlock:^{

		NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:timeoutInterval Target:target Repeats:NO OnTimeIntervalReachesEventHandler:^(NSTimer *timer) {

			[operationQueue cancelAllOperations];
			
			OnTimeIntervalReachesEventHandler (timer);
		}];

		dispatch_queue_t queue = dispatch_queue_create ("MutipleThreadsWithAsyncQueue", NULL);

		dispatch_async (queue, ^{

			id jsonResult = [self parseJson:url OnErrorEventHandler: onErrorEventHandler];

			if (jsonResult)
			{
				if (timer)
					[timer invalidate];

				onJsonParseCompletionEventHandler (jsonResult);
			}

			/*
			dispatch_sync(dispatch_get_main_queue(), ^{//其实这个也是在子线程中执行的，只是把它放到了主线程的队列中
				Boolean isMain = [NSThread isMainThread];
				if (isMain) {
					NSLog(@"GCD主线程");
			});
			 */
		});
	}];
}

- (id) parseJson: (NSString *) url OnErrorEventHandler: (void (^) (id <NSCopying> sender, NSError *error))onErrorEventHandler
{
	NSDataReadingOptions mask = 0;

	return [self parseJson:url DataReadingOptions:mask JSONReadingOption:NSJSONReadingMutableContainers OnErrorEventHandler:onErrorEventHandler];
}

- (id) parseJson: (NSString *) url JSONReadingOption: (NSJSONReadingOptions) JSONReadingOption
{
	NSDataReadingOptions mask	= 0;

	return [self parseJson:url DataReadingOptions:mask JSONReadingOption:JSONReadingOption OnErrorEventHandler:nil];
}

- (id) parseJson: (NSString *) url JSONReadingOption: (NSJSONReadingOptions) JSONReadingOption OnErrorEventHandler: (void (^) (id <NSCopying> sender, NSError *error)) onErrorEventHandler
{
	NSDataReadingOptions mask	= 0;

	return [self parseJson:url DataReadingOptions:mask JSONReadingOption:JSONReadingOption OnErrorEventHandler:onErrorEventHandler];
}

- (id) parseJson: (NSString *) url DataReadingOptions: (NSDataReadingOptions) dataReadingOptions JSONReadingOption: (NSJSONReadingOptions) JSONReadingOption OnErrorEventHandler: (void (^) (id <NSCopying> sender, NSError *error)) onErrorEventHandler
{
	if ([delegate respondsToSelector:@selector (onBeginJsonRequest)])
	{
		[delegate performSelector:@selector (onBeginJsonRequest)];
	}

	NSError *error	= nil;
	NSURL *jsonUrl	= [NSURL URLWithString:url];
	NSData *data	= [NSData dataWithContentsOfURL:jsonUrl options:dataReadingOptions error:&error];

	__block NSError *error_block = error;

	id result = nil;

	if (!data)
		onErrorEventHandler (url, error_block);
	else
	{
		id response	= [NSJSONSerialization JSONObjectWithData:data options:JSONReadingOption error:&error];

		if (error)
		{
			if (onErrorEventHandler)
				onErrorEventHandler (url, error_block);
		}

		result = response;
	}

	if ([delegate respondsToSelector:@selector (onEndJsonRequest)])
	{
		[delegate performSelector:@selector (onEndJsonRequest)];
	}

	return result;
}

#pragma end mark - JSON Invocation via URL Data

@end
