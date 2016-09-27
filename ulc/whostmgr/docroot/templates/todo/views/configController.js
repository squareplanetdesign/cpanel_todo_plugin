/* global define: false */

define(
    [
        "angular",
        "cjt/services/alertService",
        "app/services/configAPI"
    ],
    function(angular) {

        // Retrieve the current application
        var app = angular.module("App");

        var controller = app.controller(
            "todosController", [
                "$scope",
                "alertService",
                "configAPI",
                function(
                    $scope,
                    alertService,
                    configAPI
                ) {
                    $scope.load = function() {
                        configAPI.fetch().then(function(config) {
                            $scope.config = config;
                            $scope.loading = false;
                        }).catch(function(error) {
                            alertService.add({
                                type:    "danger",
                                message: "Failed to load the configuration.",
                                id:      "loadFailed"
                            });
                        });
                    };

                    $scope.save = function() {
                        $scope.loading = true;
                        configAPI.save($scope.config).then(function(config) {
                            $scope.config = config;
                            $scope.loading = false;
                        }).catch(function(error) {
                            alertService.add({
                                type:    "danger",
                                message: "Failed to save the configuration.",
                                id:      "saveFailed"
                            });
                        });
                    };

                    $scope.loading = true;
                    $scope.load();
                }
            ]
        );

        return controller;
    }
);
