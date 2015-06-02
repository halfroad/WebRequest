//
//  WebHelper.h
//  iStadium
//
//  Created by Jinhui Li on 12/28/14.
//  Copyright (c) 2014 Half Road Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WebHelperDelegate <NSObject>

@required

@optional

- (void) onWebHelperRequestError: (NSError *) error;

- (void) onBeginWebHelperRequest;
- (void) onEndWebHelperRequest;

@end



@interface WebHelper : NSObject <NSURLConnectionDelegate>

@property (strong, nonatomic) id <WebHelperDelegate> delegate;

+ (WebHelper *) sharedInstance : (id <WebHelperDelegate>) delegate;
+ (WebHelper *) sharedInstance : (id <WebHelperDelegate>) delegate UserName: (NSString *) userName Password: (NSString *) password;

/*!
 Http Request to the web server.

 @param		url						URL address to send
 @param		HttpResponseContent		The content of Http response.

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */
- (NSDictionary *) httpRequest:(NSString *) url HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent;

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
- (NSDictionary *) httpRequest:(NSString *) url HttpRequestBody: (id) httpRequestBody HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent;

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
- (NSDictionary *) httpRequest: (NSString *) url HttpRequestBody: (id) httpRequestBody StringEncoding: (NSStringEncoding) stringEncoding HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent;

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
- (NSDictionary *) httpRequest:(NSString *) url HttpMethod: (NSString *) httpMethod HttpRequestBody: (id) httpRequestBody HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent;

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
- (NSDictionary *) httpRequest: (NSString *) url HttpMethod: (NSString *) httpMethod HttpRequestBody: (id) httpRequestBody StringEncoding: (NSStringEncoding) stringEncoding HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent;

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
- (NSDictionary *) httpRequest: (NSString *) url HTTPHeaderFields: (NSDictionary *) httpHeaderFields HttpRequestBody: (id) httpRequestBody HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent;

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
- (NSDictionary *) httpRequest: (NSString *) url HTTPHeaderFields: (NSDictionary *) httpHeaderFields HttpRequestBody: (id) httpRequestBody StringEncoding: (NSStringEncoding) stringEncoding HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent;

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
- (NSDictionary *) httpRequest: (NSString *) url HttpMethod: (NSString *) httpMethod HTTPHeaderFields: (NSDictionary *) httpHeaderFields EnableCookieStorage: (BOOL) enableCookieStorage HttpRequestBody: (id) httpRequestBody HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent;

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
- (NSDictionary *) httpRequest: (NSString *) url HttpMethod: (NSString *) httpMethod HTTPHeaderFields: (NSDictionary *) httpHeaderFields HttpRequestBody: (id) httpRequestBody StringEncoding: (NSStringEncoding) stringEncoding HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent;

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
 @param		HTTPRequestCompletionHandler	HTTP request completion event handler
 @param		HttpResponse					Http Response
 @param		HttpResponseContent				The content of Http response

 @result
 The dictionary returns from http response.

 @discussion
 This is an example.
 */
