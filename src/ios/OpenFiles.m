#import "OpenFiles.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface OpenFiles () <UIDocumentPickerDelegate>
@property (nonatomic, strong) CDVInvokedUrlCommand *command;
@end

@implementation OpenFiles

- (void)open:(CDVInvokedUrlCommand*)command {
    self.command = command;

    // Allowed file types (all types)
    NSArray *documentTypes = @[(NSString *)kUTTypeItem];

    // Create document picker
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeOpen];
    documentPicker.delegate = self;

    // Present the document picker
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        [rootViewController presentViewController:documentPicker animated:YES completion:nil];
    });
}

// Document picker delegate method
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    if (urls.count == 0) {
        [self sendError:@"No file selected."];
        return;
    }

    NSURL *fileURL = [urls firstObject];
    NSString *filePath = [fileURL path];

    // Read file as binary and convert to Base64
    NSData *fileData = [NSData dataWithContentsOfURL:fileURL];
    if (fileData == nil) {
        [self sendError:@"Failed to read file."];
        return;
    }

    NSString *base64Data = [fileData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];

    // Create JSON response
    NSDictionary *result = @{
        @"filePath": filePath,
        @"fileData": base64Data
    };

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
}

// Handle cancel event
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    [self sendError:@"File selection was cancelled."];
}

// Helper method to send error message
- (void)sendError:(NSString *)message {
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
}

@end
