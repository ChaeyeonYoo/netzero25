import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class KakaoMapWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final double zoom;
  final bool showMyLocation;
  final String apiKey;

  const KakaoMapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    this.zoom = 15,
    this.showMyLocation = true,
    required this.apiKey,
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
                print('카카오맵 로딩 진행률: $progress%');
              },
              onPageStarted: (String url) {
                print('카카오맵 페이지 시작: $url');
                setState(() {
                  _isLoading = true;
                });
              },
              onPageFinished: (String url) {
                print('카카오맵 페이지 완료: $url');
                setState(() {
                  _isLoading = false;
                });
              },
              onWebResourceError: (WebResourceError error) {
                print('카카오맵 오류: ${error.description}');
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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>카카오맵</title>
    <style>
        html, body {
            width: 100%;
            height: 100%;
            margin: 0;
            padding: 0;
            overflow: hidden;
        }
        #map {
            width: 100%;
            height: 100%;
        }
        .loading {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            color: #333;
            font-size: 16px;
            background: rgba(255,255,255,0.9);
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.2);
        }
    </style>
</head>
<body>
    <div id="map">
        <div class="loading">카카오맵을 불러오는 중...</div>
    </div>
    
    <script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=${widget.apiKey}&libraries=services"></script>
    <script>
        try {
            console.log('카카오맵 초기화 시작');
            
            var container = document.getElementById('map');
            var options = {
                center: new kakao.maps.LatLng(${widget.latitude}, ${widget.longitude}),
                level: ${widget.zoom}
            };
            
            console.log('지도 옵션:', options);
            
            var map = new kakao.maps.Map(container, options);
            console.log('카카오맵 생성 완료');
            
            // 현재 위치 마커
            var currentLocationMarker = new kakao.maps.Marker({
                position: new kakao.maps.LatLng(${widget.latitude}, ${widget.longitude})
            });
            currentLocationMarker.setMap(map);
            console.log('현재 위치 마커 추가');
            
            // 쓰레기통 마커들 (예시)
            var trashBinPositions = [
                new kakao.maps.LatLng(${widget.latitude + 0.001}, ${widget.longitude + 0.001}),
                new kakao.maps.LatLng(${widget.latitude - 0.001}, ${widget.longitude + 0.001}),
                new kakao.maps.LatLng(${widget.latitude + 0.001}, ${widget.longitude - 0.001}),
                new kakao.maps.LatLng(${widget.latitude - 0.001}, ${widget.longitude - 0.001})
            ];
            
            trashBinPositions.forEach(function(position, index) {
                var marker = new kakao.maps.Marker({
                    position: position,
                    icon: new kakao.maps.MarkerImage(
                        'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTYgMTlWMjFIMThWMTlIMjBWMThIMTlWMTJIMTVWMTlIMTNWMTJIOFYxOUg3VjE4SDZWMjFaIiBmaWxsPSIjNEZBRjUwIi8+CjxwYXRoIGQ9Ik0xMCAxMlYxOUgxNFYxMkgxMFoiIGZpbGw9IndoaXRlIi8+Cjwvc3ZnPgo=',
                        new kakao.maps.Size(24, 24)
                    )
                });
                marker.setMap(map);
                console.log('쓰레기통 마커 ' + (index + 1) + ' 추가');
            });
            
            // 현재 위치 표시 (브라우저 지원 시)
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(function(position) {
                    var lat = position.coords.latitude;
                    var lng = position.coords.longitude;
                    var locPosition = new kakao.maps.LatLng(lat, lng);
                    
                    currentLocationMarker.setPosition(locPosition);
                    map.setCenter(locPosition);
                    console.log('현재 위치 업데이트:', lat, lng);
                }, function(error) {
                    console.log('위치 정보 가져오기 실패:', error.message);
                });
            } else {
                console.log('브라우저가 위치 정보를 지원하지 않습니다.');
            }
            
            console.log('카카오맵 초기화 완료');
            
        } catch (error) {
            console.error('카카오맵 초기화 오류:', error);
            document.getElementById('map').innerHTML = '<div class="loading">카카오맵 로딩 실패: ' + error.message + '</div>';
        }
    </script>
</body>
</html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('카카오맵을 불러오는 중...'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
