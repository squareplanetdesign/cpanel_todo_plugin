/*
  Copyright 2016 cPanel, Inc.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

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
                    var request = new APIREQUEST.Class();
                    request.initialize("Todo", "list_todos");
                    return this.deferred(request).promise;
                },
                add: function(todo) {
                    var request = new APIREQUEST.Class();
                    request.initialize("Todo", "add_todo");
                    request.addArgument("subject", todo.subject);
                    request.addArgument("description", todo.description);
                    return this.deferred(request).promise;
                },
                mark: function(todo) {
                    var request = new APIREQUEST.Class();
                    request.initialize("Todo", "mark_todo");
                    request.addArgument("id", todo.id);
                    request.addArgument("status", todo.status);
                    return this.deferred(request).promise;
                },
                update: function(todo) {
                    var request = new APIREQUEST.Class();
                    request.initialize("Todo", "update_todo");
                    request.addArgument("id", todo.id);
                    request.addArgument("subject", todo.subject);
                    request.addArgument("description", todo.description);
                    return this.deferred(request).promise;
                },
                remove: function(todo) {
                    var request = new APIREQUEST.Class();
                    request.initialize("Todo", "remove_todo");
                    request.addArgument("id", todo.id);
                    return this.deferred(request).promise;
                }
            });

            return new TodoService();
        }
    ]);
});