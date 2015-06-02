//
//  WebHelper.m
//  iStadium
//
//  Created by Jinhui Li on 12/28/14.
//  Copyright (c) 2014 Half Road Software Inc. All rights reserved.
//

#import <objc/runtime.h>

#import "WebHelper.h"

@import MobileCoreServices;

/***** Application Settings ******/

#define SETTINGS										@"Setting"
#define THROTTLE										@"Throttle"

#define CONTENT_LENGTH									@"Content-Length"
#define CONTENT_TYPE									@"Content-Type"
#define APPLICATION_X_WWW_FORM_URLENCODED				@"application/x-www-form-urlencoded"
#define TEXT_XML										@"text/xml; charset=utf-8"
#define SOAP_ACTION_FIELD								@"SoapAction"
#define SOAP_METHOD_TEMPLATE							@"$SOAP_METHOD_TEMPLATE"
#define SOAP_ACTION_VALUE								@"http://tempuri.org/%@/%@"
#define SOAP_MESSAGE_TEMPLATE							@"$SOAP_MESSAGE_TEMPLATE"
#define COOKIE											@"Cookie"

#define ACCEPT											@"Accept"
#define APPLICATION_JSON								@"application/json"
#define ENCTYPE											@"enctype"
#define MULTIPART_FORM_DATA								@"multipart/form-data; boundary=%@"
#define CONTENT_DISPOSITION								@"Content-Disposition"
#define FORM_DATA_NAME_FILE_NAME						@"form-data; name=\"%@\"; filename=\"%@\""
#define FORM_DATA_NAME									@"form-data; name=\"%@\""
#define _RETURN_NEW_LINE								@"\r\n"
#define DELIMITER										@"--"
#define CONNECTOR										@"&"
#define CONNECTION										@"Connection"
#define KEEP_LIVE										@"Keep-live"
#define KEEP_ALIVE										@"Keep-Alive"
#define BOUNDARY										@"Boundary"

#define USER_AGENT										@"User-Agent"
#define USER_AGENT_VALUE_MAC							@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_2) AppleWebKit/600.3.18 (KHTML, like Gecko) Version/8.0.3 Safari/600.3.18"

#define	HTTP_METHOD_POST								@"POST"
#define HTTP_METHOD_GET									@"GET"
#define QUESTION_SYNTAX									@"?";
#define PARAMETER_CONNECTOR								@"%@=%@&"

#define DEFAULT_TIMEOUT_THROTTLE						60.0f
#define DEFAULT_KEEP_ALIVE								@"300"
#define DEFAULT_BOUNDARY_LENGTH							20

#define URL_ESCAPE_CHARACTER_SET						"!*'();:@&=+$,/?%#[]"
#define XML_VERSION_1_0_ENCODING_UTF_8					@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
#define SERVICE_SOAP_MESSAGE_TEMPLATE					@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" \
"<SOAP-ENV:Envelope \n" \
	"xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" \n" \
	"xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" \n" \
	"xmlns:SOAP-ENC=\"http://schemas.xmlsoap.org/soap/encoding/\" \n" \
	"SOAP-ENV:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\" \n" \
	"xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\"> \n" \
	"<SOAP-ENV:Body> \n" \
		"<$SOAP_METHOD_TEMPLATE xmlns=\"http://tempuri.org/\"> \n" \
			"$SOAP_MESSAGE_TEMPLATE \n" \
		"</$SOAP_METHOD_TEMPLATE> \n" \
	"</SOAP-ENV:Body> \n" \
"</SOAP-ENV:Envelope>"


// Return Value
#define RETURN_VALUE									@"ReturnValue"
#define RETURN_STATUS_CODE								@"StatusCode"
#define RETURN_ERROR_CODE								@"ErrorCode"
#define RETURN_DESCRIPTION								@"Description"
#define RETURN_CONTENT									@"Content"

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
	_Pragma("clang diagnostic push") \
	_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
	Stuff; \
	_Pragma("clang diagnostic pop") \
} while (0)

@interface WebHelper ()

@property (assign, nonatomic) NSString *certificate;
@property (assign, nonatomic) NSString *certificateCredential;

@property (assign, nonatomic) NSString *userName;
@property (assign, nonatomic) NSString *password;

@property (assign, nonatomic) NSStringEncoding stringEncoding;
@property (copy, nonatomic) void (^ onResponseReceived) (NSURLConnection *connection, NSURLResponse *response);
@property (copy, nonatomic) void (^ onDataReceived) (NSURLConnection *connection, NSData *data);
@property (copy, nonatomic) void (^ onFailWithError) (NSURLConnection *connection, NSError *error);

@end


@implementation WebHelper

static WebHelper* instance;

- (id) init
{		   
	if((self = [super init]))
		return self;

	return nil;
}

+ (WebHelper *) sharedInstance
{
	if (!instance)
		instance = [[WebHelper alloc] init];

	return instance;
}

+ (WebHelper *) sharedInstance : (id <WebHelperDelegate>) delegate
{
	if (!instance)
		instance = [[self alloc] init];

	instance.delegate = delegate;

	return instance;
}

+ (WebHelper *) sharedInstance : (id <WebHelperDelegate>) delegate UserName: (NSString *) userName Password: (NSString *) password
{
	if (!instance)
		instance = [[self alloc] init];

	instance.delegate = delegate;
	instance.userName = userName;
	instance.password = password;

	return instance;
}

/*!
 Http Request to the web server.

 @param		url						URL address to send
 @param		HttpResponseContent		The content of Http response.

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */
- (NSDictionary *) httpRequest:(NSString *) url HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent
{
	return [self httpRequest: url HttpMethod: HTTP_METHOD_GET HttpRequestBody: nil HttpResponseContent:httpResponseContent];
}

/*!
 Http Request to the web server.

 @param		url						URL address to send
 @param		HttpMethod				Http Method
 @param		HttpRequestBody			The body of Http Request
 @param		HttpResponseContent		The content of Http response.

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */
- (NSDictionary *) httpRequest:(NSString *) url HttpRequestBody: (id) httpRequestBody HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent
{
	return [self httpRequest: url HttpMethod: HTTP_METHOD_POST HTTPHeaderFields: nil EnableCookieStorage: YES HttpRequestBody: httpRequestBody HttpResponseContent: httpResponseContent];
}

/*!
 Http Request to the web server.

 @param		url								URL address to send
 @param		EnableCookieStorage				Whether to Enable the Cookie Storage support
 @param		HttpRequestBody					The body of Http Request
 @param		StringEncoding					String Encoding
 @param		HttpResponseContent				The content of Http response

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */
- (NSDictionary *) httpRequest: (NSString *) url HttpRequestBody: (id) httpRequestBody StringEncoding: (NSStringEncoding) stringEncoding HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent
{
	return [self httpRequest: url HttpMethod: HTTP_METHOD_POST HTTPHeaderFields: nil HttpRequestBody: httpRequestBody StringEncoding: stringEncoding HttpResponseContent: httpResponseContent];
}

/*!
 Http Request to the web server.

 @param		url						URL address to send
 @param		HttpMethod				Http Method
 @param		HttpRequestBody			The body of Http Request
 @param		HttpResponseContent		The content of Http response.

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */
- (NSDictionary *) httpRequest:(NSString *) url HttpMethod: (NSString *) httpMethod HttpRequestBody: (id) httpRequestBody HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent
{
	return [self httpRequest: url HttpMethod: httpMethod HTTPHeaderFields: nil EnableCookieStorage: YES HttpRequestBody: httpRequestBody HttpResponseContent: httpResponseContent];
}

/*!
 Http Request to the web server.

 @param		url								URL address to send
 @param		HttpMethod						Http Method
 @param		EnableCookieStorage				Whether to Enable the Cookie Storage support
 @param		HttpRequestBody					The body of Http Request
 @param		StringEncoding					String Encoding
 @param		HttpResponseContent				The content of Http response

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */
- (NSDictionary *) httpRequest: (NSString *) url HttpMethod: (NSString *) httpMethod HttpRequestBody: (id) httpRequestBody StringEncoding: (NSStringEncoding) stringEncoding HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent
{
	return [self httpRequest: url HttpMethod: httpMethod HTTPHeaderFields: nil HttpRequestBody: httpRequestBody StringEncoding: stringEncoding HttpResponseContent: httpResponseContent];
}

/*!
 Http Request to the web server.

 @param		url								URL address to send
 @param		HTTPHeaderFields				HTTP Request Header Fields
 @param		HttpRequestBody					The body of Http Request
 @param		HttpResponseContent				The content of Http response

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */
- (NSDictionary *) httpRequest: (NSString *) url HTTPHeaderFields: (NSDictionary *) httpHeaderFields HttpRequestBody: (id) httpRequestBody HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent
{
	return [self httpRequest: url HttpMethod: HTTP_METHOD_POST HTTPHeaderFields: httpHeaderFields HttpRequestBody: httpRequestBody StringEncoding: NSUTF8StringEncoding HttpResponseContent: httpResponseContent];
}

/*!
 Http Request to the web server.

 @param		url								URL address to send
 @param		HTTPHeaderFields				HTTP Request Header Fields
 @param		HttpRequestBody					The body of Http Request
 @param		StringEncoding					String Encoding
 @param		HttpResponseContent				The content of Http response

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */
- (NSDictionary *) httpRequest: (NSString *) url HTTPHeaderFields: (NSDictionary *) httpHeaderFields HttpRequestBody: (id) httpRequestBody StringEncoding: (NSStringEncoding) stringEncoding HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent
{
	return [self httpRequest: url HttpMethod: HTTP_METHOD_POST HTTPHeaderFields: httpHeaderFields HttpRequestBody: httpRequestBody StringEncoding: stringEncoding HttpResponseContent: httpResponseContent];
}

/*!
 Http Request to the web server.

 @param		url								URL address to send
 @param		HttpMethod						Http Method
 @param		HTTPHeaderFields				HTTP Request Header Fields
 @param		EnableCookieStorage				Whether to Enable the Cookie Storage support
 @param		HttpRequestBody					The body of Http Request
 @param		HttpResponseContent				The content of Http response

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */
- (NSDictionary *) httpRequest: (NSString *) url HttpMethod: (NSString *) httpMethod HTTPHeaderFields: (NSDictionary *) httpHeaderFields EnableCookieStorage: (BOOL) enableCookieStorage HttpRequestBody: (id) httpRequestBody HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent
{
	NSHTTPURLResponse *httpURLResponse = [[NSHTTPURLResponse alloc] init];

	return [self httpRequest: url HttpMethod: httpMethod HTTPHeaderFields: httpHeaderFields EnableCookieStorage: enableCookieStorage HttpRequestBody: httpRequestBody TimeoutInterval: DEFAULT_TIMEOUT_THROTTLE RequestCachePolicy:NSURLRequestReloadIgnoringCacheData UseAsynchronous: NO HTTPRequestDelegate: nil StringEncoding: NSUTF8StringEncoding HTTPRequestCompletionHandler: nil HttpResponse: &httpURLResponse HttpResponseContent: httpResponseContent];
}

/*!
 Http Request to the web server.

 @param		url								URL address to send
 @param		HttpMethod						Http Method
 @param		HTTPHeaderFields				HTTP Request Header Fields
 @param		EnableCookieStorage				Whether to Enable the Cookie Storage support
 @param		HttpRequestBody					The body of Http Request
@param		StringEncoding					String Encoding
 @param		HttpResponseContent				The content of Http response

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */
- (NSDictionary *) httpRequest: (NSString *) url HttpMethod: (NSString *) httpMethod HTTPHeaderFields: (NSDictionary *) httpHeaderFields HttpRequestBody: (id) httpRequestBody StringEncoding: (NSStringEncoding) stringEncoding HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent
{
	NSHTTPURLResponse *httpURLResponse = [[NSHTTPURLResponse alloc] init];

	return [self httpRequest: url HttpMethod: httpMethod HTTPHeaderFields: httpHeaderFields EnableCookieStorage: YES HttpRequestBody: httpRequestBody TimeoutInterval: DEFAULT_TIMEOUT_THROTTLE RequestCachePolicy:NSURLRequestReloadIgnoringCacheData UseAsynchronous: NO HTTPRequestDelegate: nil StringEncoding: stringEncoding HTTPRequestCompletionHandler: nil HttpResponse: &httpURLResponse HttpResponseContent: httpResponseContent];
}

