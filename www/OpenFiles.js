var exec = require("cordova/exec");

var OpenFiles = {
    open: function(successCallback, errorCallback) {
        exec(successCallback, errorCallback, "OpenFiles", "open", []);
    }
};

module.exports = OpenFiles;