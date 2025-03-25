#import "OpenFiles.h"

@implementation OpenFiles

// Opens the file picker
- (void)open:(CDVInvokedUrlCommand*)command {
    self.callbackId = command.callbackId;

    NSArray *documentTypes = @[@"public.item"]; // Allows all file types
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeImport];

    documentPicker.delegate = self;
    documentPicker.modalPresentationStyle = UIModalPresentationFullScreen;

    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:documentPicker animated:YES completion:nil];
    });
}

// Called when a file is picked
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    if (urls.count == 0) {
        [self sendError:@"No file was selected"];
        return;
    }

    NSURL *fileURL = urls[0];
    NSString *fileName = [fileURL lastPathComponent];
    NSData *fileData = [NSData dataWithContentsOfURL:fileURL];

    if (!fileData) {
        [self sendError:@"Failed to read file data"];
        return;
    }

    NSString *fileBase64 = [fileData base64EncodedStringWithOptions:0];
    NSString *mimeType = [self getMimeTypeFromUrl:fileURL];

    NSDictionary *result = @{
        @"fileName": fileName,
        @"mimeType": mimeType,
        @"fileData": fileBase64
    };

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}

// Called when user cancels file selection
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    [self sendError:@"File selection was canceled"];
}

// Returns MIME type of selected file
- (NSString *)getMimeTypeFromUrl:(NSURL *)fileURL {
    NSString *fileExtension = [fileURL pathExtension];
    if (fileExtension.length == 0) {
        return @"application/octet-stream"; // Default unknown file type
    }

    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)fileExtension, NULL);
    CFStringRef mimeTypeCF = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);

    NSString *mimeType = (__bridge_transfer NSString *)mimeTypeCF;
    if (!mimeType) {
        mimeType = @"application/octet-stream"; // Fallback MIME type
    }

    CFRelease(UTI);
    return mimeType;
}

// Sends an error response
- (void)sendError:(NSString *)message {
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}

@end