/*!
 Http Request to the web server.

 @param		url								URL address to send
 @param		HttpMethod						Http Method
 @param		HTTPHeaderFields				HTTP Request Header Fields
 @param		EnableCookieStorage				Whether to Enable the Cookie Storage support
 @param		HttpRequestBody					The body of Http Request
 @param		TimeoutInterval					Timeout Interval
 @param		RequestCachePolicy				Request Cache Policy
 @param		UseAsynchronous					Whether to use asynchronous request
 @param		HTTPRequestDelegate				The delegate of HTTP Request
 @param		StringEncoding					String Encoding
 @param		HTTPRequestCompletionHandler	HTTP request completion event handler
 @param		HttpResponse					Http Response
 @param		HttpResponseContent				The content of Http response

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */
- (NSDictionary *) httpRequest: (NSString *) url HttpMethod: (NSString *) httpMethod HTTPHeaderFields: (NSDictionary *) httpHeaderFields EnableCookieStorage: (BOOL) enableCookieStorage HttpRequestBody: (id) httpRequestBody TimeoutInterval: (NSTimeInterval) timeoutInterval RequestCachePolicy: (NSURLRequestCachePolicy) requestCachePolicy UseAsynchronous: (BOOL) useAsynchronous HTTPRequestDelegate: (id) httpRequestDelegate StringEncoding: (NSStringEncoding) stringEncoding HTTPRequestCompletionHandler: (void (^) (NSURLResponse *, NSData *, NSError *)) onHTTPRequestCompletionHandler HttpResponse: (NSHTTPURLResponse *__autoreleasing *) httpResponse HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent
{
	if ([self.delegate respondsToSelector: @selector (onBeginWebHelperRequest)])
	{
		[self.delegate onBeginWebHelperRequest];
	}

	url = [url stringByAddingPercentEscapesUsingEncoding: stringEncoding];
	//url = [url stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLQueryAllowedCharacterSet]];

	NSURL *nsurl					= [NSURL URLWithString: url];
	NSMutableURLRequest *request	= [[NSMutableURLRequest alloc] initWithURL: nsurl cachePolicy: requestCachePolicy timeoutInterval: timeoutInterval];

	request.HTTPShouldHandleCookies = enableCookieStorage;
	request.HTTPMethod				= httpMethod;

	//http://en.wikipedia.org/wiki/List_of_HTTP_header_fields
	[request setValue: KEEP_ALIVE forHTTPHeaderField: CONNECTION];
	[request setValue: DEFAULT_KEEP_ALIVE forHTTPHeaderField: KEEP_ALIVE];

	if (!httpHeaderFields.count)
		[request setValue: APPLICATION_X_WWW_FORM_URLENCODED forHTTPHeaderField: CONTENT_TYPE];

	[request setValue: USER_AGENT_VALUE_MAC forHTTPHeaderField: USER_AGENT];

	[httpHeaderFields enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {

		[request addValue: key forHTTPHeaderField: key];
	}];

	if (httpRequestBody)
	{
		if ([httpRequestBody isKindOfClass: [NSString class]])
		{
			NSData *body				= [httpRequestBody dataUsingEncoding: stringEncoding allowLossyConversion: YES];
			NSString *length			= [NSString stringWithFormat: @"%tu", body.length];
			[request addValue: length forHTTPHeaderField: CONTENT_LENGTH];
			request.HTTPBody			= body;
		}
		else if ([httpRequestBody isKindOfClass: [NSDictionary class]])
		{
			NSMutableArray * pairs		= [NSMutableArray array];

			[httpRequestBody enumerateKeysAndObjectsUsingBlock: ^(NSString *key, NSString *value, BOOL *stop) {

				NSString *pair			=[NSString stringWithFormat: @"%@=%@", key, value];
				[pairs addObject: pair];
			}];

			NSString * body				= [pairs componentsJoinedByString: CONNECTOR];
			NSData * data				= [body dataUsingEncoding: stringEncoding];
			NSString *length			= [NSString stringWithFormat: @"%tu", data.length];
			[request addValue: length forHTTPHeaderField: CONTENT_LENGTH];
			request.HTTPBody			= data;
		}
		else
		{
			NSString *length			= [NSString stringWithFormat: @"%tu", [httpRequestBody length]];
			[request addValue: length forHTTPHeaderField: CONTENT_LENGTH];
			request.HTTPBody			= httpRequestBody;
		}
	}

	NSError *error;

	NSDictionary *returnValue			= [NSDictionary dictionary];

	if (useAsynchronous)
	{
		/*
		 while(!finished) {

		 [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDatedistantFuture]];

		 }
		 */

		if (httpRequestDelegate)
			[NSURLConnection connectionWithRequest:request delegate: httpRequestDelegate];
		else
		{
			//
			[NSURLConnection sendAsynchronousRequest: request queue:[NSOperationQueue mainQueue] completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error)
			 {
				 //
				 NSInteger statusCode	= [(NSHTTPURLResponse *) response statusCode];

				 if (!error && statusCode == 200)
				 {
					 SEL selector = NSSelectorFromString (@"onRequestCompleted");

					 if ([httpRequestDelegate respondsToSelector: @selector (selector)])
					 {
						 SuppressPerformSelectorLeakWarning ([httpRequestDelegate performSelector: selector]);
					 }

					 if (onHTTPRequestCompletionHandler)
						 onHTTPRequestCompletionHandler (response, data, error);
				 }
				 else
				 {
					 SEL selector = NSSelectorFromString (@"onWebHelperRequestError:");
					 SuppressPerformSelectorLeakWarning ([httpRequestDelegate performSelector: selector withObject: error]);
				 }
			 }];
		}
	}
	else
	{
		NSData *responseData	= [NSURLConnection sendSynchronousRequest: request returningResponse:httpResponse error:&error];
		NSString *string		= [[NSString alloc] initWithData: responseData encoding: NSUTF8StringEncoding];
		*httpResponseContent	= string;

		if (!error && (*httpResponse).statusCode >= 200 && (*httpResponse).statusCode < 300)
		{
			returnValue = @{
							RETURN_VALUE		: @(YES),
							RETURN_STATUS_CODE	: @((*httpResponse).statusCode),
							RETURN_ERROR_CODE	: @(INT16_MIN),
							RETURN_DESCRIPTION	: NSLocalizedString (@"Success", @"Success"),
							RETURN_CONTENT		: string ? string : @""
							};
		}
		else
		{
			returnValue = @{
							RETURN_VALUE		: @(NO),
							RETURN_STATUS_CODE	: @(error.code),
							RETURN_ERROR_CODE	: @(error.code),
							RETURN_DESCRIPTION	: NSLocalizedString (@"Fail", @"Fail"),
							RETURN_CONTENT		: string ? string : @""
							};

			if ([self.delegate respondsToSelector: @selector (onWebHelperRequestError:)])
			{
				[self.delegate onWebHelperRequestError: error];
			}
		}
	}

	if ([self.delegate respondsToSelector: @selector (onEndWebHelperRequest)])
	{
		[self.delegate onEndWebHelperRequest];
	}
	
	return returnValue;
}

/*!
 Http Request to the web server.

 @param		url								URL address to send
 @param		Boundary						The boundary of Http Request
 @param		WebFormParameters				The Web Form Parameters of Http Request
 @param		WebFormPostFiles				The Web Form Post Files of Http Request
 @param		HttpResponseContent				The content of Http response

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */
- (NSDictionary *) httpRequest: (NSString *) url WebFormParameters: (id) webFormParameters WebFormPostFiles: (id) webFormPostFiles HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent
{
	NSString *boundary = [self boundary];

	return [self httpRequest: url HTTPHeaderFields: nil Boundary: boundary WebFormParameters: webFormParameters WebFormPostFiles: webFormPostFiles HttpResponseContent: httpResponseContent];
}

/*!
 Http Request to the web server.

 @param		url								URL address to send
 @param		Boundary						The boundary of Http Request
 @param		WebFormParameters				The Web Form Parameters of Http Request
 @param		WebFormPostFiles				The Web Form Post Files of Http Request
 @param		StringEncoding					The encoding of HTTP Request
 @param		HttpResponseContent				The content of Http response

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */
- (NSDictionary *) httpRequest: (NSString *) url Boundary: (NSString *) boundary WebFormParameters: (id) webFormParameters WebFormPostFiles: (id) webFormPostFiles StringEncoding: (NSStringEncoding) stringEncoding HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent
{
	return [self httpRequest: url HTTPHeaderFields: nil Boundary: boundary WebFormParameters: webFormParameters WebFormPostFiles: webFormPostFiles StringEncoding: stringEncoding HttpResponseContent: httpResponseContent];
}

/*!
 Http Request to the web server.

 @param		url								URL address to send
 @param		HTTPHeaderFields				HTTP Request Header Fields
 @param		Boundary						The boundary of Http Request
 @param		WebFormParameters				The Web Form Parameters of Http Request
 @param		WebFormPostFiles				The Web Form Post Files of Http Request
 @param		HttpResponseContent				The content of Http response

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */
- (NSDictionary *) httpRequest: (NSString *) url HTTPHeaderFields: (NSDictionary *) httpHeaderFields Boundary: (NSString *) boundary WebFormParameters: (id) webFormParameters WebFormPostFiles: (id) webFormPostFiles HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent
{
	NSHTTPURLResponse *httpURLResponse = [[NSHTTPURLResponse alloc] init];

	return [self httpRequest: url HTTPHeaderFields: httpHeaderFields EnableCookieStorage: YES Boundary: boundary WebFormParameters: webFormParameters WebFormPostFiles: webFormPostFiles TimeoutInterval: DEFAULT_TIMEOUT_THROTTLE RequestCachePolicy: NSURLRequestReloadIgnoringCacheData UseAsynchronous: NO HTTPRequestDelegate: nil StringEncoding: NSUTF8StringEncoding HTTPRequestCompletionHandler: nil HttpResponse: &httpURLResponse HttpResponseContent: httpResponseContent];
}

/*!
 Http Request to the web server.

 @param		url								URL address to send
 @param		HTTPHeaderFields				HTTP Request Header Fields
 @param		Boundary						The boundary of Http Request
 @param		WebFormParameters				The Web Form Parameters of Http Request
 @param		WebFormPostFiles				The Web Form Post Files of Http Request
@param		StringEncoding					The encoding of HTTP Request
 @param		HttpResponseContent				The content of Http response

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */
- (NSDictionary *) httpRequest: (NSString *) url HTTPHeaderFields: (NSDictionary *) httpHeaderFields Boundary: (NSString *) boundary WebFormParameters: (id) webFormParameters WebFormPostFiles: (id) webFormPostFiles StringEncoding: (NSStringEncoding) stringEncoding HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent
{
	NSHTTPURLResponse *httpURLResponse = [[NSHTTPURLResponse alloc] init];

	return [self httpRequest: url HTTPHeaderFields: httpHeaderFields EnableCookieStorage: YES Boundary: boundary WebFormParameters: webFormParameters WebFormPostFiles: webFormPostFiles TimeoutInterval: DEFAULT_TIMEOUT_THROTTLE RequestCachePolicy: NSURLRequestReloadIgnoringCacheData UseAsynchronous: NO HTTPRequestDelegate: nil StringEncoding: stringEncoding HTTPRequestCompletionHandler: nil HttpResponse: &httpURLResponse HttpResponseContent: httpResponseContent];
}

