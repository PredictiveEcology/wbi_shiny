// Edit this array of apps
var apps = [
    {
        name: "WBI NWT",
        path: "./apps/nwt/",
        image: "https://hub.analythium.io/assets/web/covid-shiny.png",
        description: "Northwest Territories part of WBI"
    }
]

var app = new Vue({
    el: '#app',
    data: {
        apps: apps
    }
})
