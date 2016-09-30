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

/* global require: false, define: false, PAGE: false */

define(
    [
        "angular",
        "jquery",
        "lodash",
        "cjt/core",
        "cjt/modules",
        "ngRoute",
        "uiBootstrap"
    ],
    function(angular, $, _, CJT) {
        return function() {
            // First create the application
            angular.module("App", ["ngRoute", "ui.bootstrap", "cjt2.cpanel"]);

            // Then load the application dependencies
            var app = require(
                [
                    // Application Modules
                    "cjt/views/applicationController",
                    "cjt/directives/alertList",

                    // Controllers
                    "app/views/todosController"
                ], function() {

                    var app = angular.module("App");

                    var todos = [];

                    // Optimization 1: Prefetch data
                    if (PAGE.todos && PAGE.todos.status) {
                        todos = PAGE.todos.data;
                    }

                    app.value("todoData", {
                        todos: todos
                    });

                    // routing
                    app.config(["$routeProvider",
                        function($routeProvider) {

                            /* Optimization 2: Preload view partials,
                               we don't need their full paths. */

                            // Setup the routes
                            $routeProvider.when("/todos/", {
                                controller: "todosController",
                                templateUrl: "views/todosView.ptt"
                            });

                            $routeProvider.when("/todo/new", {
                                controller: "todosController",
                                templateUrl: "views/addTodoView.ptt"
                            });

                            $routeProvider.otherwise({
                                "redirectTo": "/todos/"
                            });
                        }
                    ]);

                    /**
                     * Initialize the application
                     * @return {ngModule} Main module.
                     */
                    app.init = function() {

                        var appContent = angular.element("#content");

                        if(appContent[0] !== null){
                            // apply the app after requirejs loads everything
                            angular.bootstrap(appContent[0], ["App"]);
                        }

                        // Chaining
                        return app;
                    };

                    // We can now run the bootstrap for the application
                    app.init();

                });

            return app;
        };
    }
);
