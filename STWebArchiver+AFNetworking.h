/*
 * @header STWebArchiver
 *  Created by Jackey Cheung.
 *  Copyright (c) 2014 Guanghzou Tianao Internet Technology Co. Ltd.
 *
 * @copyright MIT License
 *
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

#import <Foundation/Foundation.h>

#import "STWebArchiver.h"


/**
 *  @brief Extends functionality of STWebArchiver with AFNetworking
 */
@interface STWebArchiver (AFNetworking)

/**
 * Downloads all used resource of a web page, and save to local storage.
 *
 * @param aData The HTML page to be saved. Please note that this is the entire
 *              data of the page, not the URL to it.
 * @param anEncoding The character encoding used to process page data.
 * @param anURL The base URL of relative links in the page.
 * @param requestSerializer The request serializer to generate requests
 * @param filterBlock A block to determine if the URL shall be downloaded. Returns NO if the given URL shall not be downloaded. An empty string will be associated with such URL.
 * @param progress The block function to be called when downloading has progress.
 * @param completion The block function that will be called after the page is saved.
 * @param failure The block function to be called when error occurred during downloading.
 */
- (void)webarchiveForHTMLData:(NSData *)aData
                 textEncoding:(NSString *)anEncoding
                      baseURL:(NSURL *)anURL
            requestSerializer:(AFHTTPRequestSerializer*)requestSerializer
                  filterBlock:(BOOL(^)(NSURL*))filter
                progressBlock:(void(^)(NSUInteger, NSUInteger))progress
              completionBlock:(void(^)(NSData*))completion
                  failurBlock:(void(^)(AFHTTPRequestOperation*, NSError*))failure;

@end
