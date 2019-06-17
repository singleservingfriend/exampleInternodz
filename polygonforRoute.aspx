    <div id="msg" class="polymsgcss">
        <div class="typewriter">
             <h1>Calculating...</h1>
        </div>
        <div class="typewriter">
            <p>Please wait a bit, while we inform<br />the potential customers on your route</p>
        </div>
    </div>
    <script type="text/javascript">
        var mapCanvas = "map-canvas";
        var map;
        var directionsService = new google.maps.DirectionsService;
        var directionsDisplay = new google.maps.DirectionsRenderer;

        var mapConfig = {
            zoom: 6,
            center: { lat: 41.015137, lng: 28.979530 },
            mapTypeId: google.maps.MapTypeId.ROADMAP,
            mapTypeControlOptions: {
                style: google.maps.MapTypeControlStyle.DROPDOWN_MENU,
                mapTypeIds: [google.maps.MapTypeId.HYBRID, google.maps.MapTypeId.ROADMAP, google.maps.MapTypeId.SATELLITE, google.maps.MapTypeId.TERRAIN]
            },
            overviewMapControl: true,
            scaleControl: true,
            streetViewControl: true,
            panControl: true,
            rotateControl: true,
            maxZoomForCenter: 17
        };

        function initialize() {
            map = new google.maps.Map(document.getElementById(mapCanvas), mapConfig);
            directionsDisplay.setMap(map);
            calculateAndDisplayRoute(directionsService, directionsDisplay);
        };

        var triangleCoords2 = [
            { lat: 25.774, lng: -80.19 },
            { lat: 18.466, lng: -66.118 },
            { lat: 32.321, lng: -64.757 }
        ];

        function calculateAndDisplayRoute(directionsService, directionsDisplay) {
            var waypts = [];
            //var checkboxArray = document.getElementById('waypoints');

            //BİRDEN FAZLA NOKTA İÇİN
            //waypts.push({
            //    location: new window.google.maps.LatLng(39.752098, 37.017896),
            //    stopover: true
            //});

            var url = window.location.href;
            var startP = /start=([^&]+)/.exec(url)[1];
            var endP = /end=([^&]+)/.exec(url)[1];
           
            directionsService.route({
                origin: startP, /*new window.google.maps.LatLng(parseFloat(39.75182,37.017451)),*/
                destination: endP, /*new window.google.maps.LatLng(parseFLoat(39.709124,37.021074)),*/
                waypoints: waypts,
                optimizeWaypoints: true,
                travelMode: 'DRIVING'
            }, function (response, status) {
                if (status === 'OK') {
                    directionsDisplay.setDirections(response);
                    var route = response.routes[0];

                    var legs = response.routes[0].legs;
                    overviewPath = response.routes[0].overview_path,
                        overviewPathGeo = [];
                    for (var i = 0; i < legs.length; i++) {
                        var steps = legs[i].steps;
                        for (j = 0; j < steps.length; j++) {
                            var nextSegment = steps[j].path;
                            for (k = 0; k < nextSegment.length; k++) {
                                overviewPathGeo.push(
                                    [nextSegment[k].lng(), nextSegment[k].lat()]
                                );
                            }
                        }
                    }
                    bermudaTriangle = new google.maps.Polygon({
                        paths: createPolygon(overviewPathGeo),
                        fillColor: '#ff0000',
                    });
                    bermudaTriangle.setMap(map);

                    var summaryPanel = document.getElementById('directions-panel');
                    summaryPanel.innerHTML = '';
                    // For each route, display summary information.
                    for (var i = 0; i < route.legs.length; i++) {
                        var routeSegment = i + 1;
                        summaryPanel.innerHTML += '<b>Route Segment: ' + routeSegment +
                            '</b><br>';
                        summaryPanel.innerHTML += route.legs[i].start_address + '<br><i>↓</i><br>';
                        summaryPanel.innerHTML += route.legs[i].end_address + '<br>';
                        summaryPanel.innerHTML += route.legs[i].distance.text + '<br><br>';
                    }
                } else {
                    window.alert('Directions request failed due to ' + status);
                }

                var sentstring = document.getElementById("sentstring").value;

                var llarray = sentstring.split("&");
                var i;
                for (i = 0; i < llarray.length; i++) {

                    var allitem = llarray[i].split("-");
                    var userid = allitem[0];
                    var items = allitem[1];

                    var item = items.split(",");
                    var curPosition = new google.maps.LatLng(item[0], item[1]);
                    var inOrout =
                        google.maps.geometry.poly.containsLocation(curPosition, bermudaTriangle) ?
                            userid + "-" :
                            '';
                    document.getElementById("laststring").value = document.getElementById("laststring").value + inOrout;
                }
                const sleep = (milliseconds) => {
                    return new Promise(resolve => setTimeout(resolve, milliseconds))
                }
                sleep(4000).then(() => {
                    var rldt = /rldt=([^&]+)/.exec(url)[1];
                    var did = /deliverid=([^&]+)/.exec(url)[1];
                    window.location.href = "addUpcomings.aspx?did=" + did + "&userstr=" + document.getElementById("laststring").value + "&rldt=" + rldt;
                })
                
            });

        }

        createPolygon = function (overviewPath) {
            if (overviewPath && overviewPath.length >= 0) {
                var url = window.location.href;
                var distvalue = /distance=([^&]+)/.exec(url)[1];
                last_width_long = 7;
                var distance = last_width_long / distvalue;  //en km.
                distance = (distance / 111.12);
                geoInput = {
                    type: "LineString",
                    coordinates: overviewPath
                };
                var geoReader = new jsts.io.GeoJSONReader(),
                    geoWriter = new jsts.io.GeoJSONWriter();
                var geometry = geoReader.read(geoInput).buffer(distance);
                var polygon = geoWriter.write(geometry);
                polygon_route = polygon;

                var areaCoordinates = [];
                var polygonCoordinates = polygon.coordinates[0];
                
                for (i = 0; i < polygonCoordinates.length; i++) {
                    var coordinate = polygonCoordinates[i];
                    areaCoordinates.push(new google.maps.LatLng(coordinate[1], coordinate[0]));
                   
                }
                //console.log(JSON.stringify(areaCoordinates));
                return areaCoordinates;
            } else return false;
        };
        google.maps.event.addDomListener(window, 'load', initialize);
    </script>

    <div id="map-canvas"></div>
    <div id="directions-panel"></div>