/*!
 Http Request to the web server.

 @param		url								URL address to send
 @param		HTTPHeaderFields				HTTP Request Header Fields
 @param		EnableCookieStorage				Whether to Enable the Cookie Storage support
 @param		Boundary						The boundary of Http Request
 @param		WebFormParameters				The Web Form Parameters of Http Request
 @param		WebFormPostFiles				The Web Form Post Files of Http Request
 @param		TimeoutInterval					Timeout Interval
 @param		RequestCachePolicy				Request Cache Policy
 @param		UseAsynchronous					Whether to use asynchronous request
 @param		HTTPRequestDelegate				The delegate of HTTP Request
 @param		StringEncoding					The encoding of HTTP Request
 @param		HTTPRequestCompletionHandler	HTTP request completion event handler
 @param		HttpResponse					Http Response
 @param		HttpResponseContent				The content of Http response

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */
- (NSDictionary *) httpRequest: (NSString *) url HTTPHeaderFields: (NSDictionary *) httpHeaderFields EnableCookieStorage: (BOOL) enableCookieStorage Boundary: (NSString *) boundary WebFormParameters: (id) webFormParameters WebFormPostFiles: (id) webFormPostFiles TimeoutInterval: (NSTimeInterval) timeoutInterval RequestCachePolicy: (NSURLRequestCachePolicy) requestCachePolicy UseAsynchronous: (BOOL) useAsynchronous HTTPRequestDelegate: (id) httpRequestDelegate StringEncoding: (NSStringEncoding) stringEncoding HTTPRequestCompletionHandler: (void (^) (NSURLResponse *, NSData *, NSError *)) onHTTPRequestCompletionHandler HttpResponse: (NSHTTPURLResponse *__autoreleasing *) httpResponse HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent
{
	if ([self.delegate respondsToSelector: @selector (onBeginWebHelperRequest)])
	{
		[self.delegate onBeginWebHelperRequest];
	}

	url = [url stringByAddingPercentEscapesUsingEncoding: stringEncoding];
	//url = [url stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLQueryAllowedCharacterSet]];

	NSURL *nsurl					= [NSURL URLWithString: url];
	NSMutableURLRequest *request	= [[NSMutableURLRequest alloc] initWithURL: nsurl cachePolicy: requestCachePolicy timeoutInterval: timeoutInterval];

	request.HTTPShouldHandleCookies = enableCookieStorage;
	request.HTTPMethod				= HTTP_METHOD_POST;

	//http://en.wikipedia.org/wiki/List_of_HTTP_header_fields
	[request setValue: KEEP_ALIVE forHTTPHeaderField: CONNECTION];
	[request setValue: DEFAULT_KEEP_ALIVE forHTTPHeaderField: KEEP_ALIVE];

	NSString *multipartFormData = [NSString stringWithFormat: MULTIPART_FORM_DATA, boundary];
	[request setValue: multipartFormData forHTTPHeaderField: CONTENT_TYPE];

	[httpHeaderFields enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {

		[request addValue: obj forHTTPHeaderField: key];
	}];

	NSMutableData *httpRequestBody = [NSMutableData data];

	// Add all form parameters
	if ([webFormParameters isKindOfClass:[NSDictionary class]])
	{
		[webFormParameters enumerateKeysAndObjectsUsingBlock: ^(NSString *key, NSString *value, BOOL *stop) {

			NSString *string	= [NSString stringWithFormat:@"%@%@%@", DELIMITER, boundary, _RETURN_NEW_LINE];
			NSData *data		= [string dataUsingEncoding: stringEncoding];
			[httpRequestBody appendData: data];

			string				= [NSString stringWithFormat: FORM_DATA_NAME, key];
			string				= [NSString stringWithFormat: @"%@: %@%@%@", CONTENT_DISPOSITION, string, _RETURN_NEW_LINE, _RETURN_NEW_LINE];
			data				= [string dataUsingEncoding: stringEncoding];
			[httpRequestBody appendData: data];

			string				= [value stringByAppendingString: _RETURN_NEW_LINE];
			data				= [string dataUsingEncoding: stringEncoding];
			[httpRequestBody appendData: data];
		}];
	}

	// Add all form post files
	if ([webFormPostFiles isKindOfClass:[NSDictionary class]])
	{
		[webFormPostFiles enumerateKeysAndObjectsUsingBlock: ^(NSString *key, NSString *path, BOOL *stop) {

			NSString *string		= [NSString stringWithFormat:@"%@%@%@", DELIMITER, boundary, _RETURN_NEW_LINE];
			NSData *data			= [string dataUsingEncoding: stringEncoding];
			[httpRequestBody appendData: data];

			NSString *fileName		= [path lastPathComponent];
			string					= [NSString stringWithFormat: FORM_DATA_NAME_FILE_NAME, key, fileName];
			string					= [NSString stringWithFormat: @"%@%@", string, _RETURN_NEW_LINE];
			string					= [NSString stringWithFormat:@"%@: %@", CONTENT_DISPOSITION, string];
			data					= [string dataUsingEncoding: stringEncoding];
			[httpRequestBody appendData: data];

			NSString *mimeType		= [self mimeTypeForPath: path];
			string					= [NSString stringWithFormat:@"%@: %@%@%@", CONTENT_TYPE, mimeType, _RETURN_NEW_LINE, _RETURN_NEW_LINE];
			data					= [string dataUsingEncoding: stringEncoding];
			[httpRequestBody appendData: data];

			data					= [NSData dataWithContentsOfFile: path];
			[httpRequestBody appendData: data];

			data					= [_RETURN_NEW_LINE dataUsingEncoding: stringEncoding];
			[httpRequestBody appendData: data];
		}];
	}

	NSString *string				= [NSString stringWithFormat:@"%@%@%@%@", DELIMITER, boundary, DELIMITER, _RETURN_NEW_LINE];
	NSData *data					= [string dataUsingEncoding: stringEncoding];
	[httpRequestBody appendData: data];

	NSString *length				= [NSString stringWithFormat: @"%tu", httpRequestBody.length];
	[request addValue: length forHTTPHeaderField: CONTENT_LENGTH];

	request.HTTPBody				= httpRequestBody;

	NSError *error;

	NSDictionary *returnValue		= [NSDictionary dictionary];

	if (useAsynchronous)
	{
		if (httpRequestDelegate)
			[NSURLConnection connectionWithRequest:request delegate: httpRequestDelegate];
		else
		{
			//
			[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error)
			 {
				 //
				 NSInteger statusCode	= [(NSHTTPURLResponse *) response statusCode];

				 if (!error && statusCode == 200)
				 {
					 SEL selector = NSSelectorFromString (@"onRequestCompleted");

					 if ([httpRequestDelegate respondsToSelector: @selector (selector)])
					 {
						 SuppressPerformSelectorLeakWarning ([httpRequestDelegate performSelector: selector]);
					 }

					 if (onHTTPRequestCompletionHandler)
						 onHTTPRequestCompletionHandler (response, data, error);
				 }
			 }];
		}
	}
	else
	{
		NSData *responseData	= [NSURLConnection sendSynchronousRequest:request returningResponse: httpResponse error:&error];
		NSString *string		= [[NSString alloc] initWithData:responseData encoding: stringEncoding];
		*httpResponseContent	= string;
		NSInteger statusCode	= (*httpResponse).statusCode;

		if (!error && statusCode >= 200 && statusCode < 300)
		{
			returnValue = @{
							RETURN_VALUE		: @(YES),
							RETURN_STATUS_CODE	: @((*httpResponse).statusCode),
							RETURN_ERROR_CODE	: @(INT16_MIN),
							RETURN_DESCRIPTION	: NSLocalizedString (@"Success", @"Success"),
							RETURN_CONTENT		: string ? string : @""
							};
		}
		else
		{
			returnValue = @{
							RETURN_VALUE		: @(NO),
							RETURN_STATUS_CODE	: @(error.code),
							RETURN_ERROR_CODE	: @(error.code),
							RETURN_DESCRIPTION	: NSLocalizedString (@"Fail", @"Fail"),
							RETURN_CONTENT		: string ? string : @""
							};

			if ([self.delegate respondsToSelector: @selector (onWebHelperRequestError:)])
			{
				[self.delegate onWebHelperRequestError: error];
			}
		}
	}

	if ([self.delegate respondsToSelector: @selector (onEndWebHelperRequest)])
	{
		[self.delegate onEndWebHelperRequest];
	}
	
	return returnValue;
}

/*!
 Http WCF Service Request to the web server.

 @param		url								URL address to send
 @param		ServiceContract					The name of Service Contract
 @param		WebMethod						The Web Method
 @param		HttpRequestBody					The body of Http Request
 @param		HttpResponseContent				The content of Http response

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */
- (NSDictionary *) httpRequest: (NSString *) url ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent
{
	NSHTTPURLResponse *httpURLResponse = [[NSHTTPURLResponse alloc] init];

	return [self httpRequest: url HttpMethod: HTTP_METHOD_POST HTTPHeaderFields: nil ServiceContract: serviceContract WebMethod: webMethod HttpRequestBody: httpRequestBody TimeoutInterval: DEFAULT_TIMEOUT_THROTTLE RequestCachePolicy: NSURLRequestReloadIgnoringCacheData UseAsynchronous: NO HTTPRequestDelegate: nil StringEncoding: NSUTF8StringEncoding HTTPRequestCompletionHandler: nil HttpResponse:&httpURLResponse HttpResponseContent: httpResponseContent];
}

/*!
 Http WCF Service Request to the web server.

 @param		url								URL address to send
 @param		HttpMethod						Http Method
 @param		ServiceContract					The name of Service Contract
 @param		WebMethod						The Web Method
 @param		HttpRequestBody					The body of Http Request
 @param		HttpResponseContent				The content of Http response

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */
- (NSDictionary *) httpRequest: (NSString *) url HttpMethod: (NSString *) httpMethod ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent
{
	NSHTTPURLResponse *httpURLResponse = [[NSHTTPURLResponse alloc] init];

	return [self httpRequest: url HttpMethod: httpMethod HTTPHeaderFields: nil ServiceContract: serviceContract WebMethod: webMethod HttpRequestBody: httpRequestBody TimeoutInterval: DEFAULT_TIMEOUT_THROTTLE RequestCachePolicy: NSURLRequestReloadIgnoringCacheData UseAsynchronous: NO HTTPRequestDelegate: nil StringEncoding: NSUTF8StringEncoding HTTPRequestCompletionHandler: nil HttpResponse:&httpURLResponse HttpResponseContent: httpResponseContent];
}

/*!
 Http WCF Service Request to the web server.

 @param		url								URL address to send
 @param		HTTPHeaderFields				HTTP Request Header Fields
 @param		ServiceContract					The name of Service Contract
 @param		WebMethod						The Web Method
 @param		HttpRequestBody					The body of Http Request
 @param		HttpResponseContent				The content of Http response

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */
- (NSDictionary *) httpRequest: (NSString *) url HTTPHeaderFields: (NSDictionary *) httpHeaderFields ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent
{
	NSHTTPURLResponse *httpURLResponse = [[NSHTTPURLResponse alloc] init];

	return [self httpRequest: url HttpMethod: HTTP_METHOD_POST HTTPHeaderFields: httpHeaderFields ServiceContract: serviceContract WebMethod: webMethod HttpRequestBody: httpRequestBody TimeoutInterval: DEFAULT_TIMEOUT_THROTTLE RequestCachePolicy: NSURLRequestReloadIgnoringCacheData UseAsynchronous: NO HTTPRequestDelegate: nil StringEncoding: NSUTF8StringEncoding HTTPRequestCompletionHandler: nil HttpResponse:&httpURLResponse HttpResponseContent: httpResponseContent];
}

