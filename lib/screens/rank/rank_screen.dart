import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gbsw_capstone_appsters/const/color.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RankScreen extends StatefulWidget {
  final void Function() onNavigateToHome;

  const RankScreen({
    super.key,
    required this.onNavigateToHome,
  });

  @override
  State<RankScreen> createState() => _RankScreenState();
}

class _RankScreenState extends State<RankScreen> {
  bool isLoading = true;
  Map<String, dynamic>? rankingData;
  int currentPage = 0;
  static const int itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    checkRankAvailability();
  }

  Future<void> checkRankAvailability() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        throw Exception("Access Token이 없습니다.");
      }

      final String? baseUrl = dotenv.env['SERVER_URL'];
      const String endpoint = '/quiz/student/best-scores';
      final String url = '$baseUrl$endpoint';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data == null || data.isEmpty) {
          _showNoRankingsDialog();
          return;
        } else {
          fetchRankings(); // 데이터가 존재하면 랭킹 가져오기
        }
      } else {
        throw Exception('랭킹 데이터를 확인하지 못했습니다.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      Navigator.pop(context); // 오류 발생 시 이전 화면으로 이동
    }
  }

  Future<void> _showNoRankingsDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('랭킹 데이터 없음'),
        content: const Text('랭크로 진입이 안됩니다.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onNavigateToHome();
            },
            child: const Text("확인"),
          ),
        ],
      ),
    );
  }

  Future<void> fetchRankings() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        throw Exception("Access Token이 없습니다.");
      }
      final String? baseUrl = dotenv.env['SERVER_URL'];
      const String endpoint = '/quiz/rankings/overall';
      final String url = '$baseUrl$endpoint';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          rankingData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('랭킹 데이터를 불러오지 못했습니다.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  int get totalPages {
    if (rankingData == null) return 0;
    final rankings = rankingData!['rankings'] as List;
    return ((rankings.length - 3) / itemsPerPage).ceil();
  }

  List<Map<String, dynamic>> get currentPageItems {
    if (rankingData == null) return [];
    final rankings = rankingData!['rankings'] as List;
    if (rankings.length <= 3) return [];

    final startIndex = 3 + (currentPage * itemsPerPage);
    final endIndex = startIndex + itemsPerPage;
    final pageItems = rankings.skip(startIndex).take(itemsPerPage).toList();

    return List<Map<String, dynamic>>.from(pageItems);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: Image.asset(
            'assets/images/logo.png',
            scale: 1.8,
          ),
        ),
      );
    }

    if (rankingData == null) {
      return const Scaffold(
        body: Center(child: Text('랭킹 데이터를 불러오지 못했습니다.')),
      );
    }

    final currentUser = rankingData!['currentUser'];
    final rankings = rankingData!['rankings'];

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // AppBar
                SliverAppBar(
                  expandedHeight: 120,
                  floating: false,
                  pinned: false,
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text(
                      '랭킹',
                      style: TextStyle(color: Colors.white),
                    ),
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primaryColor,
                            Color(0xFF1976D2),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Current User Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1976D2), AppColors.primaryColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundImage: currentUser['imageUri'] != null
                                  ? NetworkImage(currentUser['imageUri'])
                                  : const AssetImage(
                                          'assets/images/default.png')
                                      as ImageProvider,
                              backgroundColor: Colors.white,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentUser['nickName'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '점수: ${currentUser['score']}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  '#${currentUser['rank']}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const Text(
                                  '내 순위',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Top 3 Section
                if (rankings.length >= 3)
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            'TOP 3',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildTopThreeCard(rankings[1], 2),
                              _buildTopThreeCard(rankings[0], 1),
                              _buildTopThreeCard(rankings[2], 3),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                // Remaining Rankings
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= currentPageItems.length) return null;
                        final rank = currentPageItems[index];

                        return Card(
                          color: AppColors.basicColor,
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 2,
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 25,
                              backgroundImage: rank['imageUri'] != null
                                  ? NetworkImage(rank['imageUri'])
                                  : const AssetImage(
                                          'assets/images/default.png')
                                      as ImageProvider,
                              backgroundColor: Colors.white,
                            ),
                            title: Text(
                              rank['nickName'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text('점수: ${rank['score']}'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '#${rank['rank']}',
                                style: const TextStyle(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: currentPageItems.length,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Pagination Controls
          if (totalPages > 0)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: currentPage > 0
                        ? () => setState(() => currentPage--)
                        : null,
                  ),
                  for (int i = 0; i < totalPages; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: currentPage == i
                              ? AppColors.primaryColor
                              : Colors.grey[200],
                          minimumSize: const Size(40, 40),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () => setState(() => currentPage = i),
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            color:
                                currentPage == i ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: currentPage < totalPages - 1
                        ? () => setState(() => currentPage++)
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopThreeCard(Map<String, dynamic> player, int position) {
    final Color borderColor = position == 1
        ? Colors.amber
        : position == 2
            ? Colors.grey[300]!
            : Colors.brown[300]!;

    return Card(
      color: AppColors.basicColor,
      elevation: position == 1 ? 8 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: borderColor, width: 2),
      ),
      child: Container(
        width: position == 1 ? 120 : 100,
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                CircleAvatar(
                  radius: position == 1 ? 35 : 30,
                  backgroundImage: player['imageUri'] != null
                      ? NetworkImage(player['imageUri'])
                      : const AssetImage('assets/images/default.png')
                          as ImageProvider,
                  backgroundColor: Colors.white,
                ),
                Icon(
                  Icons.workspace_premium,
                  color: borderColor,
                  size: position == 1 ? 30 : 24,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              player['nickName'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: position == 1 ? 16 : 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${player['score']}점',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: position == 1 ? 14 : 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