- (NSDictionary *) httpRequest: (NSString *) url HttpMethod: (NSString *) httpMethod HTTPHeaderFields: (NSDictionary *) httpHeaderFields EnableCookieStorage: (BOOL) enableCookieStorage HttpRequestBody: (id) httpRequestBody TimeoutInterval: (NSTimeInterval) timeoutInterval RequestCachePolicy: (NSURLRequestCachePolicy) requestCachePolicy UseAsynchronous: (BOOL) useAsynchronous HTTPRequestDelegate: (id) httpRequestDelegate StringEncoding: (NSStringEncoding) stringEncoding HTTPRequestCompletionHandler: (void (^) (NSURLResponse *, NSData *, NSError *)) onHTTPRequestCompletionHandler HttpResponse: (NSHTTPURLResponse *__autoreleasing *) httpResponse HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent;

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
- (NSDictionary *) httpRequest: (NSString *) url WebFormParameters: (id) webFormParameters WebFormPostFiles: (id) webFormPostFiles HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent;

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
- (NSDictionary *) httpRequest: (NSString *) url HTTPHeaderFields: (NSDictionary *) httpHeaderFields Boundary: (NSString *) boundary WebFormParameters: (id) webFormParameters WebFormPostFiles: (id) webFormPostFiles HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent;

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
- (NSDictionary *) httpRequest: (NSString *) url Boundary: (NSString *) boundary WebFormParameters: (id) webFormParameters WebFormPostFiles: (id) webFormPostFiles StringEncoding: (NSStringEncoding) stringEncoding HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent;

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
- (NSDictionary *) httpRequest: (NSString *) url HTTPHeaderFields: (NSDictionary *) httpHeaderFields Boundary: (NSString *) boundary WebFormParameters: (id) webFormParameters WebFormPostFiles: (id) webFormPostFiles StringEncoding: (NSStringEncoding) stringEncoding HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent;

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
- (NSDictionary *) httpRequest: (NSString *) url HTTPHeaderFields: (NSDictionary *) httpHeaderFields EnableCookieStorage: (BOOL) enableCookieStorage Boundary: (NSString *) boundary WebFormParameters: (id) webFormParameters WebFormPostFiles: (id) webFormPostFiles TimeoutInterval: (NSTimeInterval) timeoutInterval RequestCachePolicy: (NSURLRequestCachePolicy) requestCachePolicy UseAsynchronous: (BOOL) useAsynchronous HTTPRequestDelegate: (id) httpRequestDelegate StringEncoding: (NSStringEncoding) stringEncoding HTTPRequestCompletionHandler: (void (^) (NSURLResponse *, NSData *, NSError *)) onHTTPRequestCompletionHandler HttpResponse: (NSHTTPURLResponse *__autoreleasing *) httpResponse HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent;

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
- (NSDictionary *) httpRequest: (NSString *) url ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent;

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
- (NSDictionary *) httpRequest: (NSString *) url HttpMethod: (NSString *) httpMethod ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent;

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
- (NSDictionary *) httpRequest: (NSString *) url HTTPHeaderFields: (NSDictionary *) httpHeaderFields ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent;

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
- (NSDictionary *) httpRequest: (NSString *) url HttpMethod: (NSString *) httpMethod HTTPHeaderFields: (NSDictionary *) httpHeaderFields ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent;

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
- (NSDictionary *) httpRequest: (NSString *) url HttpMethod: (NSString *) httpMethod HTTPHeaderFields: (NSDictionary *) httpHeaderFields ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody HttpResponse: (NSHTTPURLResponse *__autoreleasing *) httpResponse HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent;

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
- (NSDictionary *) httpRequest: (NSString *) url HttpMethod: (NSString *) httpMethod HTTPHeaderFields: (NSDictionary *) httpHeaderFields ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody HTTPRequestCompletionHandler: (void (^) (NSURLResponse *, NSData *, NSError *)) onHTTPRequestCompletionHandler HttpResponse: (NSHTTPURLResponse *__autoreleasing *) httpResponse HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent;

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
- (NSDictionary *) httpRequest: (NSString *) url HttpMethod: (NSString *) httpMethod HTTPHeaderFields: (NSDictionary *) httpHeaderFields ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody StringEncoding: (NSStringEncoding) stringEncoding HTTPRequestCompletionHandler: (void (^) (NSURLResponse *, NSData *, NSError *)) onHTTPRequestCompletionHandler HttpResponse: (NSHTTPURLResponse *__autoreleasing *) httpResponse HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent;

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
- (NSDictionary *) httpRequest: (NSString *) url HttpMethod: (NSString *) httpMethod HTTPHeaderFields: (NSDictionary *) httpHeaderFields ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody HTTPRequestDelegate: (id) httpRequestDelegate StringEncoding: (NSStringEncoding) stringEncoding HTTPRequestCompletionHandler: (void (^) (NSURLResponse *, NSData *, NSError *)) onHTTPRequestCompletionHandler HttpResponse: (NSHTTPURLResponse *__autoreleasing *) httpResponse HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent;

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
- (NSDictionary *) httpRequest: (NSString *) url HttpMethod: (NSString *) httpMethod HTTPHeaderFields: (NSDictionary *) httpHeaderFields ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody UseAsynchronous: (BOOL) useAsynchronous HTTPRequestDelegate: (id) httpRequestDelegate StringEncoding: (NSStringEncoding) stringEncoding HTTPRequestCompletionHandler: (void (^) (NSURLResponse *, NSData *, NSError *)) onHTTPRequestCompletionHandler HttpResponse: (NSHTTPURLResponse *__autoreleasing *) httpResponse HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent;

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
- (NSDictionary *) httpRequest: (NSString *) url HttpMethod: (NSString *) httpMethod HTTPHeaderFields: (NSDictionary *) httpHeaderFields ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody TimeoutInterval: (NSTimeInterval) timeoutInterval RequestCachePolicy: (NSURLRequestCachePolicy) requestCachePolicy UseAsynchronous: (BOOL) useAsynchronous HTTPRequestDelegate: (id) httpRequestDelegate StringEncoding: (NSStringEncoding) stringEncoding HTTPRequestCompletionHandler: (void (^) (NSURLResponse *, NSData *, NSError *)) onHTTPRequestCompletionHandler HttpResponse: (NSHTTPURLResponse *__autoreleasing *) httpResponse HttpResponseContent: (NSString *__autoreleasing *) httpResponseContent;

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

