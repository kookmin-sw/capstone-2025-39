import 'package:flutter/material.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/services/like_service.dart'; // LikeService import
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

class LikedHistoryScreen extends StatefulWidget {
  const LikedHistoryScreen({super.key});

  @override
  State<LikedHistoryScreen> createState() => _LikedHistoryScreenState();
}

class _LikedHistoryScreenState extends State<LikedHistoryScreen> {
  List<String> likedPlaceNames = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLikedPlaces();
  }

  Future<void> fetchLikedPlaces() async {
    final auth = context.read<AuthProvider>();
    final url = 'http://15.165.95.8:8080/api/likes/my';

    try {
      final dio = LikeService.dio; // LikeService의 dio 사용
      final response = await dio.get(
        url,
        options: Options(headers: {
          'Authorization': 'Bearer ${auth.token}',
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data as List;
        setState(() {
          likedPlaceNames = data.map((e) => e.toString()).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print('좋아요 목록 불러오기 실패: $e');
      setState(() => isLoading = false);
    }
  }

  // 좋아요 취소 메세지
  Future<void> toggleLikeWithConfirm(String placeName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('좋아요 취소'),
        content: Text('$placeName 좋아요를 취소하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('아니오'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('네'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final auth = context.read<AuthProvider>();
    final token = 'Bearer ${auth.token}';

    final result = await LikeService.toggleLike(
      placeName: placeName,
      token: token,
      shouldLike: false, // 좋아요 취소
    );

    if (!result) {
      setState(() {
        likedPlaceNames.remove(placeName);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$placeName 좋아요가 취소되었습니다')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$placeName 좋아요 취소 실패')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    if (likedPlaceNames.isEmpty) {
      return const Center(child: Text('좋아요 한 장소가 없습니다.'));
    }

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GridView.builder(
        itemCount: likedPlaceNames.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.5,
        ),
        itemBuilder: (context, index) {
          final placeName = likedPlaceNames[index];

          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    placeName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () => toggleLikeWithConfirm(placeName),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
