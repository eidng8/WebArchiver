/*
 * MIT License
 *
 *  Created by Jackey Cheung.
 *  Copyright (c) 2014 Guanghzou Tianao Internet Technology Co. Ltd.
 */
/*
 * Copyright (c) 2011 Shun Takebayashi
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#import <objc/runtime.h>
#import <libxml/xpath.h>
#import <libxml/HTMLparser.h>
#import "AFNetworking.h"
#import "STWebArchiver+AFNetworking.h"



#pragma mark -
@implementation STWebArchiver (AFNetworking)


#pragma mark -- Public methods

- (void)webarchiveForHTMLData:(NSData *)htmlData
                 textEncoding:(NSString *)textEncoding
                      baseURL:(NSURL *)baseURL
            requestSerializer:(AFHTTPRequestSerializer*)requestSerializer
                  filterBlock:(BOOL(^)(NSURL*))filter
                progressBlock:(void (^)(NSUInteger, NSUInteger))progress
              completionBlock:(void (^)(NSData*))completion
                  failurBlock:(void(^)(AFHTTPRequestOperation*, NSError*))failure;
{
  if(nil == htmlData)
    [NSException raise:NSInvalidArgumentException format:@"%@", @"Data must not be nil."];

  // Parse the data inot HTML document.
  // This document will be freed when everything has been downloaded.
	htmlDocPtr doc = htmlParseDoc((xmlChar *)[htmlData bytes], [textEncoding UTF8String]);

  // get a list of all used URL in the page
  /** List of all used URL in a page */
  NSArray *resourceUrls = [self absoluteURLsForPaths:[[self valueForAttributeName:@"src" withEvaluatingXPath:@"//script[@src]|//img[@src]" inDocument:doc] arrayByAddingObjectsFromArray:[self valueForAttributeName:@"href" withEvaluatingXPath:@"//link[@rel='stylesheet'][@href]" inDocument:doc]] baseURL:baseURL];
  /** List of all used resources' actual content of the page. */
  NSMutableDictionary *resources = [[NSMutableDictionary alloc] init];

  // Queues all resource URL
  NSError *error;
  AFHTTPRequestOperation *task;
  NSMutableArray *mutableOperations = [NSMutableArray array];
  for(NSURL *url in resourceUrls)
  {
    // asks the filter block, if given, whether the URL shall be downloaded.
    if(nil != filter && NO == filter(url))
    {
      NSMutableDictionary *resourceArchive = [NSMutableDictionary dictionaryWithObjectsAndKeys:url.absoluteString, @"WebResourceURL", @"html/text", @"WebResourceMIMEType", @"", @"WebResourceData", @"UTF-8", @"WebResourceTextEncodingName", nil];
      @synchronized(resources)
      {
        [resources setObject:resourceArchive forKey:url.absoluteString];
      }
    }
    else
    {
      // create a download task for the current resource URL
      if(nil != requestSerializer)
        task = [[AFHTTPRequestOperation alloc] initWithRequest:[requestSerializer requestWithMethod:@"GET" URLString:[url absoluteString] parameters:nil error:&error]];
      else
        task = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:url]];
      // task completion block
      [task setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // One operation has finished successfully
        NSMutableDictionary *resourceArchive =
        [NSMutableDictionary
         dictionaryWithObjectsAndKeys:
         operation.request.URL.absoluteString, @"WebResourceURL",
         [operation.response MIMEType], @"WebResourceMIMEType",
         responseObject, @"WebResourceData", nil];
        if([operation.response textEncodingName])
        {
          [resourceArchive setObject:[operation.response textEncodingName] forKey:@"WebResourceTextEncodingName"];
        }
        @synchronized(resources)
        {
          [resources setObject:resourceArchive
                        forKey:operation.request.URL.absoluteString];
        }
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // One operation has failed
        if(failure)
          failure(operation, error);
      }];
      // add the operation to array
      [mutableOperations addObject:task];
    }
  }

  // Use operation queue instead of GCD
  NSArray *operations = [AFURLConnectionOperation batchOfRequestOperations:mutableOperations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
    // one operation has finished
    if(nil != progress)
      progress(numberOfFinishedOperations, totalNumberOfOperations);
  } completionBlock:^(NSArray *operations) {
    // entire queue has finished
    // restructure everything for archiving
		NSMutableDictionary *archiveSource = [NSMutableDictionary dictionaryWithObject:[resources allValues] forKey:@"WebSubresources"];
		NSMutableDictionary *mainResource = [[NSMutableDictionary alloc] init];
		[mainResource setObject:htmlData forKey:@"WebResourceData"];
		[mainResource setObject:@"" forKey:@"WebResourceFrameName"];
		[mainResource setObject:@"text/html" forKey:@"WebResourceMIMEType"];
		[mainResource setObject:textEncoding forKey:@"WebResourceTextEncodingName"];
		[mainResource setObject:[baseURL absoluteString] forKey:@"WebResourceURL"];
		[archiveSource setObject:mainResource forKey:@"WebMainResource"];
		NSData *webArchive = [NSPropertyListSerialization
                          dataFromPropertyList:archiveSource
                          format:NSPropertyListBinaryFormat_v1_0
                          errorDescription:NULL];
    // invote the pass-in completion block
    if(nil != completion)
      completion(webArchive);
    // don't forget to free the HTML document.
    xmlFreeDoc(doc);
  }];

  // add to operation queue
  [[NSOperationQueue mainQueue] addOperations:operations waitUntilFinished:NO];
}

@end
