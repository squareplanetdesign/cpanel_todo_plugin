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
                "todoData",
                function(
                    $scope,
                    alertService,
                    todoAPI,
                    todoData
                ) {
                    var list = function() {
                        todoAPI.list().then(function(resp) {
                            todoData.todos = $scope.todos = resp.data;
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
                    };

                    $scope.open_add_view = function() {
                        $scope.newTodo = {
                            subject: "",
                            description: ""
                        };
                        $scope.loadView("todo/new");
                    };

                    $scope.add = function(todo) {
                        $scope.saving = true;
                        todoAPI.add(todo).then(function(resp) {
                            $scope.todos.push(resp.data);
                            alertService.add({
                                type: "info",
                                message: "Added the new todo.",
                                id: "addOk"
                            });
                            $scope.saving = false;
                            $scope.loadView("todos");
                        }).catch(function(error) {
                            alertService.add({
                                type: "danger",
                                message: "Failed to add the new todo: " + error,
                                id: "addFailed"
                            });
                        });
                    };

                    if (!todoData.todos) {
                        list();
                    } else {
                        $scope.todos = todoData.todos;
                    }
                }
            ]
        );

        return controller;
    }
);