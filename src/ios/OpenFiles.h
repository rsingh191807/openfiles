#import <Cordova/CDVPlugin.h>
#import <UIKit/UIKit.h>

@interface OpenFiles : CDVPlugin <UIDocumentPickerDelegate>

@property (nonatomic, strong) NSString *callbackId;

- (void)open:(CDVInvokedUrlCommand*)command;

@end
