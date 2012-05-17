//
//  VILoaderImageView.m
//  LoaderImageView
//
//  Created by Anthony Alesia on 5/17/12.
//  Copyright (c) 2012 VOKAL. All rights reserved.
//

#import "VILoaderImageView.h"

#define TMP NSTemporaryDirectory()

@interface VILoaderImageView ()

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

+ (UIImage *)getCachedImage:(NSString *)imageURLString;
+ (void)cacheImage:(NSString *)imageURLString completion:(void (^)(UIImage *image))completion;
@end

@implementation VILoaderImageView

@synthesize activityIndicator = _activityIndicator;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame imageUrl:(NSString *)imageUrl
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
        
        UIImage *image = [VILoaderImageView getCachedImage:imageUrl];
        
        if (image != nil) {
            self.image = image;
        } else {
            _activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 
                                                                                           self.frame.size.width,
                                                                                           self.frame.size.height)];
            _activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
            [_activityIndicator startAnimating];
            [self addSubview:_activityIndicator];
            
            [VILoaderImageView cacheImage:imageUrl completion:^(UIImage *image) {
                [_activityIndicator stopAnimating];
                [_activityIndicator removeFromSuperview];
                _activityIndicator = nil;
                
                self.image = image;
            }];
        }
    }
    return self;
}

+ (void)cacheImage:(NSString *)imageURLString completion:(void (^)(UIImage *image))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSURL *imageURL = [NSURL URLWithString:imageURLString];
        
        // Generate a unique path to a resource representing the image you want
        NSString *filename = [[imageURLString stringByReplacingOccurrencesOfString:@":" withString:@""]
                              stringByReplacingOccurrencesOfString:@"/" withString:@""];
        
        NSString *uniquePath = [TMP stringByAppendingPathComponent:filename];
        UIImage *image = nil;
        
        // Check for file existence
        if(![[NSFileManager defaultManager] fileExistsAtPath:uniquePath])
        {
            NSData *data = [[NSData alloc] initWithContentsOfURL:imageURL];
            image = [[UIImage alloc] initWithData: data];
            
            if([imageURLString rangeOfString:@".jpg" options:NSCaseInsensitiveSearch].location != NSNotFound || 
               [imageURLString rangeOfString:@".jpeg" options:NSCaseInsensitiveSearch].location != NSNotFound
               ) {
                [UIImageJPEGRepresentation(image, 100) writeToFile: uniquePath atomically: YES];
            } else {
                [UIImagePNGRepresentation(image) writeToFile: uniquePath atomically: YES];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(image);
        });
    });
}

+ (UIImage *)getCachedImage:(NSString *)imageURLString
{
    NSString *filename = [[imageURLString stringByReplacingOccurrencesOfString:@":" withString:@""]
                          stringByReplacingOccurrencesOfString:@"/" withString:@""];
    
    NSString *uniquePath = [TMP stringByAppendingPathComponent: filename];
    
    UIImage *image = nil;
    
    // Check for a cached version
    if([[NSFileManager defaultManager] fileExistsAtPath: uniquePath]) {
        image = [UIImage imageWithContentsOfFile: uniquePath]; // this is the cached image
    }
	
    return image;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end