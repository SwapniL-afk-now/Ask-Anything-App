import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_state.dart';
import 'results_screen.dart';

class TopicScreen extends StatefulWidget {
  @override
  _TopicScreenState createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen> {
  final TextEditingController _topicController = TextEditingController();

  final List<String> _suggestions = [
    'Quantum Computing',
    'Artificial Intelligence',
    'Blockchain Technology',
  ];

  @override
  void initState() {
    super.initState();
    _topicController.addListener(() {
      setState(() {});
    });
  }

  void _onAnalyze() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) return;

    final appState = Provider.of<AppState>(context, listen: false);
    appState.setTopic(topic);

    final success = await appState.analyzeCurrentTopic();

    if (success && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResultsScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appState.errorMessage ?? 'Failed to analyze topic')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final hasTopic = _topicController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Center(
          child: Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
            child: Row(
              children: [
                Expanded(flex: 2, child: Container(decoration: BoxDecoration(color: const Color(0xFF1392EC), borderRadius: BorderRadius.circular(2)))),
                Expanded(flex: 1, child: Container()),
              ],
            ),
          ),
        ),
        actions: [const SizedBox(width: 48)],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1392EC).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: const Color(0xFF1392EC).withOpacity(0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.person, color: Color(0xFF0B6CB3), size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Perspective: ',
                                  style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF0B6CB3), fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  appState.selectedProfession,
                                  style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF0B6CB3), fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: const Icon(Icons.edit, color: Color(0xFF0B6CB3), size: 16),
                                )
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        Text(
                          "What do you want to explore?",
                          style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF111518), height: 1.2),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "We'll tailor the answer to your expertise.",
                          style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B)),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F7F8),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.transparent, width: 2),
                            boxShadow: [
                              BoxShadow(color: Colors.grey.shade300, blurRadius: 4, offset: const Offset(0, 2))
                            ]
                          ),
                          child: Stack(
                            children: [
                              TextField(
                                controller: _topicController,
                                autofocus: true,
                                maxLines: null,
                                decoration: InputDecoration(
                                  hintText: "Type a concept, problem, or topic here...",
                                  hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                                style: GoogleFonts.inter(fontSize: 18, color: const Color(0xFF111518)),
                              ),
                              Positioned(
                                bottom: 12,
                                right: 12,
                                child: Icon(Icons.edit_note, color: const Color(0xFF1392EC).withOpacity(0.4), size: 28),
                              )
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        Text(
                          "SUGGESTED TOPICS",
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF64748B), letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 12),
                        
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _suggestions.map((topic) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () {
                                    _topicController.text = topic;
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      topic,
                                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF111518)),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: (hasTopic && !appState.isLoading) ? _onAnalyze : null,
                      icon: const Icon(Icons.analytics, color: Colors.white),
                      label: Text(
                        'Analyze & Explain',
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1392EC),
                        disabledBackgroundColor: const Color(0xFF1392EC).withOpacity(0.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            if (appState.isLoading)
              Container(
                color: Colors.white.withOpacity(0.8),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Color(0xFF1392EC)),
                      const SizedBox(height: 16),
                      Text("Analyzing Topic...", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF1392EC))),
                      const SizedBox(height: 8),
                      Text("This usually takes 5-10 seconds", style: GoogleFonts.inter(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
