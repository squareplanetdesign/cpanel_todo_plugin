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

                    $scope.mark = function(todo) {
                        todoAPI.mark(todo).then(function(resp) {
                            todo.status  = resp.data.status;
                            todo.doned   = resp.data.doned;
                            todo.changed = resp.data.changed;
                        }).catch(function(error) {
                            alertService.add({
                                type: "danger",
                                message: "Failed to add the mark the todo: " + error,
                                id: "markFailed"
                            });
                        });
                    };

                    // Hide done items initially
                    $scope.hideDone = true;

                    var pattern, patternSubject;
                    $scope.by_subject_and_status = function(todo) {
                        if (!pattern || patternSubject !== $scope.subjectFilter) {
                            pattern = new RegExp($scope.subjectFilter);
                        }
                        if ($scope.hideDone) {
                            return pattern.test(todo.subject) && todo.status !== 2;
                        } else {
                            return pattern.test(todo.subject);
                        }
                    };

                    $scope.edit = function(todo) {
                        if (todo.edit) {
                            todoAPI.update(todo).then(function(resp) {
                                todo.doned   = resp.data.doned;
                                todo.changed = resp.data.changed;
                                todo.edit    = false;
                            }).catch(function(error) {
                                alertService.add({
                                    type: "danger",
                                    message: "Failed to update the todo: " + error,
                                    id: "updateFailed"
                                });
                            });
                        } else {
                            todo.edit = true;
                        }
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