- (void) HttpRequest: (NSString *) url Certificate: (NSString *) certificate CertificateCredential: (NSString *) certificateCredential ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody OnDataReceivedEventHandler: (void (^) (NSURLConnection *connection, NSData *data)) onDataReceivedEventHandler OnFailWithErrorEventHandler: (void (^) (NSURLConnection *connection, NSError *error)) onFailWithErrorEventHandler;

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

- (void) HttpRequest: (NSString *) url Certificate: (NSString *) certificate CertificateCredential: (NSString *) certificateCredential ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody OnResponseReceivedEventHandler: (void (^) (NSURLConnection *, NSURLResponse *)) onResponseReceivedEventHandler OnDataReceivedEventHandler: (void (^) (NSURLConnection *, NSData * )) onDataReceivedEventHandler OnFailWithErrorEventHandler: (void (^) (NSURLConnection *, NSError *)) onFailWithErrorEventHandler;

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

- (void) HttpRequest: (NSString *) url Certificate: (NSString *) certificate CertificateCredential: (NSString *) certificateCredential ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody OnResponseReceivedEventHandler: (void (^) (NSURLConnection *, NSURLResponse *)) onResponseReceivedEventHandler OnDataReceivedEventHandler: (void (^) (NSURLConnection *, NSData * )) onDataReceivedEventHandler OnFailWithErrorEventHandler: (void (^) (NSURLConnection *, NSError *)) onFailWithErrorEventHandler StartImmediately: (BOOL) startImmediately;
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

- (void) HttpRequest: (NSString *) url Certificate: (NSString *) certificate CertificateCredential: (NSString *) certificateCredential HTTPHeaderFields: (NSDictionary *) httpHeaderFields ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody OnResponseReceivedEventHandler: (void (^) (NSURLConnection *, NSURLResponse *)) onResponseReceivedEventHandler OnDataReceivedEventHandler: (void (^) (NSURLConnection *, NSData * )) onDataReceivedEventHandler OnFailWithErrorEventHandler: (void (^) (NSURLConnection *, NSError *)) onFailWithErrorEventHandler StartImmediately: (BOOL) startImmediately;

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