/*!
 Http WCF Service Request to the web server.

 @param		url								URL address to send
 @param		HttpMethod						Http Method
 @param		HTTPHeaderFields				HTTP Request Header Fields
 @param		ServiceContract					The name of Service Contract
 @param		WebMethod						The Web Method
 @param		HttpRequestBody					The body of Http Request
 @param		HttpResponseContent				The content of Http response

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */
- (NSDictionary *) httpRequest: (NSString *) url HttpMethod: (NSString *) httpMethod HTTPHeaderFields: (NSDictionary *) httpHeaderFields ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent
{
	NSHTTPURLResponse *httpURLResponse = [[NSHTTPURLResponse alloc] init];

	return [self httpRequest: url HttpMethod: httpMethod HTTPHeaderFields: httpHeaderFields ServiceContract: serviceContract WebMethod: webMethod HttpRequestBody: httpRequestBody TimeoutInterval: DEFAULT_TIMEOUT_THROTTLE RequestCachePolicy: NSURLRequestReloadIgnoringCacheData UseAsynchronous: NO HTTPRequestDelegate: nil StringEncoding: NSUTF8StringEncoding HTTPRequestCompletionHandler: nil HttpResponse:&httpURLResponse HttpResponseContent: httpResponseContent];
}

/*!
 Http WCF Service Request to the web server.

 @param		url								URL address to send
 @param		HttpMethod						Http Method
 @param		HTTPHeaderFields				HTTP Request Header Fields
 @param		ServiceContract					The name of Service Contract
 @param		WebMethod						The Web Method
 @param		HttpRequestBody					The body of Http Request
 @param		HttpResponse					Http Response
 @param		HttpResponseContent				The content of Http response

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */
- (NSDictionary *) httpRequest: (NSString *) url HttpMethod: (NSString *) httpMethod HTTPHeaderFields: (NSDictionary *) httpHeaderFields ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody HttpResponse: (NSHTTPURLResponse *__autoreleasing *) httpResponse HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent
{
	return [self httpRequest: url HttpMethod: httpMethod HTTPHeaderFields: httpHeaderFields ServiceContract: serviceContract WebMethod: webMethod HttpRequestBody: httpRequestBody TimeoutInterval: DEFAULT_TIMEOUT_THROTTLE RequestCachePolicy: NSURLRequestReloadIgnoringCacheData UseAsynchronous: NO HTTPRequestDelegate: nil StringEncoding: NSUTF8StringEncoding HTTPRequestCompletionHandler: nil HttpResponse:httpResponse HttpResponseContent:httpResponseContent];
}

/*!
 Http WCF Service Request to the web server.

 @param		url								URL address to send
 @param		HttpMethod						Http Method
 @param		HTTPHeaderFields				HTTP Request Header Fields
 @param		ServiceContract					The name of Service Contract
 @param		WebMethod						The Web Method
 @param		HttpRequestBody					The body of Http Request
 @param		HTTPRequestCompletionHandler	HTTP request completion event handler
 @param		HttpResponse					Http Response
 @param		HttpResponseContent				The content of Http response

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */
- (NSDictionary *) httpRequest: (NSString *) url HttpMethod: (NSString *) httpMethod HTTPHeaderFields: (NSDictionary *) httpHeaderFields ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody HTTPRequestCompletionHandler: (void (^) (NSURLResponse *, NSData *, NSError *)) onHTTPRequestCompletionHandler HttpResponse: (NSHTTPURLResponse *__autoreleasing *) httpResponse HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent
{
	return [self httpRequest: url HttpMethod: httpMethod HTTPHeaderFields: httpHeaderFields ServiceContract: serviceContract WebMethod: webMethod HttpRequestBody: httpRequestBody TimeoutInterval: DEFAULT_TIMEOUT_THROTTLE RequestCachePolicy: NSURLRequestReloadIgnoringCacheData UseAsynchronous: NO HTTPRequestDelegate: nil StringEncoding: NSUTF8StringEncoding HTTPRequestCompletionHandler: onHTTPRequestCompletionHandler HttpResponse:httpResponse HttpResponseContent:httpResponseContent];
}

/*!
 Http WCF Service Request to the web server.

 @param		url								URL address to send
 @param		HttpMethod						Http Method
 @param		HTTPHeaderFields				HTTP Request Header Fields
 @param		ServiceContract					The name of Service Contract
 @param		WebMethod						The Web Method
 @param		HttpRequestBody					The body of Http Request
 @param		StringEncoding					String Encoding
 @param		HTTPRequestCompletionHandler	HTTP request completion event handler
 @param		HttpResponse					Http Response
 @param		HttpResponseContent				The content of Http response

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */
- (NSDictionary *) httpRequest: (NSString *) url HttpMethod: (NSString *) httpMethod HTTPHeaderFields: (NSDictionary *) httpHeaderFields ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody StringEncoding: (NSStringEncoding) stringEncoding HTTPRequestCompletionHandler: (void (^) (NSURLResponse *, NSData *, NSError *)) onHTTPRequestCompletionHandler HttpResponse: (NSHTTPURLResponse *__autoreleasing *) httpResponse HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent
{
	return [self httpRequest: url HttpMethod: httpMethod HTTPHeaderFields: httpHeaderFields ServiceContract: serviceContract WebMethod: webMethod HttpRequestBody: httpRequestBody TimeoutInterval: DEFAULT_TIMEOUT_THROTTLE RequestCachePolicy: NSURLRequestReloadIgnoringCacheData UseAsynchronous: NO HTTPRequestDelegate: nil StringEncoding: stringEncoding HTTPRequestCompletionHandler: onHTTPRequestCompletionHandler HttpResponse:httpResponse HttpResponseContent:httpResponseContent];
}

/*!
 Http WCF Service Request to the web server.

 @param		url								URL address to send
 @param		HttpMethod						Http Method
 @param		HTTPHeaderFields				HTTP Request Header Fields
 @param		ServiceContract					The name of Service Contract
 @param		WebMethod						The Web Method
 @param		HttpRequestBody					The body of Http Request
 @param		HTTPRequestDelegate				The delegate of HTTP Request
 @param		StringEncoding					String Encoding
 @param		HTTPRequestCompletionHandler	HTTP request completion event handler
 @param		HttpResponse					Http Response
 @param		HttpResponseContent				The content of Http response

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */
- (NSDictionary *) httpRequest: (NSString *) url HttpMethod: (NSString *) httpMethod HTTPHeaderFields: (NSDictionary *) httpHeaderFields ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody HTTPRequestDelegate: (id) httpRequestDelegate StringEncoding: (NSStringEncoding) stringEncoding HTTPRequestCompletionHandler: (void (^) (NSURLResponse *, NSData *, NSError *)) onHTTPRequestCompletionHandler HttpResponse: (NSHTTPURLResponse *__autoreleasing *) httpResponse HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent
{
	return [self httpRequest: url HttpMethod: httpMethod HTTPHeaderFields: httpHeaderFields ServiceContract: serviceContract WebMethod: webMethod HttpRequestBody: httpRequestBody TimeoutInterval: DEFAULT_TIMEOUT_THROTTLE RequestCachePolicy: NSURLRequestReloadIgnoringCacheData UseAsynchronous: NO HTTPRequestDelegate: httpRequestDelegate StringEncoding: stringEncoding HTTPRequestCompletionHandler: onHTTPRequestCompletionHandler HttpResponse:httpResponse HttpResponseContent:httpResponseContent];
}

/*!
 Http WCF Service Request to the web server.

 @param		url								URL address to send
 @param		HttpMethod						Http Method
 @param		HTTPHeaderFields				HTTP Request Header Fields
 @param		ServiceContract					The name of Service Contract
 @param		WebMethod						The Web Method
 @param		HttpRequestBody					The body of Http Request
 @param		UseAsynchronous					Whether to use asynchronous request
 @param		HTTPRequestDelegate				The delegate of HTTP Request
 @param		StringEncoding					String Encoding
 @param		HTTPRequestCompletionHandler	HTTP request completion event handler
 @param		HttpResponse					Http Response
 @param		HttpResponseContent				The content of Http response

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */
- (NSDictionary *) httpRequest: (NSString *) url HttpMethod: (NSString *) httpMethod HTTPHeaderFields: (NSDictionary *) httpHeaderFields ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody UseAsynchronous: (BOOL) useAsynchronous HTTPRequestDelegate: (id) httpRequestDelegate StringEncoding: (NSStringEncoding) stringEncoding HTTPRequestCompletionHandler: (void (^) (NSURLResponse *, NSData *, NSError *)) onHTTPRequestCompletionHandler HttpResponse: (NSHTTPURLResponse *__autoreleasing *) httpResponse HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent
{
	return [self httpRequest: url HttpMethod: httpMethod HTTPHeaderFields: httpHeaderFields ServiceContract: serviceContract WebMethod: webMethod HttpRequestBody: httpRequestBody TimeoutInterval: DEFAULT_TIMEOUT_THROTTLE RequestCachePolicy: NSURLRequestReloadIgnoringCacheData UseAsynchronous: useAsynchronous HTTPRequestDelegate: httpRequestDelegate StringEncoding: stringEncoding HTTPRequestCompletionHandler: onHTTPRequestCompletionHandler HttpResponse:httpResponse HttpResponseContent:httpResponseContent];
}

