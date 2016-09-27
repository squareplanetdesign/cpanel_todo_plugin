/* global define: false */

define([
    "angular"
], function(
    angular
) {

    var app = angular.module("App");

    var data = [
            {
                id: 1,
                subject: "wash the car",
                created: 12345678,
                updated: 12345678,
                doned:   null,
                description: "remember you have a coupon",
                status: 1,
            },
            {
                id: 2,
                subject: "take out the trash",
                created: 12345678,
                updated: 12345678,
                doned:   null,
                description: "do not forget the upstairs bath room again",
                status: 1,
            },
            {
                id: 3,
                subject: "record the starwars marathon on tv",
                created: 12345633,
                updated: 12345639,
                doned:   12345641,
                description: "What channel?",
                status: 2,
            }
        ];

    app.factory("todoAPI", [
        function(
        ) {
            return {
                list : function() {
                    return data;
                }
            };
        }
    ]);
});