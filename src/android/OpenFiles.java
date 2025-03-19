package com.example.openfiles;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.util.Base64;
import android.database.Cursor;
import android.provider.OpenableColumns;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.PluginResult;

import java.io.InputStream;
import java.io.ByteArrayOutputStream;

public class OpenFiles extends CordovaPlugin {
    private static final int PICK_FILE_REQUEST = 1;
    private CallbackContext callbackContext;

    @Override
    public boolean execute(String action, org.json.JSONArray args, CallbackContext callbackContext) {
        if (action.equals("open")) {
            this.callbackContext = callbackContext;
            openFilePicker();
            return true;
        }
        return false;
    }

    private void openFilePicker() {
        Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
        intent.setType("*/*"); // Opens file manager for all file types
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        cordova.startActivityForResult(this, intent, PICK_FILE_REQUEST);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == PICK_FILE_REQUEST && resultCode == Activity.RESULT_OK) {
            if (data != null) {
                Uri uri = data.getData();
                try {
                    InputStream inputStream = cordova.getActivity().getContentResolver().openInputStream(uri);
                    ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
                    byte[] buffer = new byte[1024];
                    int bytesRead;
                    while ((bytesRead = inputStream.read(buffer)) != -1) {
                        outputStream.write(buffer, 0, bytesRead);
                    }
                    inputStream.close();
                    String base64File = Base64.encodeToString(outputStream.toByteArray(), Base64.DEFAULT);

                    org.json.JSONObject result = new org.json.JSONObject();
                    result.put("fileName", getFileName(uri));
                    result.put("fileData", base64File);

                    callbackContext.success(result);
                } catch (Exception e) {
                    callbackContext.error("Failed to read file: " + e.getMessage());
                }
            }
        } else {
            callbackContext.error("File selection canceled.");
        }
    }

    private String getFileName(Uri uri) {
        Cursor cursor = cordova.getActivity().getContentResolver().query(uri, null, null, null, null);
        int nameIndex = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME);
        cursor.moveToFirst();
        String fileName = cursor.getString(nameIndex);
        cursor.close();
        return fileName;
    }
}