/*!
 Http WCF Service Request to the web server.

 @param		url								URL address to send
 @param		HttpMethod						Http Method
 @param		HTTPHeaderFields				HTTP Request Header Fields
 @param		ServiceContract					The name of Service Contract
 @param		WebMethod						The Web Method
 @param		HttpRequestBody					The body of Http Request
 @param		TimeoutInterval					Timeout Interval
 @param		RequestCachePolicy				Request Cache Policy
 @param		UseAsynchronous					Whether to use asynchronous request
 @param		HTTPRequestDelegate				The delegate of HTTP Request
 @param		StringEncoding					String Encoding
 @param		HTTPRequestCompletionHandler	HTTP request completion event handler
 @param		HttpResponse					Http Response
 @param		HttpResponseContent				The content of Http response

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */
- (NSDictionary *) httpRequest: (NSString *) url HttpMethod: (NSString *) httpMethod HTTPHeaderFields: (NSDictionary *) httpHeaderFields ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody TimeoutInterval: (NSTimeInterval) timeoutInterval RequestCachePolicy: (NSURLRequestCachePolicy) requestCachePolicy UseAsynchronous: (BOOL) useAsynchronous HTTPRequestDelegate: (id) httpRequestDelegate StringEncoding: (NSStringEncoding) stringEncoding HTTPRequestCompletionHandler: (void (^) (NSURLResponse *, NSData *, NSError *)) onHTTPRequestCompletionHandler HttpResponse: (NSHTTPURLResponse *__autoreleasing *) httpResponse HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent
{
	if ([self.delegate respondsToSelector: @selector (onBeginWebHelperRequest)])
	{
		[self.delegate onBeginWebHelperRequest];
	}

	url = [url stringByAddingPercentEscapesUsingEncoding: stringEncoding];
	//url = [url stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLQueryAllowedCharacterSet]];

	NSURL *nsurl					= [NSURL URLWithString: url];
	NSMutableURLRequest *request	= [[NSMutableURLRequest alloc] initWithURL: nsurl cachePolicy: requestCachePolicy timeoutInterval: timeoutInterval];

	request.HTTPShouldHandleCookies = YES;
	request.HTTPMethod				= httpMethod;

	//http://en.wikipedia.org/wiki/List_of_HTTP_header_fields
	[request setValue: KEEP_ALIVE forHTTPHeaderField: CONNECTION];
	[request setValue: DEFAULT_KEEP_ALIVE forHTTPHeaderField: KEEP_ALIVE];
	[request setValue: TEXT_XML forHTTPHeaderField: CONTENT_TYPE];
	NSString *soapActionValue = [NSString stringWithFormat: SOAP_ACTION_VALUE, serviceContract, webMethod];
	[request setValue: soapActionValue forHTTPHeaderField: SOAP_ACTION_FIELD];

	[httpHeaderFields enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {

		[request addValue: key forHTTPHeaderField: key];
	}];

	if (httpRequestBody)
	{
		NSString *SoapMessage		= [SERVICE_SOAP_MESSAGE_TEMPLATE stringByReplacingOccurrencesOfString: SOAP_METHOD_TEMPLATE withString: webMethod];
		NSMutableArray * pairs		= [NSMutableArray array];

		[httpRequestBody enumerateKeysAndObjectsUsingBlock: ^(NSString *key, NSString *value, BOOL *stop) {

			NSString *pair			=[NSString stringWithFormat: @"<%@>%@</%@>", key, value, key];
			[pairs addObject: pair];
		}];

		NSString * body				= [pairs componentsJoinedByString: @""];
		SoapMessage					= [SoapMessage stringByReplacingOccurrencesOfString: SOAP_MESSAGE_TEMPLATE withString: body];
		NSData * data				= [SoapMessage dataUsingEncoding: stringEncoding];
		NSString *length			= [NSString stringWithFormat: @"%tu", data.length];
		[request addValue: length forHTTPHeaderField: CONTENT_LENGTH];
		request.HTTPBody			= data;
	}

	NSError *error;

	NSDictionary *returnValue			= [NSDictionary dictionary];

	if (useAsynchronous)
	{
		/*
		 while(!finished) {

		 [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDatedistantFuture]];

		 }
		 */

		if (httpRequestDelegate)
			[NSURLConnection connectionWithRequest:request delegate: httpRequestDelegate];
		else
		{
			//
			[NSURLConnection sendAsynchronousRequest: request queue:[NSOperationQueue mainQueue] completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error)
			 {
				 //
				 NSInteger statusCode	= [(NSHTTPURLResponse *) response statusCode];

				 if (!error && statusCode == 200)
				 {
					 SEL selector = NSSelectorFromString (@"onRequestCompleted");

					 if ([httpRequestDelegate respondsToSelector: @selector (selector)])
					 {
						 SuppressPerformSelectorLeakWarning ([httpRequestDelegate performSelector: selector]);
					 }

					 if (onHTTPRequestCompletionHandler)
						 onHTTPRequestCompletionHandler (response, data, error);
				 }
				 else
				 {
					 SEL selector = NSSelectorFromString (@"onWebHelperRequestError:");
					 SuppressPerformSelectorLeakWarning ([httpRequestDelegate performSelector: selector withObject: error]);
				 }
			 }];
		}
	}
	else
	{
		NSData *responseData	= [NSURLConnection sendSynchronousRequest: request returningResponse:httpResponse error:&error];
		NSString *string		= [[NSString alloc] initWithData: responseData encoding: NSUTF8StringEncoding];
		*httpResponseContent	= string;
		NSInteger statusCode	= (*httpResponse).statusCode;

		if (!error && statusCode >= 200 && statusCode < 300)
		{
			returnValue	= @{
							RETURN_VALUE		: @(YES),
							RETURN_STATUS_CODE	: @((*httpResponse).statusCode),
							RETURN_ERROR_CODE	: @(INT16_MIN),
							RETURN_DESCRIPTION	: NSLocalizedString (@"Success", @"Success"),
							RETURN_CONTENT		: string ? string : @""
							};
		}
		else
		{
			returnValue = @{
							RETURN_VALUE		: @(NO),
							RETURN_STATUS_CODE	: @(error.code),
							RETURN_ERROR_CODE	: @(error.code),
							RETURN_DESCRIPTION	: NSLocalizedString (@"Fail", @"Fail"),
							RETURN_CONTENT		: string ? string : @""
							};

			if ([self.delegate respondsToSelector: @selector (onWebHelperRequestError:)])
			{
				[self.delegate onWebHelperRequestError: error];
			}
		}
	}

	if ([self.delegate respondsToSelector: @selector (onEndWebHelperRequest)])
	{
		[self.delegate onEndWebHelperRequest];
	}
	
	return returnValue;
}

/*!
 Http request to the web server with Security Socket Layer.

 @param		url								URL address to send
 @param		Certificate						Certificate to access the server
 @param		CertificateCredential			Certificate Password
 @param		ServiceContract					The name of Service Contract
 @param		WebMethod						The Web Method
 @param		HttpRequestBody					The body of Http Requestg
 @param		OnResponseReceivedEventHandler	The event handler of on Response received
 @param		OnDataReceivedEventHandler		The event handler of on Data received
 @param		OnFailWithErrorEventHandler		The event handler of error

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */

- (void) HttpRequest: (NSString *) url Certificate: (NSString *) certificate CertificateCredential: (NSString *) certificateCredential ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody OnDataReceivedEventHandler: (void (^) (NSURLConnection *connection, NSData *data)) onDataReceivedEventHandler OnFailWithErrorEventHandler: (void (^) (NSURLConnection *connection, NSError *error)) onFailWithErrorEventHandler
{
	[self HttpRequest: url Certificate: certificate CertificateCredential: certificateCredential HttpMethod: HTTP_METHOD_POST HTTPHeaderFields: nil ServiceContract: serviceContract WebMethod: webMethod HttpRequestBody: httpRequestBody TimeoutInterval: DEFAULT_TIMEOUT_THROTTLE RequestCachePolicy: NSURLRequestReloadIgnoringCacheData HTTPRequestDelegate: nil StringEncoding: NSUTF8StringEncoding OnResponseReceivedEventHandler: nil OnDataReceivedEventHandler: onDataReceivedEventHandler OnFailWithErrorEventHandler: onFailWithErrorEventHandler StartImmediately: YES];
}

/*!
 Http request to the web server with Security Socket Layer.

 @param		url								URL address to send
 @param		Certificate						Certificate to access the server
 @param		CertificateCredential			Certificate Password
 @param		ServiceContract					The name of Service Contract
 @param		WebMethod						The Web Method
 @param		HttpRequestBody					The body of Http Requestg
 @param		OnResponseReceivedEventHandler	The event handler of on Response received
 @param		OnDataReceivedEventHandler		The event handler of on Data received
 @param		OnFailWithErrorEventHandler		The event handler of error

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */

- (void) HttpRequest: (NSString *) url Certificate: (NSString *) certificate CertificateCredential: (NSString *) certificateCredential ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody OnResponseReceivedEventHandler: (void (^) (NSURLConnection *connection, NSURLResponse *response)) onResponseReceivedEventHandler OnDataReceivedEventHandler: (void (^) (NSURLConnection *connection, NSData *data)) onDataReceivedEventHandler OnFailWithErrorEventHandler: (void (^) (NSURLConnection *connection, NSError *error)) onFailWithErrorEventHandler
{
	[self HttpRequest: url Certificate: certificate CertificateCredential: certificateCredential HttpMethod: HTTP_METHOD_POST HTTPHeaderFields: nil ServiceContract: serviceContract WebMethod: webMethod HttpRequestBody: httpRequestBody TimeoutInterval: DEFAULT_TIMEOUT_THROTTLE RequestCachePolicy: NSURLRequestReloadIgnoringCacheData HTTPRequestDelegate: nil StringEncoding: NSUTF8StringEncoding OnResponseReceivedEventHandler: onResponseReceivedEventHandler OnDataReceivedEventHandler: onDataReceivedEventHandler OnFailWithErrorEventHandler: onFailWithErrorEventHandler StartImmediately: YES];
}

/*!
 Http request to the web server with Security Socket Layer.

 @param		url								URL address to send
 @param		Certificate						Certificate to access the server
 @param		CertificateCredential			Certificate Password
 @param		HttpMethod						Http Method
 @param		ServiceContract					The name of Service Contract
 @param		WebMethod						The Web Method
 @param		HttpRequestBody					The body of Http Request
 @param		OnResponseReceivedEventHandler	The event handler of on Response received
 @param		OnDataReceivedEventHandler		The event handler of on Data received
 @param		OnFailWithErrorEventHandler		The event handler of error
 @param		StartImmediately				Start the request immediately?

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */

- (void) HttpRequest: (NSString *) url Certificate: (NSString *) certificate CertificateCredential: (NSString *) certificateCredential ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody OnResponseReceivedEventHandler: (void (^) (NSURLConnection *connection, NSURLResponse *response)) onResponseReceivedEventHandler OnDataReceivedEventHandler: (void (^) (NSURLConnection *connection, NSData *data)) onDataReceivedEventHandler OnFailWithErrorEventHandler: (void (^) (NSURLConnection *connection, NSError *error)) onFailWithErrorEventHandler StartImmediately: (BOOL) startImmediately
{
	[self HttpRequest: url Certificate: certificate CertificateCredential: certificateCredential HttpMethod: HTTP_METHOD_POST HTTPHeaderFields: nil ServiceContract: serviceContract WebMethod: webMethod HttpRequestBody: httpRequestBody TimeoutInterval: DEFAULT_TIMEOUT_THROTTLE RequestCachePolicy: NSURLRequestReloadIgnoringCacheData HTTPRequestDelegate: nil StringEncoding: NSUTF8StringEncoding OnResponseReceivedEventHandler: onResponseReceivedEventHandler OnDataReceivedEventHandler: onDataReceivedEventHandler OnFailWithErrorEventHandler: onFailWithErrorEventHandler StartImmediately: startImmediately];
}

/*!
 Http request to the web server with Security Socket Layer.

 @param		url								URL address to send
 @param		Certificate						Certificate to access the server
 @param		CertificateCredential			Certificate Password
 @param		HttpMethod						Http Method
 @param		HTTPHeaderFields				HTTP Request Header Fields
 @param		ServiceContract					The name of Service Contract
 @param		WebMethod						The Web Method
 @param		HttpRequestBody					The body of Http Request
 @param		OnResponseReceivedEventHandler	The event handler of on Response received
 @param		OnDataReceivedEventHandler		The event handler of on Data received
 @param		OnFailWithErrorEventHandler		The event handler of error
 @param		StartImmediately				Start the request immediately?

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */

- (void) HttpRequest: (NSString *) url Certificate: (NSString *) certificate CertificateCredential: (NSString *) certificateCredential HTTPHeaderFields: (NSDictionary *) httpHeaderFields ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody OnResponseReceivedEventHandler: (void (^) (NSURLConnection *connection, NSURLResponse *response)) onResponseReceivedEventHandler OnDataReceivedEventHandler: (void (^) (NSURLConnection *connection, NSData *data)) onDataReceivedEventHandler OnFailWithErrorEventHandler: (void (^) (NSURLConnection *connection, NSError *error)) onFailWithErrorEventHandler StartImmediately: (BOOL) startImmediately
{
	[self HttpRequest: url Certificate: certificate CertificateCredential: certificateCredential HttpMethod: HTTP_METHOD_POST HTTPHeaderFields: httpHeaderFields ServiceContract: serviceContract WebMethod: webMethod HttpRequestBody: httpRequestBody TimeoutInterval: DEFAULT_TIMEOUT_THROTTLE RequestCachePolicy: NSURLRequestReloadIgnoringCacheData HTTPRequestDelegate: nil StringEncoding: NSUTF8StringEncoding OnResponseReceivedEventHandler: onResponseReceivedEventHandler OnDataReceivedEventHandler: onDataReceivedEventHandler OnFailWithErrorEventHandler: onFailWithErrorEventHandler StartImmediately: startImmediately];
}

