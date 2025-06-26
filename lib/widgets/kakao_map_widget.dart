import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class KakaoMapWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final double zoom;
  final bool showMyLocation;

  const KakaoMapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    this.zoom = 15,
    this.showMyLocation = true,
  });

  @override
  State<KakaoMapWidget> createState() => _KakaoMapWidgetState();
}

class _KakaoMapWidgetState extends State<KakaoMapWidget> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                // 로딩 진행률
              },
              onPageStarted: (String url) {
                setState(() {
                  _isLoading = true;
                });
              },
              onPageFinished: (String url) {
                setState(() {
                  _isLoading = false;
                });
              },
            ),
          )
          ..loadHtmlString(_getKakaoMapHtml());
  }

  String _getKakaoMapHtml() {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>카카오맵</title>
    <style>
        html, body {
            width: 100%;
            height: 100%;
            margin: 0;
            padding: 0;
        }
        #map {
            width: 100%;
            height: 100%;
        }
    </style>
</head>
<body>
    <div id="map"></div>
    <script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=f6fb9c1790ce2f7db1f2c120c6690a60"></script>
    <script>
        var container = document.getElementById('map');
        var options = {
            center: new kakao.maps.LatLng(${widget.latitude}, ${widget.longitude}),
            level: ${widget.zoom}
        };
        
        var map = new kakao.maps.Map(container, options);
        
        // 현재 위치 마커
        var currentLocationMarker = new kakao.maps.Marker({
            position: new kakao.maps.LatLng(${widget.latitude}, ${widget.longitude})
        });
        currentLocationMarker.setMap(map);
        
        // 쓰레기통 마커들 (예시)
        var trashBinPositions = [
            new kakao.maps.LatLng(${widget.latitude + 0.001}, ${widget.longitude + 0.001}),
            new kakao.maps.LatLng(${widget.latitude - 0.001}, ${widget.longitude + 0.001}),
            new kakao.maps.LatLng(${widget.latitude + 0.001}, ${widget.longitude - 0.001})
        ];
        
        trashBinPositions.forEach(function(position) {
            var marker = new kakao.maps.Marker({
                position: position,
                icon: new kakao.maps.MarkerImage(
                    'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTYgMTlWMjFIMThWMTlIMjBWMThIMTlWMTJIMTVWMTlIMTNWMTJIOFYxOUg3VjE4SDZWMjFaIiBmaWxsPSIjNEZBRjUwIi8+CjxwYXRoIGQ9Ik0xMCAxMlYxOUgxNFYxMkgxMFoiIGZpbGw9IndoaXRlIi8+Cjwvc3ZnPgo=',
                    new kakao.maps.Size(24, 24)
                )
            });
            marker.setMap(map);
        });
        
        // 현재 위치 표시 (브라우저 지원 시)
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(function(position) {
                var lat = position.coords.latitude;
                var lng = position.coords.longitude;
                var locPosition = new kakao.maps.LatLng(lat, lng);
                
                currentLocationMarker.setPosition(locPosition);
                map.setCenter(locPosition);
            });
        }
    </script>
</body>
</html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          Container(
            color: Colors.white,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
