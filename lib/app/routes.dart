import 'package:flutter/material.dart';
import 'package:petzero/features/splash/splash_page.dart';
import 'package:petzero/features/home/home_page.dart';
import 'package:petzero/features/camera/camera_page.dart';
import 'package:petzero/features/ranking/ranking_page.dart';
import 'package:petzero/features/community/community_page.dart';
import 'package:petzero/features/walk/walk_page.dart';

class AppRoutes {
  static const splash = '/';
  static const home = '/home';
  static const camera = '/camera';
  static const ranking = '/ranking';
  static const community = '/community';
  static const walk = '/walk';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case camera:
        final args = settings.arguments as Map<String, dynamic>?;
        final recordType =
            args?['recordType'] as RecordType? ?? RecordType.poop;
        return MaterialPageRoute(
          builder: (_) => CameraPage(recordType: recordType),
        );
      case ranking:
        return MaterialPageRoute(builder: (_) => const RankingPage());
      case community:
        return MaterialPageRoute(builder: (_) => const CommunityPage());
      case walk:
        return MaterialPageRoute(builder: (_) => const WalkPage());
      default:
        return MaterialPageRoute(
          builder:
              (_) =>
                  const Scaffold(body: Center(child: Text('페이지를 찾을 수 없습니다'))),
        );
    }
  }
}