/*!
 Http request to the web server with Security Socket Layer.

 @param		url								URL address to send
 @param		Certificate						Certificate to access the server
 @param		CertificateCredential			Certificate Password
 @param		HttpMethod						Http Method
 @param		HTTPHeaderFields				HTTP Request Header Fields
 @param		ServiceContract					The name of Service Contract
 @param		WebMethod						The Web Method
 @param		HttpRequestBody					The body of Http Request
 @param		HTTPRequestDelegate				The delegate of HTTP Request
 @param		StringEncoding					String Encoding
 @param		OnResponseReceivedEventHandler	The event handler of on Response received
 @param		OnDataReceivedEventHandler		The event handler of on Data received
 @param		OnFailWithErrorEventHandler		The event handler of error
 @param		StartImmediately				Start the request immediately?

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */

- (void) HttpRequest: (NSString *) url Certificate: (NSString *) certificate CertificateCredential: (NSString *) certificateCredential HTTPHeaderFields: (NSDictionary *) httpHeaderFields ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody HTTPRequestDelegate: (id) httpRequestDelegate OnResponseReceivedEventHandler: (void (^) (NSURLConnection *connection, NSURLResponse *response)) onResponseReceivedEventHandler OnDataReceivedEventHandler: (void (^) (NSURLConnection *connection, NSData *data)) onDataReceivedEventHandler OnFailWithErrorEventHandler: (void (^) (NSURLConnection *connection, NSError *error)) onFailWithErrorEventHandler StartImmediately: (BOOL) startImmediately
{
	[self HttpRequest: url Certificate: certificate CertificateCredential: certificateCredential HttpMethod: HTTP_METHOD_POST HTTPHeaderFields: httpHeaderFields ServiceContract: serviceContract WebMethod: webMethod HttpRequestBody: httpRequestBody TimeoutInterval: DEFAULT_TIMEOUT_THROTTLE RequestCachePolicy: NSURLRequestReloadIgnoringCacheData HTTPRequestDelegate: httpRequestDelegate StringEncoding: NSUTF8StringEncoding OnResponseReceivedEventHandler: onResponseReceivedEventHandler OnDataReceivedEventHandler: onDataReceivedEventHandler OnFailWithErrorEventHandler: onFailWithErrorEventHandler StartImmediately: startImmediately];
}

/*!
 Http request to the web server with Security Socket Layer.

 @param		url								URL address to send
 @param		Certificate						Certificate to access the server
 @param		CertificateCredential			Certificate Password
 @param		HttpMethod						Http Method
 @param		HTTPHeaderFields				HTTP Request Header Fields
 @param		ServiceContract					The name of Service Contract
 @param		WebMethod						The Web Method
 @param		HttpRequestBody					The body of Http Request
 @param		RequestCachePolicy				Request Cache Policy
 @param		HTTPRequestDelegate				The delegate of HTTP Request
 @param		StringEncoding					String Encoding
 @param		OnResponseReceivedEventHandler	The event handler of on Response received
 @param		OnDataReceivedEventHandler		The event handler of on Data received
 @param		OnFailWithErrorEventHandler		The event handler of error
 @param		StartImmediately				Start the request immediately?

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */

- (void) HttpRequest: (NSString *) url Certificate: (NSString *) certificate CertificateCredential: (NSString *) certificateCredential HTTPHeaderFields: (NSDictionary *) httpHeaderFields ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody RequestCachePolicy: (NSURLRequestCachePolicy) requestCachePolicy HTTPRequestDelegate: (id) httpRequestDelegate OnResponseReceivedEventHandler: (void (^) (NSURLConnection *connection, NSURLResponse *response)) onResponseReceivedEventHandler OnDataReceivedEventHandler: (void (^) (NSURLConnection *connection, NSData *data)) onDataReceivedEventHandler OnFailWithErrorEventHandler: (void (^) (NSURLConnection *connection, NSError *error)) onFailWithErrorEventHandler StartImmediately: (BOOL) startImmediately
{
	[self HttpRequest: url Certificate: certificate CertificateCredential: certificateCredential HttpMethod: HTTP_METHOD_POST HTTPHeaderFields: httpHeaderFields ServiceContract: serviceContract WebMethod: webMethod HttpRequestBody: httpRequestBody TimeoutInterval: DEFAULT_TIMEOUT_THROTTLE RequestCachePolicy: requestCachePolicy HTTPRequestDelegate: httpRequestDelegate StringEncoding: NSUTF8StringEncoding OnResponseReceivedEventHandler: onResponseReceivedEventHandler OnDataReceivedEventHandler: onDataReceivedEventHandler OnFailWithErrorEventHandler: onFailWithErrorEventHandler StartImmediately: startImmediately];
}

/*!
 Http request to the web server with Security Socket Layer.

 @param		url								URL address to send
 @param		Certificate						Certificate to access the server
 @param		CertificateCredential			Certificate Password
 @param		HTTPHeaderFields				HTTP Request Header Fields
 @param		ServiceContract					The name of Service Contract
 @param		WebMethod						The Web Method
 @param		HttpRequestBody					The body of Http Request
 @param		TimeoutInterval					Timeout Interval
 @param		RequestCachePolicy				Request Cache Policy
 @param		HTTPRequestDelegate				The delegate of HTTP Request
 @param		OnResponseReceivedEventHandler	The event handler of on Response received
 @param		OnDataReceivedEventHandler		The event handler of on Data received
 @param		OnFailWithErrorEventHandler		The event handler of error
 @param		StartImmediately				Start the request immediately?

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */

- (void) HttpRequest: (NSString *) url Certificate: (NSString *) certificate CertificateCredential: (NSString *) certificateCredential HTTPHeaderFields: (NSDictionary *) httpHeaderFields ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody TimeoutInterval: (NSTimeInterval) timeoutInterval RequestCachePolicy: (NSURLRequestCachePolicy) requestCachePolicy HTTPRequestDelegate: (id) httpRequestDelegate OnResponseReceivedEventHandler: (void (^) (NSURLConnection *connection, NSURLResponse *response)) onResponseReceivedEventHandler OnDataReceivedEventHandler: (void (^) (NSURLConnection *connection, NSData *data)) onDataReceivedEventHandler OnFailWithErrorEventHandler: (void (^) (NSURLConnection *connection, NSError *error)) onFailWithErrorEventHandler StartImmediately: (BOOL) startImmediately
{
	[self HttpRequest: url Certificate: certificate CertificateCredential: certificateCredential HttpMethod: HTTP_METHOD_POST HTTPHeaderFields: httpHeaderFields ServiceContract: serviceContract WebMethod: webMethod HttpRequestBody: httpRequestBody TimeoutInterval: timeoutInterval RequestCachePolicy: requestCachePolicy HTTPRequestDelegate: httpRequestDelegate StringEncoding: NSUTF8StringEncoding OnResponseReceivedEventHandler: onResponseReceivedEventHandler OnDataReceivedEventHandler: onDataReceivedEventHandler OnFailWithErrorEventHandler: onFailWithErrorEventHandler StartImmediately: startImmediately];
}

/*!
 Http request to the web server with Security Socket Layer.

 @param		url								URL address to send
 @param		Certificate						Certificate to access the server
 @param		CertificateCredential			Certificate Password
 @param		HttpMethod						Http Method
 @param		HTTPHeaderFields				HTTP Request Header Fields
 @param		ServiceContract					The name of Service Contract
 @param		WebMethod						The Web Method
 @param		HttpRequestBody					The body of Http Request
 @param		TimeoutInterval					Timeout Interval
 @param		RequestCachePolicy				Request Cache Policy
 @param		HTTPRequestDelegate				The delegate of HTTP Request
 @param		OnResponseReceivedEventHandler	The event handler of on Response received
 @param		OnDataReceivedEventHandler		The event handler of on Data received
 @param		OnFailWithErrorEventHandler		The event handler of error
 @param		StartImmediately				Start the request immediately?

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */

- (void) HttpRequest: (NSString *) url Certificate: (NSString *) certificate CertificateCredential: (NSString *) certificateCredential HttpMethod: (NSString *) httpMethod HTTPHeaderFields: (NSDictionary *) httpHeaderFields ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody TimeoutInterval: (NSTimeInterval) timeoutInterval RequestCachePolicy: (NSURLRequestCachePolicy) requestCachePolicy HTTPRequestDelegate: (id) httpRequestDelegate OnResponseReceivedEventHandler: (void (^) (NSURLConnection *connection, NSURLResponse *response)) onResponseReceivedEventHandler OnDataReceivedEventHandler: (void (^) (NSURLConnection *connection, NSData *data)) onDataReceivedEventHandler OnFailWithErrorEventHandler: (void (^) (NSURLConnection *connection, NSError *error)) onFailWithErrorEventHandler StartImmediately: (BOOL) startImmediately
{
	[self HttpRequest: url Certificate: certificate CertificateCredential: certificateCredential HttpMethod: httpMethod HTTPHeaderFields: httpHeaderFields ServiceContract: serviceContract WebMethod: webMethod HttpRequestBody: httpRequestBody TimeoutInterval: timeoutInterval RequestCachePolicy: requestCachePolicy HTTPRequestDelegate: httpRequestDelegate StringEncoding: NSUTF8StringEncoding OnResponseReceivedEventHandler: onResponseReceivedEventHandler OnDataReceivedEventHandler: onDataReceivedEventHandler OnFailWithErrorEventHandler: onFailWithErrorEventHandler StartImmediately: startImmediately];
}

/*!
 Http request to the web server with Security Socket Layer.

 @param		url								URL address to send
 @param		Certificate						Certificate to access the server
 @param		CertificateCredential			Certificate Password
 @param		HTTPHeaderFields				HTTP Request Header Fields
 @param		ServiceContract					The name of Service Contract
 @param		WebMethod						The Web Method
 @param		HttpRequestBody					The body of Http Request
 @param		TimeoutInterval					Timeout Interval
 @param		RequestCachePolicy				Request Cache Policy
 @param		HTTPRequestDelegate				The delegate of HTTP Request
 @param		StringEncoding					String Encoding
 @param		OnResponseReceivedEventHandler	The event handler of on Response received
 @param		OnDataReceivedEventHandler		The event handler of on Data received
 @param		OnFailWithErrorEventHandler		The event handler of error
 @param		StartImmediately				Start the request immediately?

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */

- (void) HttpRequest: (NSString *) url Certificate: (NSString *) certificate CertificateCredential: (NSString *) certificateCredential HttpMethod: (NSString *) httpMethod HTTPHeaderFields: (NSDictionary *) httpHeaderFields ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody TimeoutInterval: (NSTimeInterval) timeoutInterval RequestCachePolicy: (NSURLRequestCachePolicy) requestCachePolicy StringEncoding: (NSStringEncoding) stringEncoding OnResponseReceivedEventHandler: (void (^) (NSURLConnection *connection, NSURLResponse *response)) onResponseReceivedEventHandler OnDataReceivedEventHandler: (void (^) (NSURLConnection *connection, NSData *data)) onDataReceivedEventHandler OnFailWithErrorEventHandler: (void (^) (NSURLConnection *connection, NSError *error)) onFailWithErrorEventHandler StartImmediately: (BOOL) startImmediately
{
	[self HttpRequest: url Certificate: certificate CertificateCredential: certificateCredential HttpMethod: httpMethod HTTPHeaderFields: httpHeaderFields ServiceContract: serviceContract WebMethod: webMethod HttpRequestBody: httpRequestBody TimeoutInterval: timeoutInterval RequestCachePolicy: requestCachePolicy HTTPRequestDelegate: nil StringEncoding: stringEncoding OnResponseReceivedEventHandler: onResponseReceivedEventHandler OnDataReceivedEventHandler: onDataReceivedEventHandler OnFailWithErrorEventHandler: onFailWithErrorEventHandler StartImmediately: startImmediately];
}

