/* global define: false */

define([
    "angular",
    "cjt/core"
], function(
    angular,
    CJT
) {

    var app = angular.module("App");

    app.factory("configAPI", [
        "$http",
        function(
            $http
        ) {
            return {
                fetch: function() {
                    return $http({
                        method: "GET",
                        url: CJT.buildFullPath("templated/todo/config.cgi")
                    }).then(function(resp) {
                        return resp.data;
                    });
                },
                save: function(config) {
                    return $http({
                        method: "POST",
                        url:    CJT.buildFullPath("templated/todo/config.cgi"),
                        data:   config
                    }).then(function(resp) {
                        return resp.data;
                    });
                }
            };
        }
    ]);
});
