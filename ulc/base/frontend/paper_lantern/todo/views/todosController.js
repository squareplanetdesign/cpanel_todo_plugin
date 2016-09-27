/* global define: false */

define(
    [
        "angular",
        "cjt/services/alertService",
        "app/services/todoAPI"
    ],
    function(angular) {

        // Retrieve the current application
        var app = angular.module("App");

        var controller = app.controller(
            "todosController", [
                "$scope",
                "alertService",
                "todoAPI",
                function(
                    $scope,
                    alertService,
                    todoAPI
                ) {
                    $scope.todos = todoAPI.list();
                    alertService.add({
                        type: "info",
                        message: "Loaded the data",
                        id: "loadedOk"
                    });
                }
            ]
        );

        return controller;
    }
);