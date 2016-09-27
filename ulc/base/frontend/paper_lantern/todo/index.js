/* global require: false, define: false */

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

                    app.value("todoData", {
                        todos: null
                    });

                    // routing
                    app.config(["$routeProvider",
                        function($routeProvider) {

                            // Setup the routes
                            $routeProvider.when("/todos/", {
                                controller: "todosController",
                                templateUrl: CJT.buildFullPath("plugins/cpanel/todo/views/todosView.ptt")
                            });

                            $routeProvider.when("/todo/new", {
                                controller: "todosController",
                                templateUrl: CJT.buildFullPath("plugins/cpanel/todo/views/addTodoView.ptt")
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
