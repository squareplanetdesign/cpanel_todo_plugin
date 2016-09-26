/* global require: false */

// Loads the application with the pre-built combined files
require( ["frameworksBuild", "locale!cjtBuild", "app/index.cmb"], function() {
    require(
        [
            "master/master",
            "app/index"
        ],
        function(MASTER, APP) {
            MASTER();
            APP();
        }
    );
});
