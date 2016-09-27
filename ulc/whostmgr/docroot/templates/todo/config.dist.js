/* global require: false */

// Loads the application with the pre-built combined files
require( ["frameworksBuild", "locale!cjtBuild", "app/config.cmb"], function() {
    require(
        [
            "app/config"
        ],
        function(APP) {
            MASTER();
            APP();
        }
    );
});
