
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportDetailsScreen extends StatefulWidget {
  final dynamic report;
  const ReportDetailsScreen({super.key, required this.report});

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  List<dynamic> comments = [];
  List<dynamic> reactions = [];
  String? selectedReaction;
  final commentController = TextEditingController();

  Map<String, List<String>> reactionMap = {};
  int? currentUserId;

  @override
  void initState() {
    super.initState();
    fetchComments();
    fetchReactions();

  }

  Future<Map<String, String>> getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> fetchComments() async {
    final headers = await getAuthHeaders();
    final prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getInt('userId');

    final response = await http.get(
      Uri.parse("http://10.0.2.2:8081/api/v1/comments/${widget.report['id']}"),
      headers: headers,
    );
    if (response.statusCode == 200) {
      setState(() {
        comments = jsonDecode(response.body);
      });
    } else {
      print("❌ Eroare comentarii: ${response.statusCode}");
    }
  }

  Future<void> fetchReactions() async {
    final headers = await getAuthHeaders();
    final response = await http.get(
      Uri.parse("http://10.0.2.2:8081/api/v1/reactions/${widget.report['id']}"),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = prefs.getInt('userId');


      final data = jsonDecode(response.body);
      reactionMap.clear();
      String? userReaction;

      for (var r in data) {
        final type = r['type'];
        final user = r['user'];
        final name = "${user['firstName']} ${user['lastName']}";
        if (!reactionMap.containsKey(type)) {
          reactionMap[type] = [];
        }
        reactionMap[type]!.add(name);

        if (user['id'] == currentUserId) {
          userReaction = type;
        }
      }

      setState(() {
        reactions = data;
        selectedReaction = userReaction;
      });
    } else {
      print("❌ Eroare reacții: ${response.statusCode}");
    }
  }


  Future<void> submitReaction(String type) async {
    final headers = await getAuthHeaders();

    if (selectedReaction == type) {
      final response = await http.delete(
        Uri.parse("http://10.0.2.2:8081/api/v1/reactions/${widget.report['id']}"),
        headers: headers,
      );
      if (response.statusCode == 200) {
        setState(() => selectedReaction = null);
        fetchReactions();
      } else {
        print("❌ Eroare stergere reacție: ${response.statusCode}");
      }
      return;
    }

    final response = await http.post(
      Uri.parse("http://10.0.2.2:8081/api/v1/reactions/${widget.report['id']}"),
      headers: headers,
      body: jsonEncode({"type": type}),
    );
    if (response.statusCode == 200) {
      setState(() => selectedReaction = type);
      fetchReactions();
    } else {
      print("❌ Eroare trimitere reacție: ${response.statusCode}");
    }
  }

  Future<void> submitComment() async {
    if (commentController.text.trim().isEmpty) return;
    final headers = await getAuthHeaders();
    final response = await http.post(
      Uri.parse("http://10.0.2.2:8081/api/v1/comments/${widget.report['id']}"),
      headers: headers,
      body: jsonEncode({"content": commentController.text.trim()}),
    );
    if (response.statusCode == 200) {
      commentController.clear();
      fetchComments();
    } else {
      print("❌ Eroare trimitere comentariu: ${response.statusCode}");
    }
  }


  Widget _reactionButton(String type, IconData icon, Color color) {
    final count = reactionMap[type]?.length ?? 0;
    final names = reactionMap[type] ?? [];

    return GestureDetector(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (_) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: const Color(0xffe1f8dc),
            child: Container(
              padding: const EdgeInsets.all(20),
              constraints: const BoxConstraints(maxHeight: 300),
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Users who gave $type",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff00695C),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: ListView.builder(
                        itemCount: names.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                const Icon(Icons.person, size: 18, color: Colors.green),
                                const SizedBox(width: 8),
                                Text(
                                  names[index],
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff00b09b),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },

      child: ElevatedButton.icon(
        onPressed: () => submitReaction(type),
        icon: Icon(icon, size: 18),
        label: Text("$type ($count)"),
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedReaction == type ? color : color.withOpacity(0.3),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }


  Widget _buildReactionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Reactions:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: [
            _reactionButton("LIKE", Icons.thumb_up, Colors.green),
            _reactionButton("DISLIKE", Icons.thumb_down, Colors.red),
            _reactionButton("CONFIRMED", Icons.check_circle, Colors.blue),
          ],
        ),
        const SizedBox(height: 10),
        Text("Total reactions: ${reactions.length}", style: const TextStyle(color: Colors.black87,fontSize: 16) ),
      ],
    );
  }
  Future<void> _deleteComment(int commentId) async {
    final headers = await getAuthHeaders();
    final response = await http.delete(
      Uri.parse("http://10.0.2.2:8081/api/v1/comments/$commentId"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      fetchComments();
    } else {
      print("❌ Eroare ștergere comentariu: ${response.statusCode}");
    }
  }


  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Comments:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),


        if (comments.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              "No comments yet. Be the first to comment!",
              style: TextStyle(fontStyle: FontStyle.italic,fontSize: 18),
            ),
          )
        else
          ...comments.map((comment) {
            final user = comment['user'];
            final userId = user['id'];
            final reportUserId = widget.report['user']['id'];
            final canDelete = (userId == currentUserId) || (currentUserId == reportUserId);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${user['firstName']} ${user['lastName']}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        if (canDelete)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () => _deleteComment(comment['id']),
                            tooltip: "Delete comment",
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment['content'],
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            );
          })
        ,


        const SizedBox(height: 10),
        TextField(
          controller: commentController,
          decoration: InputDecoration(
            hintText: 'Add a comment...',
            filled: true,
            fillColor: Colors.white,
            suffixIcon: IconButton(
              icon: const Icon(Icons.send),
              onPressed: submitComment,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }


  Widget _buildReportCard(dynamic report, String status, Color statusColor) {
    final user = report['user'];
    final String reporterName = user != null
        ? "${user['firstName'] ?? ''} ${user['lastName'] ?? ''}"
        : "Unknown";

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff70e1f5), Color(0xffffd194)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  report['title'] ?? 'No title',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                reporterName,
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),


          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 12, color: statusColor),
                const SizedBox(width: 6),
                Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 10),


          Text(report['description'] ?? 'No description', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 10),


          if (report['imageUrl'] != null && report['imageUrl'].toString().isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                "http://10.0.2.2:8081${report['imageUrl']}",
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final status = report['status'] ?? 'Unknown';
    Color statusColor = Colors.grey;
    if (status == 'Received') statusColor = Colors.blue;
    else if (status == 'In Progress') statusColor = Colors.orange;
    else if (status == 'Fixed') statusColor = Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff00b09b), Color(0xff96c93d)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffe1f8dc), Color(0xffc0e8a9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReportCard(report, status, statusColor),
              const SizedBox(height: 20),
              _buildReactionsSection(),
              const SizedBox(height: 20),
              _buildCommentSection(),
            ],
          ),
        ),
      ),
    );
  }
}
