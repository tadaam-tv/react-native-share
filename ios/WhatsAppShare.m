//
//  FacebookShare.m
//  RNShare
//
//  Created by Diseño Uno BBCL on 23-07-16.
//  Copyright © 2016 Facebook. All rights reserved.
//

#import "WhatsAppShare.h"

@implementation WhatsAppShare
RCT_EXPORT_MODULE();

#if !TARGET_OS_TV
static UIDocumentInteractionController *documentInteractionController;

- (void)shareSingle:(NSDictionary *)options
    failureCallback:(RCTResponseErrorBlock)failureCallback
    successCallback:(RCTResponseSenderBlock)successCallback {

    NSLog(@"Try open view");

    if ([options objectForKey:@"message"] && [options objectForKey:@"message"] != [NSNull null]) {
        NSString *text = [RCTConvert NSString:options[@"message"]];
        text = [text stringByAppendingString: [@" " stringByAppendingString: options[@"url"]] ];
        NSString *whatsAppNumber = [RCTConvert NSString:options[@"whatsAppNumber"]];

        if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"whatsapp://app"]]) {
            NSLog(@"WhatsApp installed");
        } else {
            // Cannot open whatsapp
            NSString *stringURL = @"http://itunes.apple.com/app/whatsapp-messenger/id310633997";
            NSURL *url = [NSURL URLWithString:stringURL];
            [[UIApplication sharedApplication] openURL:url];

            NSString *errorMessage = @"Not installed";
            NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedString(errorMessage, nil)};
            NSError *error = [NSError errorWithDomain:@"com.rnshare" code:1 userInfo:userInfo];

            NSLog(@"%@", errorMessage);
            return failureCallback(error);
        }

        if ([options[@"url"] rangeOfString:@"wam"].location != NSNotFound || [options[@"url"] rangeOfString:@"mp4"].location != NSNotFound) {
            NSLog(@"Sending whatsapp movie");
            documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:options[@"url"]]];
            documentInteractionController.UTI = @"net.whatsapp.movie";
            documentInteractionController.delegate = self;

            [documentInteractionController presentOpenInMenuFromRect:CGRectMake(0, 0, 0, 0) inView:[[[[[UIApplication sharedApplication] delegate] window] rootViewController] view] animated:YES];
            NSLog(@"Done whatsapp movie");
            successCallback(@[]);
        } else {
            text = (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef) text, NULL,CFSTR("!*'();:@&=+$,/?%#[]"),kCFStringEncodingUTF8));
            
            NSString * urlWhats = whatsAppNumber ? [NSString stringWithFormat:@"whatsapp://send?phone=%@&text=%@", whatsAppNumber, text] : [NSString stringWithFormat:@"whatsapp://send?text=%@", text];
            NSURL * whatsappURL = [NSURL URLWithString:urlWhats];
    
            if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
                [[UIApplication sharedApplication] openURL: whatsappURL];
                successCallback(@[]);
            }
        }
    }
}
#endif
@end