/*!
 Http request to the web server with Security Socket Layer.

 @param		url								URL address to send
 @param		Certificate						Certificate to access the server
 @param		CertificateCredential			Certificate Password
 @param		HttpMethod						Http Method
 @param		HTTPHeaderFields				HTTP Request Header Fields
 @param		ServiceContract					The name of Service Contract
 @param		WebMethod						The Web Method
 @param		HttpRequestBody					The body of Http Request
 @param		TimeoutInterval					Timeout Interval
 @param		RequestCachePolicy				Request Cache Policy
 @param		HTTPRequestDelegate				The delegate of HTTP Request
 @param		StringEncoding					String Encoding
 @param		OnResponseReceivedEventHandler	The event handler of on Response received
 @param		OnDataReceivedEventHandler		The event handler of on Data received
 @param		OnFailWithErrorEventHandler		The event handler of error
 @param		StartImmediately				Start the request immediately?

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */

- (void) HttpRequest: (NSString *) url Certificate: (NSString *) certificate CertificateCredential: (NSString *) certificateCredential HttpMethod: (NSString *) httpMethod HTTPHeaderFields: (NSDictionary *) httpHeaderFields ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody TimeoutInterval: (NSTimeInterval) timeoutInterval HTTPRequestDelegate: (id) httpRequestDelegate StringEncoding: (NSStringEncoding) stringEncoding OnResponseReceivedEventHandler: (void (^) (NSURLConnection *connection, NSURLResponse *response)) onResponseReceivedEventHandler OnDataReceivedEventHandler: (void (^) (NSURLConnection *connection, NSData *data)) onDataReceivedEventHandler OnFailWithErrorEventHandler: (void (^) (NSURLConnection *connection, NSError *error)) onFailWithErrorEventHandler StartImmediately: (BOOL) startImmediately
{
	[self HttpRequest: url Certificate: certificate CertificateCredential: certificateCredential HttpMethod: httpMethod HTTPHeaderFields: httpHeaderFields ServiceContract: serviceContract WebMethod: webMethod HttpRequestBody: httpRequestBody TimeoutInterval: timeoutInterval RequestCachePolicy: NSURLRequestReloadIgnoringCacheData HTTPRequestDelegate: httpRequestDelegate StringEncoding: stringEncoding OnResponseReceivedEventHandler: onResponseReceivedEventHandler OnDataReceivedEventHandler: onDataReceivedEventHandler OnFailWithErrorEventHandler: onFailWithErrorEventHandler StartImmediately: startImmediately];
}

/*!
 Http request to the web server with Security Socket Layer.

 @param		url								URL address to send
 @param		Certificate						Certificate to access the server
 @param		CertificateCredential			Certificate Password
@param		HttpMethod						Http Method
 @param		HTTPHeaderFields				HTTP Request Header Fields
 @param		ServiceContract					The name of Service Contract
 @param		WebMethod						The Web Method
 @param		HttpRequestBody					The body of Http Request
 @param		RequestCachePolicy				Request Cache Policy
 @param		HTTPRequestDelegate				The delegate of HTTP Request
 @param		StringEncoding					String Encoding
 @param		OnResponseReceivedEventHandler	The event handler of on Response received
 @param		OnDataReceivedEventHandler		The event handler of on Data received
 @param		OnFailWithErrorEventHandler		The event handler of error
 @param		StartImmediately				Start the request immediately?

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */

- (void) HttpRequest: (NSString *) url Certificate: (NSString *) certificate CertificateCredential: (NSString *) certificateCredential HttpMethod: (NSString *) httpMethod HTTPHeaderFields: (NSDictionary *) httpHeaderFields ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody RequestCachePolicy: (NSURLRequestCachePolicy) requestCachePolicy HTTPRequestDelegate: (id) httpRequestDelegate StringEncoding: (NSStringEncoding) stringEncoding OnResponseReceivedEventHandler: (void (^) (NSURLConnection *connection, NSURLResponse *response)) onResponseReceivedEventHandler OnDataReceivedEventHandler: (void (^) (NSURLConnection *connection, NSData *data)) onDataReceivedEventHandler OnFailWithErrorEventHandler: (void (^) (NSURLConnection *connection, NSError *error)) onFailWithErrorEventHandler StartImmediately: (BOOL) startImmediately
{
	[self HttpRequest: url Certificate: certificate CertificateCredential: certificateCredential HttpMethod: httpMethod HTTPHeaderFields: httpHeaderFields ServiceContract: serviceContract WebMethod: webMethod HttpRequestBody: httpRequestBody TimeoutInterval: DEFAULT_TIMEOUT_THROTTLE RequestCachePolicy: requestCachePolicy HTTPRequestDelegate: httpRequestDelegate StringEncoding: stringEncoding OnResponseReceivedEventHandler: onResponseReceivedEventHandler OnDataReceivedEventHandler: onDataReceivedEventHandler OnFailWithErrorEventHandler: onFailWithErrorEventHandler StartImmediately: startImmediately];
}

/*!
 Http request to the web server with Security Socket Layer.

 @param		url								URL address to send
 @param		Certificate						Certificate to access the server
 @param		CertificateCredential			Certificate Password
 @param		HTTPHeaderFields				HTTP Request Header Fields
 @param		ServiceContract					The name of Service Contract
 @param		WebMethod						The Web Method
 @param		HttpRequestBody					The body of Http Request
 @param		TimeoutInterval					Timeout Interval
 @param		RequestCachePolicy				Request Cache Policy
 @param		HTTPRequestDelegate				The delegate of HTTP Request
 @param		StringEncoding					String Encoding
 @param		OnResponseReceivedEventHandler	The event handler of on Response received
 @param		OnDataReceivedEventHandler		The event handler of on Data received
 @param		OnFailWithErrorEventHandler		The event handler of error
 @param		StartImmediately				Start the request immediately?

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */

- (void) HttpRequest: (NSString *) url Certificate: (NSString *) certificate CertificateCredential: (NSString *) certificateCredential HTTPHeaderFields: (NSDictionary *) httpHeaderFields ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody TimeoutInterval: (NSTimeInterval) timeoutInterval RequestCachePolicy: (NSURLRequestCachePolicy) requestCachePolicy HTTPRequestDelegate: (id) httpRequestDelegate StringEncoding: (NSStringEncoding) stringEncoding OnResponseReceivedEventHandler: (void (^) (NSURLConnection *connection, NSURLResponse *response)) onResponseReceivedEventHandler OnDataReceivedEventHandler: (void (^) (NSURLConnection *connection, NSData *data)) onDataReceivedEventHandler OnFailWithErrorEventHandler: (void (^) (NSURLConnection *connection, NSError *error)) onFailWithErrorEventHandler StartImmediately: (BOOL) startImmediately
{
	[self HttpRequest: url Certificate: certificate CertificateCredential: certificateCredential HttpMethod: HTTP_METHOD_POST HTTPHeaderFields: httpHeaderFields ServiceContract: serviceContract WebMethod: webMethod HttpRequestBody: httpRequestBody TimeoutInterval: timeoutInterval RequestCachePolicy: requestCachePolicy HTTPRequestDelegate: httpRequestDelegate StringEncoding: stringEncoding OnResponseReceivedEventHandler: onResponseReceivedEventHandler OnDataReceivedEventHandler: onDataReceivedEventHandler OnFailWithErrorEventHandler: onFailWithErrorEventHandler StartImmediately: startImmediately];
}

/*!
 Http request to the web server with Security Socket Layer.

 @param		url								URL address to send
 @param		Certificate						Certificate to access the server
 @param		CertificateCredential			Certificate Password
 @param		HttpMethod						Http Method
 @param		HTTPHeaderFields				HTTP Request Header Fields
 @param		ServiceContract					The name of Service Contract
 @param		WebMethod						The Web Method
 @param		HttpRequestBody					The body of Http Request
 @param		TimeoutInterval					Timeout Interval
 @param		RequestCachePolicy				Request Cache Policy
 @param		HTTPRequestDelegate				The delegate of HTTP Request
 @param		StringEncoding					String Encoding
 @param		OnResponseReceivedEventHandler	The event handler of on Response received
 @param		OnDataReceivedEventHandler		The event handler of on Data received
 @param		OnFailWithErrorEventHandler		The event handler of error
 @param		StartImmediately				Start the request immediately?

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */

- (void) HttpRequest: (NSString *) url Certificate: (NSString *) certificate CertificateCredential: (NSString *) certificateCredential HttpMethod: (NSString *) httpMethod HTTPHeaderFields: (NSDictionary *) httpHeaderFields ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody TimeoutInterval: (NSTimeInterval) timeoutInterval RequestCachePolicy: (NSURLRequestCachePolicy) requestCachePolicy HTTPRequestDelegate: (id) httpRequestDelegate StringEncoding: (NSStringEncoding) stringEncoding OnResponseReceivedEventHandler: (void (^) (NSURLConnection *connection, NSURLResponse *response)) onResponseReceivedEventHandler OnDataReceivedEventHandler: (void (^) (NSURLConnection *connection, NSData *data)) onDataReceivedEventHandler OnFailWithErrorEventHandler: (void (^) (NSURLConnection *connection, NSError *error)) onFailWithErrorEventHandler StartImmediately: (BOOL) startImmediately
{
	if ([self.delegate respondsToSelector: @selector (onBeginWebHelperRequest)])
	{
		[self.delegate onBeginWebHelperRequest];
	}

	self.certificate				= certificate;
	self.certificateCredential		= certificateCredential;

	self.stringEncoding				= stringEncoding;
	self.onResponseReceived			= onResponseReceivedEventHandler;
	self.onDataReceived				= onDataReceivedEventHandler;
	self.onFailWithError			= onFailWithErrorEventHandler;

	url = [url stringByAddingPercentEscapesUsingEncoding: stringEncoding];

	NSMutableURLRequest *request	= [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: url] cachePolicy: requestCachePolicy timeoutInterval: timeoutInterval];

	request.HTTPShouldHandleCookies = YES;
	request.HTTPMethod				= httpMethod;

	//http://en.wikipedia.org/wiki/List_of_HTTP_header_fields
	[request setValue: KEEP_ALIVE forHTTPHeaderField: CONNECTION];
	[request setValue: DEFAULT_KEEP_ALIVE forHTTPHeaderField: KEEP_ALIVE];
	[request setValue: TEXT_XML forHTTPHeaderField: CONTENT_TYPE];
	NSString *soapActionValue		= [NSString stringWithFormat: SOAP_ACTION_VALUE, serviceContract, webMethod];
	[request setValue: soapActionValue forHTTPHeaderField: SOAP_ACTION_FIELD];

	[httpHeaderFields enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {

		[request addValue: key forHTTPHeaderField: key];
	}];

	if (httpRequestBody)
	{
		NSString *soapMessage		= [SERVICE_SOAP_MESSAGE_TEMPLATE stringByReplacingOccurrencesOfString: SOAP_METHOD_TEMPLATE withString: webMethod];

		//NSError *error;
		//NSData *xmlPresentation		= [NSPropertyListSerialization dataWithPropertyList: httpRequestBody format: NSPropertyListXMLFormat_v1_0 options: noErr error: &error];
		NSString *body				= [self dictionaryAsXmlPresentaion: httpRequestBody];

		soapMessage					= [soapMessage stringByReplacingOccurrencesOfString: SOAP_MESSAGE_TEMPLATE withString: body];
		
		NSData * data				= [soapMessage dataUsingEncoding: stringEncoding];
		NSString *length			= [NSString stringWithFormat: @"%tu", data.length];
		[request addValue: length forHTTPHeaderField: CONTENT_LENGTH];
		request.HTTPBody			= data;
	}

	NSURLConnection *connection		= [[NSURLConnection alloc] initWithRequest: request delegate:self startImmediately: startImmediately];

	if (startImmediately)
		[connection start];
}


