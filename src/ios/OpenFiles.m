#import "OpenFiles.h"
#import <MobileCoreServices/MobileCoreServices.h>

@implementation OpenFiles

// Entry function for Cordova
- (void)open:(CDVInvokedUrlCommand*)command {
    self.callbackId = command.callbackId;

    // Create a document picker
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[(NSString *)kUTTypeItem] inMode:UIDocumentPickerModeImport];

    documentPicker.delegate = self;
    documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;

    // Show file picker
    [self.viewController presentViewController:documentPicker animated:YES completion:nil];
}

// Delegate method called when user picks a file
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    if (urls.count == 0) {
        [self sendError:@"No file selected"];
        return;
    }

    NSURL *fileURL = urls[0];
    NSData *fileData = [NSData dataWithContentsOfURL:fileURL];

    if (!fileData) {
        [self sendError:@"Failed to read file"];
        return;
    }

    // Convert file to Base64
    NSString *base64String = [fileData base64EncodedStringWithOptions:0];

    // Create response
    NSDictionary *fileInfo = @{
        @"fileName": fileURL.lastPathComponent,
        @"filePath": fileURL.absoluteString,
        @"fileData": base64String
    };

    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:fileInfo];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}

// Handle cancellation
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    [self sendError:@"User cancelled file selection"];
}

// Helper function to send errors
- (void)sendError:(NSString *)errorMessage {
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorMessage];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}

@end
