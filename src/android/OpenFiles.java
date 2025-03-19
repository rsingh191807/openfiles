package com.example.openfiles;
import android.app.Activity;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.provider.MediaStore;
import android.util.Base64;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

public class OpenFiles extends CordovaPlugin {

    private static final int PICK_FILE_REQUEST = 1;
    private CallbackContext callbackContext;

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if ("open".equals(action)) {
            this.callbackContext = callbackContext;
            openFilePicker();
            return true;
        }
        return false;
    }

    private void openFilePicker() {
        Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
        intent.setType("*/*");
        intent.addCategory(Intent.CATEGORY_OPENABLE);

        cordova.setActivityResultCallback(this);
        cordova.getActivity().startActivityForResult(Intent.createChooser(intent, "Select a file"), PICK_FILE_REQUEST);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == PICK_FILE_REQUEST && resultCode == Activity.RESULT_OK) {
            if (data != null && data.getData() != null) {
                Uri uri = data.getData();
                try {
                    // Get file path from URI
                    String filePath = getPathFromUri(uri);

                    if (filePath != null) {
                        // Read file as binary
                        byte[] fileData = readFileAsBinary(filePath);
                        // Convert binary data to Base64
                        String base64Data = Base64.encodeToString(fileData, Base64.DEFAULT);

                        // Create JSON response
                        JSONObject result = new JSONObject();
                        result.put("filePath", filePath);
                        result.put("fileData", base64Data);

                        // Send response to JavaScript
                        callbackContext.success(result);
                    } else {
                        callbackContext.error("Unable to retrieve file path.");
                    }
                } catch (Exception e) {
                    callbackContext.error("Error processing file: " + e.getMessage());
                }
            } else {
                callbackContext.error("No file selected.");
            }
        }
    }

    private String getPathFromUri(Uri uri) {
        String[] projection = { MediaStore.Files.FileColumns.DATA };
        Cursor cursor = cordova.getActivity().getContentResolver().query(uri, projection, null, null, null);
        if (cursor != null) {
            int columnIndex = cursor.getColumnIndexOrThrow(MediaStore.Files.FileColumns.DATA);
            cursor.moveToFirst();
            String filePath = cursor.getString(columnIndex);
            cursor.close();
            return filePath;
        }
        return null;
    }

    private byte[] readFileAsBinary(String filePath) throws IOException {
        File file = new File(filePath);
        FileInputStream fis = new FileInputStream(file);
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        byte[] buffer = new byte[1024];
        int bytesRead;
        while ((bytesRead = fis.read(buffer)) != -1) {
            bos.write(buffer, 0, bytesRead);
        }
        fis.close();
        return bos.toByteArray();
    }
}