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
                    todoAPI.list().then(function(resp) {
                        $scope.todos = resp.data;
                        if ($scope.todos && $scope.todos.length > 0) {
                            alertService.add({
                                type: "info",
                                message: "Loaded the data",
                                id: "loadedOk"
                            });
                        }
                    }).catch(function(error) {
                        alertService.add({
                            type: "danger",
                            message: "Faild to load the data: " + error,
                            id: "loadFailed"
                        });
                    });
                }
            ]
        );

        return controller;
    }
);