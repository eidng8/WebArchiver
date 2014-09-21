// 
// Copyright (c) 2011 Shun Takebayashi
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// 

#import <Foundation/Foundation.h>
#import <libxml/xpath.h>


@interface STWebArchiver : NSObject
{
}


/**
 *  Download everything necessary for archiving the given daat.
 *
 *  @param aData      Page data
 *  @param anEncoding Character encoding used in the page
 *  @param anURL      Base URL to resolve relative links
 *  @param completion The block to be executed when downloading finishes.
 */
- (void)archiveHTMLData:(NSData *)aData
		   textEncoding:(NSString *)anEncoding
				baseURL:(NSURL *)anURL
        completionBlock:(void (^)(NSData *))completion;

/**
 * Looks for values of specified attributes
 *
 * @param attributeName The attribute to search for.
 * @param xpathExpression The XPath expression used to extract elements.
 * @param document The document to be searched.
 * @return Array of attribute values.
 */
- (NSArray *)valueForAttributeName:(NSString *)attributeName
               withEvaluatingXPath:(NSString *)xpathExpression
                        inDocument:(xmlDocPtr)document;

/**
 * Converts all resrouce paths into absolute path
 *
 * @param paths Array of NSString, of all resources paths.
 * @param base The base URL.
 * @return Array of NSURL, of all resource absolute paths.
 */
- (NSArray *)absoluteURLsForPaths:(NSArray *)paths baseURL:(NSURL *)base;

@end