- (void) HttpRequest: (NSString *) url Certificate: (NSString *) certificate CertificateCredential: (NSString *) certificateCredential HTTPHeaderFields: (NSDictionary *) httpHeaderFields ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody HTTPRequestDelegate: (id) httpRequestDelegate OnResponseReceivedEventHandler: (void (^) (NSURLConnection *, NSURLResponse *)) onResponseReceivedEventHandler OnDataReceivedEventHandler: (void (^) (NSURLConnection *, NSData * )) onDataReceivedEventHandler OnFailWithErrorEventHandler: (void (^) (NSURLConnection *, NSError *)) onFailWithErrorEventHandler StartImmediately: (BOOL) startImmediately;

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

- (void) HttpRequest: (NSString *) url Certificate: (NSString *) certificate CertificateCredential: (NSString *) certificateCredential HTTPHeaderFields: (NSDictionary *) httpHeaderFields ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody RequestCachePolicy: (NSURLRequestCachePolicy) requestCachePolicy HTTPRequestDelegate: (id) httpRequestDelegate OnResponseReceivedEventHandler: (void (^) (NSURLConnection *, NSURLResponse *)) onResponseReceivedEventHandler OnDataReceivedEventHandler: (void (^) (NSURLConnection *, NSData * )) onDataReceivedEventHandler OnFailWithErrorEventHandler: (void (^) (NSURLConnection *, NSError *)) onFailWithErrorEventHandler StartImmediately: (BOOL) startImmediately;

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

- (void) HttpRequest: (NSString *) url Certificate: (NSString *) certificate CertificateCredential: (NSString *) certificateCredential HTTPHeaderFields: (NSDictionary *) httpHeaderFields ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody TimeoutInterval: (NSTimeInterval) timeoutInterval RequestCachePolicy: (NSURLRequestCachePolicy) requestCachePolicy HTTPRequestDelegate: (id) httpRequestDelegate OnResponseReceivedEventHandler: (void (^) (NSURLConnection *, NSURLResponse *)) onResponseReceivedEventHandler OnDataReceivedEventHandler: (void (^) (NSURLConnection *, NSData * )) onDataReceivedEventHandler OnFailWithErrorEventHandler: (void (^) (NSURLConnection *, NSError *)) onFailWithErrorEventHandler StartImmediately: (BOOL) startImmediately;

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

- (void) HttpRequest: (NSString *) url Certificate: (NSString *) certificate CertificateCredential: (NSString *) certificateCredential HttpMethod: (NSString *) httpMethod HTTPHeaderFields: (NSDictionary *) httpHeaderFields ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody TimeoutInterval: (NSTimeInterval) timeoutInterval RequestCachePolicy: (NSURLRequestCachePolicy) requestCachePolicy HTTPRequestDelegate: (id) httpRequestDelegate OnResponseReceivedEventHandler: (void (^) (NSURLConnection *, NSURLResponse *)) onResponseReceivedEventHandler OnDataReceivedEventHandler: (void (^) (NSURLConnection *, NSData * )) onDataReceivedEventHandler OnFailWithErrorEventHandler: (void (^) (NSURLConnection *, NSError *)) onFailWithErrorEventHandler StartImmediately: (BOOL) startImmediately;

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

- (void) HttpRequest: (NSString *) url Certificate: (NSString *) certificate CertificateCredential: (NSString *) certificateCredential HttpMethod: (NSString *) httpMethod HTTPHeaderFields: (NSDictionary *) httpHeaderFields ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody TimeoutInterval: (NSTimeInterval) timeoutInterval RequestCachePolicy: (NSURLRequestCachePolicy) requestCachePolicy StringEncoding: (NSStringEncoding) stringEncoding OnResponseReceivedEventHandler: (void (^) (NSURLConnection *, NSURLResponse *)) onResponseReceivedEventHandler OnDataReceivedEventHandler: (void (^) (NSURLConnection *, NSData * )) onDataReceivedEventHandler OnFailWithErrorEventHandler: (void (^) (NSURLConnection *, NSError *)) onFailWithErrorEventHandler StartImmediately: (BOOL) startImmediately;

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

