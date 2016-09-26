/* global define: false */

define(
    [
        "angular",
    ],
    function(angular) {

        // Retrieve the current application
        var app = angular.module("App");

        var controller = app.controller(
            "todosController", [
                "$scope",
                function(
                    $scope
                ) {
                    $scope.message = "A message for plugin developers.";
                }
            ]
        );

        return controller;
    }
);