- (void) connection:(NSURLConnection *) connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *) challenge
{
	NSString *authenticationMethod = challenge.protectionSpace.authenticationMethod;

	if ([authenticationMethod isEqualToString: NSURLAuthenticationMethodServerTrust])
	{
		[challenge.sender useCredential:[NSURLCredential credentialForTrust: challenge.protectionSpace.serverTrust] forAuthenticationChallenge: challenge];
	}
	else if ([authenticationMethod isEqualToString: NSURLAuthenticationMethodClientCertificate])
	{
		NSString *fileName	= self.certificate.lastPathComponent.stringByDeletingPathExtension;
		NSString *extension = self.certificate.pathExtension;
		NSString *path		= [[NSBundle mainBundle] pathForResource: fileName ofType: extension];
		NSData *pfxdata		= [NSData dataWithContentsOfFile:path];
		CFDataRef inPfxdata = (__bridge CFDataRef) pfxdata;
		SecIdentityRef identity;
		SecTrustRef trust;
		OSStatus status		= [self extractIdentityTrust: inPfxdata Identity: &identity Trust: &trust];

		if (status == noErr)
		{
			SecCertificateRef certificate;
			SecIdentityCopyCertificate (identity, &certificate);
			const void *certs[]			= { certificate };
			CFArrayRef array			= CFArrayCreate(NULL, certs, 1, NULL);
			NSURLCredential *credential = [NSURLCredential credentialWithIdentity: identity certificates: (__bridge NSArray *)(array) persistence: NSURLCredentialPersistencePermanent];

			[challenge.sender useCredential:credential forAuthenticationChallenge:challenge];

			CFRelease (certificate);
			CFRelease (array);
			CFRelease (identity);
		}
	}
	else if ([authenticationMethod isEqualToString: NSURLAuthenticationMethodNTLM])
	{
		if (challenge.previousFailureCount)
		{
			[challenge.sender cancelAuthenticationChallenge: challenge];
		}
		else
		{
			NSURLCredential *credential = [NSURLCredential credentialWithUser: self.userName password: self.password persistence: NSURLCredentialPersistencePermanent];
			[[challenge sender] useCredential: credential forAuthenticationChallenge: challenge];
		}
	}
	else
	{
		NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
		[challenge.sender useCredential: credential forAuthenticationChallenge:challenge];
		[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
	}

	[[challenge sender] performDefaultHandlingForAuthenticationChallenge:challenge];
}

- (void) connection: (NSURLConnection *) connection didReceiveResponse:(NSURLResponse *)response
{
	if (self.onResponseReceived)
	{
		self.onResponseReceived (connection, response);
	}

	if ([self.delegate respondsToSelector: @selector (onEndWebHelperRequest)])
	{
		[self.delegate onEndWebHelperRequest];
	}
}

- (void) connection:(NSURLConnection *)connection didReceiveData: (NSData *) data
{
	if (self.onDataReceived)
	{
		self.onDataReceived (connection, data);
	}

	if ([self.delegate respondsToSelector: @selector (onEndWebHelperRequest)])
	{
		[self.delegate onEndWebHelperRequest];
	}

}

- (void) connection: (NSURLConnection *) connection didFailWithError: (NSError *) error
{
	if (self.onFailWithError)
	{
		self.onFailWithError (connection, error);
	}

	if ([self.delegate respondsToSelector: @selector (onEndWebHelperRequest)])
	{
		[self.delegate onEndWebHelperRequest];
	}
}


#pragma mark - Helper Messages

//Extract Identity & Trust
- (OSStatus) extractIdentityTrust: (CFDataRef) inPfxData Identity: (SecIdentityRef *) identity Trust: (SecTrustRef *) trust
{
	OSStatus securityError	= errSecSuccess;
	CFStringRef password	= (__bridge CFStringRef)(self.certificateCredential);
	const void *keys[]		= { kSecImportExportPassphrase };
	const void *values[]	= { password };
	CFDictionaryRef options = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
	CFArrayRef items		= CFArrayCreate (NULL, 0, 0, NULL);
	securityError			= SecPKCS12Import (inPfxData, options, &items);
	if (!securityError)
	{
		CFDictionaryRef myIdentityAndTrust	= CFArrayGetValueAtIndex (items, 0);
		const void *tempIdentity			= NULL;
		tempIdentity						= CFDictionaryGetValue(myIdentityAndTrust, kSecImportItemIdentity);
		*identity							= (SecIdentityRef)tempIdentity;
		const void *tempTrust				= NULL;
		tempTrust							= CFDictionaryGetValue(myIdentityAndTrust, kSecImportItemTrust);
		*trust								= (SecTrustRef)tempTrust;
	}

	if (options)
	{
		CFRelease(options);
	}

	return securityError;
}

- (NSString*) dictionaryAsXmlPresentaion: (NSDictionary*) dictionary
{
	return [self dictionaryAsXmlPresentaion: dictionary StartElement: NSString.string];
}

- (NSString*) dictionaryAsXmlPresentaion: (NSDictionary*) dictionary StartElement: (NSString*) startElement
{
	return [self dictionaryAsXmlPresentaion: dictionary IncludeXmlVersion: NO StartElement: startElement];
}

- (NSString*) dictionaryAsXmlPresentaion: (NSDictionary*) dictionary IncludeXmlVersion: (BOOL) includeXmlVersion StartElement: (NSString*) startElement
{
	NSMutableString *xmlPresentation = [NSMutableString string];

	if (includeXmlVersion)
		[xmlPresentation appendString: XML_VERSION_1_0_ENCODING_UTF_8];

	if (startElement.length)
		[xmlPresentation appendFormat:@"<%@>",startElement];

	[dictionary enumerateKeysAndObjectsUsingBlock: ^(NSString *key, id obj, BOOL *stop) {

		[xmlPresentation appendFormat :@"<%@>", key];

		if([obj isKindOfClass: NSString.class])
		{
			[xmlPresentation appendFormat :@"%@",obj];
		}
		else if ([obj isKindOfClass: NSNumber.class])
			[xmlPresentation appendFormat: @"%@",obj];
		else if([obj isKindOfClass: NSArray.class])
		{
			if([obj count])
			{
				[obj enumerateObjectsUsingBlock: ^(id item, NSUInteger idx, BOOL *itemStop) {

					if([item isKindOfClass: NSString.class])
					{
						[xmlPresentation appendFormat :@"<%@ />",item];
					}
					else if ([item isKindOfClass: NSNumber.class])
						[xmlPresentation appendFormat: @"<%@ />",item];
					else if([item isKindOfClass: NSDictionary.class])
					{
						NSString *text = [self dictionaryAsXmlPresentaion: item];
						[xmlPresentation appendFormat :@"%@", text];
					}
				}];
			}
		}
		else if([obj isKindOfClass: NSDictionary.class])
		{
			NSString *text = [self dictionaryAsXmlPresentaion: obj];
			[xmlPresentation appendFormat :@"%@", text];
		}
		else
		{
			NSString *text = [self objectAsXmlPresentation: obj];
			[xmlPresentation appendFormat :@"%@", text];
		}

		[xmlPresentation appendFormat :@"</%@>", key];

	}];

	if (startElement.length)
		[xmlPresentation appendFormat:@"</%@>",startElement];

	return xmlPresentation;
}

- (NSString *) objectAsXmlPresentation: (id) object
{
	unsigned int numerOfProperties		= 0;
	objc_property_t * properties		= class_copyPropertyList ([object class], &numerOfProperties);

	NSMutableString *xmlPresentation	= [NSMutableString string];

	for (unsigned int i = 0; i < numerOfProperties; ++i)
	{
		objc_property_t property		= properties [i];
		const char * name				= property_getName (property);
		NSString *propertyName			= [[NSString alloc] initWithCString: name encoding: NSUTF8StringEncoding];

		id value = [object valueForKey: propertyName];

		if ([value isKindOfClass: NSString.class] ||
			[value isKindOfClass: NSNumber.class] ||
			[value isKindOfClass: NSDate.class] ||
			[value isKindOfClass: NSData.class])
		{
			[xmlPresentation appendFormat: @"<%@>%@</%@>", propertyName, value, propertyName];
		}
		else
		{
			NSString *text = [self objectAsXmlPresentation: value];
			[xmlPresentation appendFormat :@"<%@>%@</%@>", propertyName, text, propertyName];
		}
	}

	free (properties);

	return xmlPresentation;
}

- (NSString *) mimeTypeForPath: (NSString *) path
{
	// get a mime type for an extension using MobileCoreServices.framework

	CFStringRef extension	= (__bridge CFStringRef)	[path pathExtension];
	CFStringRef UTI			= UTTypeCreatePreferredIdentifierForTag (kUTTagClassFilenameExtension, extension, NULL);

	assert (UTI != NULL);

	NSString *mimetype = CFBridgingRelease (UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType));

	assert (mimetype != NULL);

	CFRelease (UTI);

	return mimetype;
}

- (NSString *) boundary
{
	return [self rand: DEFAULT_BOUNDARY_LENGTH];
}

- (NSString *) rand: (NSInteger) length
{
	NSMutableString *string = [NSMutableString stringWithCapacity: length];

	for (NSInteger i = 0; i < length; i++)
		[string appendFormat:@"%C", (unichar) ('a' + (NSUInteger) arc4random_uniform(25))];

	return string;
}

/*
 Then submit the request. There are many, many options here.

 For example, if using NSURLSession:

 @property (nonatomic, strong) NSURLSession *session;
 You could create NSURLSessionUploadTask:

 self.session = [NSURLSession sharedSession];  // use sharedSession or create your own

 NSURLSessionTask *task = [self.session uploadTaskWithRequest:request fromData:httpBody completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
 if (error) {
 NSLog(@"error = %@", error);
 return;
 }

 NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
 NSLog(@"result = %@", result);
 }];
 [task resume];
 Or you could create a NSURLSessionDataTask:

 request.HTTPBody = httpBody;

 NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
 if (error) {
 NSLog(@"error = %@", error);
 return;
 }

 NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
 NSLog(@"result = %@", result);
 }];
 [task resume];
 Or, if using NSURLConnection:

 request.HTTPBody = httpBody;

 [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
 if (connectionError) {
 NSLog(@"error = %@", connectionError);
 return;
 }

 NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
 NSLog(@"result = %@", result);
 }];
 The above assumes that the server is just returning text response. It's better if the server returned JSON, in which case you'd use NSJSONSerialization rather than NSString method initWithData.

 Likewise, I'm using the completion block renditions of NSURLSession/NSURLConnection above, but feel free to use the richer delegate-based renditions, too. But that seems beyond the scope of this question, so I'll leave that to you.

 But hopefully this illustrates the idea.

 I'd be remiss if I didn't point that, much easier than the above, you can use AFNetworking, repeating steps 1 and 2 above, but then just calling:

 self.operationManager = [AFHTTPRequestOperationManager manager];
 self.operationManager.responseSerializer = [AFHTTPResponseSerializer serializer]; // only needed if the server is not returning JSON; if web service returns JSON, remove this line
 AFHTTPRequestOperation *operation = [self.operationManager POST:urlString parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
 NSError *error;
 if (![formData appendPartWithFileURL:[NSURL fileURLWithPath:path] name:@"avatar" fileName:[path lastPathComponent] mimeType:@"image/png" error:&error]) {
 NSLog(@"error appending part: %@", error);
 }
 } success:^(AFHTTPRequestOperation *operation, id responseObject) {
 NSLog(@"responseObject = %@", responseObject);
 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
 NSLog(@"error = %@", error);
 }];

 if (!operation) {
 NSLog(@"Creation of operation failed.");
 }
 Where operationManager is defined as a AFHTTPRequestOperationManager:

 @property (nonatomic, strong) AFHTTPRequestOperationManager *operationManager;
 */

@end
