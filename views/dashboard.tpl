<!DOCTYPE html>
<html>
  <head>
    <style type="text/css">
      html, body { height: 100%; margin: 0; padding: 0; font-family: Helvetica}
      #map { height: calc(100% - 40px); }
    </style>
    <script src="https://code.jquery.com/jquery-2.2.3.min.js"></script>
  </head>
  <body>
    <div style="width: 100%; height: 20px; background: #333; color: white; padding: 10px; line-height: 20px">
      <span>Vavava demo dashboard</span>
    </div>
    <div id="map"></div>
    <script type="text/javascript">

      var map;
      var line;
      var marker;
      var longg = 2.425390;
      var latt =  41.543664;
      var tecnoLongg = 2.434114;
      var tecnoLatt =  41.528356;
      var routes = [];
      var clusters = {};
      var clusteroids = {};
      var clients = {};
      var busos = [];
      var busObjective = [];
      var busIterations = [];
      var points = [];

      function initMap() {
        //41.541183, 2.436676
        console.log("1");
        map = new google.maps.Map(document.getElementById('map'), {
          center: {lat: 41.541183, lng: 2.436676},
          zoom: 15
        });

        {{ range .clients }}
            var client = new google.maps.Circle({
              strokeColor: '#FF0000',
              strokeOpacity: 0.0,
              strokeWeight: 2,
              fillColor: '#FF0000',
              fillOpacity: 1.0,
              map: map,
              center: {lat: {{.Lat}}, lng: {{.Lng}}},
              radius: 10
            });
            var key = {{.Lat}}.toString()+{{.Lng}}.toString();
            clients[key] = client;
        {{ end }}

        console.log("2");

        {{ range .clusters }}
            var color = randomColor({
                luminosity: 'dark',
                format: 'hex' // e.g. 'rgb(225,200,20)'
            });
            if ({{.Centroid.Lng}} != null && {{.Centroid.Lat}} != null) {
                console.log("ho");
                var cluster = new google.maps.Circle({
                  strokeColor: color,
                  strokeOpacity: 0.8,
                  strokeWeight: 2,
                  fillColor: color,
                  fillOpacity: 0.1,
                  map: map,
                  center: {lat: {{.Centroid.Lat}}, lng: {{.Centroid.Lng}}},
                  radius: {{.Radius}}+10
                });
                var key = {{.Centroid.Lat}}.toString()+{{.Centroid.Lng}}.toString();
                clusters[key] = cluster;
                clusteroids[key] = {{.}}

            }
        {{ end }}

        //bucle recorrer rutas Ivan
        {{ range .routes }}
            points.push({{.}});
            var route = [];
            //console.log(points);
            var first = true;
            var pre;
            routes.push([]);
            ci = routes.length-1;

            points[points.length-1].unshift({Lat: tecnoLatt, Lng: tecnoLongg})
            points[points.length-1].push({Lat: tecnoLatt, Lng: tecnoLongg})

            route = route.concat(newRoute(points[points.length-1], function(ci) {
                return function(pts) {
                    routes[ci] = routes[ci].concat(pts);
                    //routes = [route]
                }
            }(ci)));

            // points.forEach(function (item) {
            //     if (first) {
            //         first = false;
            //         pre = item;
            //         return;
            //     }
                
            //     pre = item;
            // })
        {{ end }}



        google.maps.event.addListener(map, 'click', function(event) {
           placeMarker(event.latLng);
        });
      }

      function moveBuses() {
          if (busos.length == 0) {
              //bucle moure tots els bus, fer la crida asincrona per moure els diferents busos
                routes.forEach(function (routeBus) {
                    var cityCircle = new google.maps.Circle({
                        strokeColor: '#000000',
                        strokeOpacity: 1,
                        strokeWeight: 2,
                        fillColor: '#00FF00',
                        fillOpacity: 0.5,
                        map: map,
                        center: {lat: routeBus[0].lat, lng: routeBus[0].lng},
                        radius: 25,
                        zIndex: 99,
                    });


                    busos.push(cityCircle);
                    busObjective.push(1);
                    busIterations.push(0);
                    //busMovement(cityCircle,routeBus);

                })

                return;
          }


          busos.forEach(function(bus,i){
              var objective = busObjective[i];
              var posActual = bus.getCenter();
              var busRoute = routes[i]
              var punt = busRoute[objective]
              //recrrer cluster i fe un check per a cada un de si == centre
              var pre = busRoute[objective-1]
            //   console.log(punt);
            //   console.log(pre);
              var a = punt.lat - pre.lat;
              var b = punt.lng - pre.lng;
              var c = Math.sqrt( a*a + b*b );
              var iterations = Math.floor(c/0.00030)+1;
              console.log("Iterations" + iterations);
              var incrementX = a/iterations;
              var incrementY = b/iterations;
              console.log(posActual.lat())
              console.log(posActual.lng())
              busIterations[i]++;
              if (busIterations[i] >= iterations) {
                  var key = ""
                  console.log(clusters)
                  for (var j = 0; j < points[i].length; j++) {
                    dist = Math.sqrt(Math.pow(points[i][j].Lat - posActual.lat(),2) + Math.pow(points[i][j].Lng - posActual.lng(),2))
                    //console.log("Dist: " + dist)
                    if (dist < 0.0005) {
                        key = points[i][j].Lat.toString() + points[i][j].Lng.toString()
                        console.log("Got key: " + key)
                    }
                  }
                  if(clusters[key] != null){
                    clusters[key].setMap(null);
                    var clustPoints = clusteroids[key].Pts;
                    clustPoints.forEach(function(clustPoint){
                      var key2 = clustPoint.Lat.toString()+clustPoint.Lng.toString()
                      if(clients[key2] != null) {
                        clients[key2].setMap(null);
                      }
                    })
                  }

                  busObjective[i]++;
                  busObjective[i] %= busRoute.length;

                  if (busObjective[i] == 0) {
                      busObjective[i] = 1;
                  }
                  busIterations[i] = 0;
              }
              var pos = new google.maps.LatLng(posActual.lat()+incrementX, posActual.lng()+incrementY)
              bus.setCenter(pos);
          })
      }
      setInterval(moveBuses,300);

      function busMovement(bus, routeMovement){
            first = true;
            pre = null;
            routeMovement.forEach(function (punt) {
                if (first) {
                    first = false;
                    pre = item;
                    return;
                }
                var a = punt.Lat - pre.Lat;
                var b = punt.Lng - pre.lng;
                var c = Math.sqrt( a*a + b*b );
                var iterations = c/0.00300;
                var incrementX = a/iterations;
                var incrementY = b/iterations;
                var actualPosition= {lat: tecnoLatt, lng: tecnoLongg}
                for (i = 0; i < iterations; ++i){
                    setTimeout(function () {
                        actualPosition.lat += incrementX;
                        actualPosition.lng += incrementY;
                        var pos = new google.maps.LatLng(actualPosition.lat, actualPosition.lng)
                        bus.setCenter(pos);
                        console.log("in")
                    }, 1000 + i*1000);
                }

            })
      }

      function placeMarker() {
                  console.log("new route");

      }

      function newRoute(points,cb) {
        console.log("hello");

        var ll = []
        pts = "";
        for (i = 0; i < points.length; i++) {
             pts = pts + "point=" + points[i].Lat + "," + points[i].Lng + "&"
        }

        //url = "https://graphhopper.com/api/1/route?point=49.932707,11.588051&point=50.3404,11.64705&vehicle=car&debug=true&key=1e6fe44a-a261-4d55-9406-384d1e0eab2a&type=json&points_encoded=false"
        url = "https://graphhopper.com/api/1/route?"+pts+"vehicle=car&debug=true&key=1e6fe44a-a261-4d55-9406-384d1e0eab2a&type=json&points_encoded=false"
        $.get( url, function( data ) {
          console.log(data);
          //rt = JSON.parse(data.message);
          rt = data;
        //   console.log(rt);


          for (var i = 0; i < rt.paths[0].points.coordinates.length; ++i) {
            ll.push({"lat":  rt.paths[0].points.coordinates[i][1], "lng": rt.paths[0].points.coordinates[i][0]})
          }
          console.log(ll);
        //   if (line) line.setMap(null);
          new google.maps.Polyline({
             path: ll,
             geodesic: true,
             strokeColor: randomColor({
                luminosity: 'dark',
                format: 'hex' // e.g. 'rgb(225,200,20)'
            }),
             strokeOpacity: 1.0,
             strokeWeight: 2
           }).setMap(map);

           cb(ll);

        //    line.setMap(map);
        });
        console.log("new route");
      }


    </script>
    <script async defer
      src="https://maps.googleapis.com/maps/api/js?key=AIzaSyDb3m6o_OKV5OwUsLAdzdDQB8DQ6BJMIl0&callback=initMap">
    </script>

    <script>
            ;(function(root, factory) {

        // Support AMD
        if (typeof define === 'function' && define.amd) {
            define([], factory);

        // Support CommonJS
        } else if (typeof exports === 'object') {
            var randomColor = factory();

            // Support NodeJS & Component, which allow module.exports to be a function
            if (typeof module === 'object' && module && module.exports) {
            exports = module.exports = randomColor;
            }

            // Support CommonJS 1.1.1 spec
            exports.randomColor = randomColor;

        // Support vanilla script loading
        } else {
            root.randomColor = factory();
        }

        }(this, function() {

        // Seed to get repeatable colors
        var seed = null;

        // Shared color dictionary
        var colorDictionary = {};

        // Populate the color dictionary
        loadColorBounds();

        var randomColor = function (options) {

            options = options || {};

            // Check if there is a seed and ensure it's an
            // integer. Otherwise, reset the seed value.
            if (options.seed !== undefined && options.seed !== null && options.seed === parseInt(options.seed, 10)) {
            seed = options.seed;

            // A string was passed as a seed
            } else if (typeof options.seed === 'string') {
            seed = stringToInteger(options.seed);

            // Something was passed as a seed but it wasn't an integer or string
            } else if (options.seed !== undefined && options.seed !== null) {
            throw new TypeError('The seed value must be an integer or string');

            // No seed, reset the value outside.
            } else {
            seed = null;
            }

            var H,S,B;

            // Check if we need to generate multiple colors
            if (options.count !== null && options.count !== undefined) {

            var totalColors = options.count,
                colors = [];

            options.count = null;

            while (totalColors > colors.length) {

                // Since we're generating multiple colors,
                // incremement the seed. Otherwise we'd just
                // generate the same color each time...
                if (seed && options.seed) options.seed += 1;

                colors.push(randomColor(options));
            }

            options.count = totalColors;

            return colors;
            }

            // First we pick a hue (H)
            H = pickHue(options);

            // Then use H to determine saturation (S)
            S = pickSaturation(H, options);

            // Then use S and H to determine brightness (B).
            B = pickBrightness(H, S, options);

            // Then we return the HSB color in the desired format
            return setFormat([H,S,B], options);
        };

        function pickHue (options) {

            var hueRange = getHueRange(options.hue),
                hue = randomWithin(hueRange);

            // Instead of storing red as two seperate ranges,
            // we group them, using negative numbers
            if (hue < 0) {hue = 360 + hue;}

            return hue;

        }

        function pickSaturation (hue, options) {

            if (options.luminosity === 'random') {
            return randomWithin([0,100]);
            }

            if (options.hue === 'monochrome') {
            return 0;
            }

            var saturationRange = getSaturationRange(hue);

            var sMin = saturationRange[0],
                sMax = saturationRange[1];

            switch (options.luminosity) {

            case 'bright':
                sMin = 55;
                break;

            case 'dark':
                sMin = sMax - 10;
                break;

            case 'light':
                sMax = 55;
                break;
        }

            return randomWithin([sMin, sMax]);

        }

        function pickBrightness (H, S, options) {

            var bMin = getMinimumBrightness(H, S),
                bMax = 100;

            switch (options.luminosity) {

            case 'dark':
                bMax = bMin + 20;
                break;

            case 'light':
                bMin = (bMax + bMin)/2;
                break;

            case 'random':
                bMin = 0;
                bMax = 100;
                break;
            }

            return randomWithin([bMin, bMax]);
        }

        function setFormat (hsv, options) {

            switch (options.format) {

            case 'hsvArray':
                return hsv;

            case 'hslArray':
                return HSVtoHSL(hsv);

            case 'hsl':
                var hsl = HSVtoHSL(hsv);
                return 'hsl('+hsl[0]+', '+hsl[1]+'%, '+hsl[2]+'%)';

            case 'hsla':
                var hslColor = HSVtoHSL(hsv);
                var alpha = options.alpha || Math.random();
                return 'hsla('+hslColor[0]+', '+hslColor[1]+'%, '+hslColor[2]+'%, ' + alpha + ')';

            case 'rgbArray':
                return HSVtoRGB(hsv);

            case 'rgb':
                var rgb = HSVtoRGB(hsv);
                return 'rgb(' + rgb.join(', ') + ')';

            case 'rgba':
                var rgbColor = HSVtoRGB(hsv);
                var alpha = options.alpha || Math.random();
                return 'rgba(' + rgbColor.join(', ') + ', ' + alpha + ')';

            default:
                return HSVtoHex(hsv);
            }

        }

        function getMinimumBrightness(H, S) {

            var lowerBounds = getColorInfo(H).lowerBounds;

            for (var i = 0; i < lowerBounds.length - 1; i++) {

            var s1 = lowerBounds[i][0],
                v1 = lowerBounds[i][1];

            var s2 = lowerBounds[i+1][0],
                v2 = lowerBounds[i+1][1];

            if (S >= s1 && S <= s2) {

                var m = (v2 - v1)/(s2 - s1),
                    b = v1 - m*s1;

                return m*S + b;
            }

            }

            return 0;
        }

        function getHueRange (colorInput) {

            if (typeof parseInt(colorInput) === 'number') {

            var number = parseInt(colorInput);

            if (number < 360 && number > 0) {
                return [number, number];
            }

            }

            if (typeof colorInput === 'string') {

            if (colorDictionary[colorInput]) {
                var color = colorDictionary[colorInput];
                if (color.hueRange) {return color.hueRange;}
            }
            }

            return [0,360];

        }

        function getSaturationRange (hue) {
            return getColorInfo(hue).saturationRange;
        }

        function getColorInfo (hue) {

            // Maps red colors to make picking hue easier
            if (hue >= 334 && hue <= 360) {
            hue-= 360;
            }

            for (var colorName in colorDictionary) {
            var color = colorDictionary[colorName];
            if (color.hueRange &&
                hue >= color.hueRange[0] &&
                hue <= color.hueRange[1]) {
                return colorDictionary[colorName];
            }
            } return 'Color not found';
        }

        function randomWithin (range) {
            if (seed === null) {
            return Math.floor(range[0] + Math.random()*(range[1] + 1 - range[0]));
            } else {
            //Seeded random algorithm from http://indiegamr.com/generate-repeatable-random-numbers-in-js/
            var max = range[1] || 1;
            var min = range[0] || 0;
            seed = (seed * 9301 + 49297) % 233280;
            var rnd = seed / 233280.0;
            return Math.floor(min + rnd * (max - min));
            }
        }

        function HSVtoHex (hsv){

            var rgb = HSVtoRGB(hsv);

            function componentToHex(c) {
                var hex = c.toString(16);
                return hex.length == 1 ? '0' + hex : hex;
            }

            var hex = '#' + componentToHex(rgb[0]) + componentToHex(rgb[1]) + componentToHex(rgb[2]);

            return hex;

        }

        function defineColor (name, hueRange, lowerBounds) {

            var sMin = lowerBounds[0][0],
                sMax = lowerBounds[lowerBounds.length - 1][0],

                bMin = lowerBounds[lowerBounds.length - 1][1],
                bMax = lowerBounds[0][1];

            colorDictionary[name] = {
            hueRange: hueRange,
            lowerBounds: lowerBounds,
            saturationRange: [sMin, sMax],
            brightnessRange: [bMin, bMax]
            };

        }

        function loadColorBounds () {

            defineColor(
            'monochrome',
            null,
            [[0,0],[100,0]]
            );

            defineColor(
            'red',
            [-26,18],
            [[20,100],[30,92],[40,89],[50,85],[60,78],[70,70],[80,60],[90,55],[100,50]]
            );

            defineColor(
            'orange',
            [19,46],
            [[20,100],[30,93],[40,88],[50,86],[60,85],[70,70],[100,70]]
            );

            defineColor(
            'yellow',
            [47,62],
            [[25,100],[40,94],[50,89],[60,86],[70,84],[80,82],[90,80],[100,75]]
            );

            defineColor(
            'green',
            [63,178],
            [[30,100],[40,90],[50,85],[60,81],[70,74],[80,64],[90,50],[100,40]]
            );

            defineColor(
            'blue',
            [179, 257],
            [[20,100],[30,86],[40,80],[50,74],[60,60],[70,52],[80,44],[90,39],[100,35]]
            );

            defineColor(
            'purple',
            [258, 282],
            [[20,100],[30,87],[40,79],[50,70],[60,65],[70,59],[80,52],[90,45],[100,42]]
            );

            defineColor(
            'pink',
            [283, 334],
            [[20,100],[30,90],[40,86],[60,84],[80,80],[90,75],[100,73]]
            );

        }

        function HSVtoRGB (hsv) {

            // this doesn't work for the values of 0 and 360
            // here's the hacky fix
            var h = hsv[0];
            if (h === 0) {h = 1;}
            if (h === 360) {h = 359;}

            // Rebase the h,s,v values
            h = h/360;
            var s = hsv[1]/100,
                v = hsv[2]/100;

            var h_i = Math.floor(h*6),
            f = h * 6 - h_i,
            p = v * (1 - s),
            q = v * (1 - f*s),
            t = v * (1 - (1 - f)*s),
            r = 256,
            g = 256,
            b = 256;

            switch(h_i) {
            case 0: r = v; g = t; b = p;  break;
            case 1: r = q; g = v; b = p;  break;
            case 2: r = p; g = v; b = t;  break;
            case 3: r = p; g = q; b = v;  break;
            case 4: r = t; g = p; b = v;  break;
            case 5: r = v; g = p; b = q;  break;
            }

            var result = [Math.floor(r*255), Math.floor(g*255), Math.floor(b*255)];
            return result;
        }

        function HSVtoHSL (hsv) {
            var h = hsv[0],
            s = hsv[1]/100,
            v = hsv[2]/100,
            k = (2-s)*v;

            return [
            h,
            Math.round(s*v / (k<1 ? k : 2-k) * 10000) / 100,
            k/2 * 100
            ];
        }

        function stringToInteger (string) {
            var total = 0
            for (var i = 0; i !== string.length; i++) {
            if (total >= Number.MAX_SAFE_INTEGER) break;
            total += string.charCodeAt(i)
            }
            return total
        }

        return randomColor;
        }));

        function componentToHex(c) {
            var hex = c.toString(16);
            return hex.length == 1 ? "0" + hex : hex;
        }

        function rgbToHex(r, g, b) {
            return "#" + componentToHex(r) + componentToHex(g) + componentToHex(b);
        }
    </script>
  </body>
</html>
