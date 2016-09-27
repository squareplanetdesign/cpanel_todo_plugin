/* global define: false */

define([
    "angular",
    "cjt/io/api",
    "cjt/io/uapi-request",
    "cjt/io/uapi", // IMPORTANT: Load the driver so its ready

    // Angular components
    "cjt/services/APIService"
], function(
    angular,
    API,
    APIREQUEST
) {

    // Fetch the angular application
    var app = angular.module("App");

    // Add a factory that handles the APIs
    app.factory("todoAPI", [
        "$q",
        "APIService",
        function(
            $q,
            APIService
        ) {
            // Set up the service's constructor and parent
            var TodoService = function() {};
            TodoService.prototype = new APIService();

            // Extend the prototype with any class-specific functionality
            angular.extend(TodoService.prototype, {
                list : function() {
                    var apiCall = new APIREQUEST.Class();
                    apiCall.initialize("Todo", "list_todos");
                    return this.deferred(apiCall).promise;
                }
            });

            return new TodoService();
        }
    ]);
});