#import "OpenFiles.h"
#import <MobileCoreServices/MobileCoreServices.h>

@implementation OpenFiles

- (void)open:(CDVInvokedUrlCommand*)command {
    self.callbackId = command.callbackId;

    dispatch_async(dispatch_get_main_queue(), ^{
        UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[(NSString*)kUTTypeItem] inMode:UIDocumentPickerModeImport];

        documentPicker.delegate = self;
        documentPicker.modalPresentationStyle = UIModalPresentationFullScreen;

        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        [rootViewController presentViewController:documentPicker animated:YES completion:nil];
    });
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    if (urls.count > 0) {
        NSURL *fileURL = urls[0];
        NSString *filePath = [fileURL path];
        NSString *fileName = [fileURL lastPathComponent];

        NSError *error;
        NSData *fileData = [NSData dataWithContentsOfURL:fileURL options:NSDataReadingMappedIfSafe error:&error];

        if (error) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Failed to read file"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
            return;
        }

        NSDictionary *fileInfo = @{
            @"fileName": fileName,
            @"filePath": filePath,
            @"fileData": [fileData base64EncodedStringWithOptions:0]
        };

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:fileInfo];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
    }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"User canceled file selection"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}

@end