- (void) HttpRequest: (NSString *) url Certificate: (NSString *) certificate CertificateCredential: (NSString *) certificateCredential HttpMethod: (NSString *) httpMethod HTTPHeaderFields: (NSDictionary *) httpHeaderFields ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody TimeoutInterval: (NSTimeInterval) timeoutInterval HTTPRequestDelegate: (id) httpRequestDelegate StringEncoding: (NSStringEncoding) stringEncoding OnResponseReceivedEventHandler: (void (^) (NSURLConnection *, NSURLResponse *)) onResponseReceivedEventHandler OnDataReceivedEventHandler: (void (^) (NSURLConnection *, NSData * )) onDataReceivedEventHandler OnFailWithErrorEventHandler: (void (^) (NSURLConnection *, NSError *)) onFailWithErrorEventHandler StartImmediately: (BOOL) startImmediately;

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

- (void) HttpRequest: (NSString *) url Certificate: (NSString *) certificate CertificateCredential: (NSString *) certificateCredential HttpMethod: (NSString *) httpMethod HTTPHeaderFields: (NSDictionary *) httpHeaderFields ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody RequestCachePolicy: (NSURLRequestCachePolicy) requestCachePolicy HTTPRequestDelegate: (id) httpRequestDelegate StringEncoding: (NSStringEncoding) stringEncoding OnResponseReceivedEventHandler: (void (^) (NSURLConnection *, NSURLResponse *)) onResponseReceivedEventHandler OnDataReceivedEventHandler: (void (^) (NSURLConnection *, NSData * )) onDataReceivedEventHandler OnFailWithErrorEventHandler: (void (^) (NSURLConnection *, NSError *)) onFailWithErrorEventHandler StartImmediately: (BOOL) startImmediately;

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

- (void) HttpRequest: (NSString *) url Certificate: (NSString *) certificate CertificateCredential: (NSString *) certificateCredential HTTPHeaderFields: (NSDictionary *) httpHeaderFields ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody TimeoutInterval: (NSTimeInterval) timeoutInterval RequestCachePolicy: (NSURLRequestCachePolicy) requestCachePolicy HTTPRequestDelegate: (id) httpRequestDelegate StringEncoding: (NSStringEncoding) stringEncoding OnResponseReceivedEventHandler: (void (^) (NSURLConnection *, NSURLResponse *)) onResponseReceivedEventHandler OnDataReceivedEventHandler: (void (^) (NSURLConnection *, NSData * )) onDataReceivedEventHandler OnFailWithErrorEventHandler: (void (^) (NSURLConnection *, NSError *)) onFailWithErrorEventHandler StartImmediately: (BOOL) startImmediately;

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

- (void) HttpRequest: (NSString *) url Certificate: (NSString *) certificate CertificateCredential: (NSString *) certificateCredential HttpMethod: (NSString *) httpMethod HTTPHeaderFields: (NSDictionary *) httpHeaderFields ServiceContract: (NSString *) serviceContract WebMethod: (NSString *) webMethod HttpRequestBody: (NSDictionary *) httpRequestBody TimeoutInterval: (NSTimeInterval) timeoutInterval RequestCachePolicy: (NSURLRequestCachePolicy) requestCachePolicy HTTPRequestDelegate: (id) httpRequestDelegate StringEncoding: (NSStringEncoding) stringEncoding OnResponseReceivedEventHandler: (void (^) (NSURLConnection *, NSURLResponse *)) onResponseReceivedEventHandler OnDataReceivedEventHandler: (void (^) (NSURLConnection *, NSData * )) onDataReceivedEventHandler OnFailWithErrorEventHandler: (void (^) (NSURLConnection *, NSError *)) onFailWithErrorEventHandler StartImmediately: (BOOL) startImmediately;

@end
