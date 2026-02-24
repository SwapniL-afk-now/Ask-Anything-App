import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_state.dart';
import '../models/five_w_model.dart';
import 'profession_screen.dart';

class ResultsScreen extends StatelessWidget {
  
  Color _getComplexityColor(String complexity) {
    if (complexity.toLowerCase() == 'basic') return Colors.green;
    if (complexity.toLowerCase() == 'advanced') return Colors.red;
    return Colors.orange;
  }

  Widget _buildQASection(String title, IconData icon, Color color, String content) {
    // Strip simple markdown bolding for native display, or use a rich text renderer ideally.
    // Here we'll just do a very basic clean up.
    String cleanContent = content.replaceAll('**', '');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  cleanContent,
                  style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFF475569), height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, duration: 400.ms);
  }

  Widget _buildSmallCard(String title, IconData icon, String content) {
    String cleanContent = content.replaceAll('**', '');
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey.shade400, size: 20),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            cleanContent,
            style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF475569), height: 1.5),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1, duration: 400.ms);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final result = appState.currentResult;
    
    if (result == null) {
      return const Scaffold(body: Center(child: Text("No results")));
    }

    final complexityColor = _getComplexityColor(result.complexity);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white.withOpacity(0.95),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Topic Analysis",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Color(0xFF1392EC)),
            onPressed: () {
              appState.reset();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => ProfessionScreen()),
                (Route<dynamic> route) => false,
              );
            },
          )
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appState.topic,
                  style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A), height: 1.1),
                ).animate().fadeIn(duration: 300.ms),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1392EC).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF1392EC).withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.person, size: 16, color: Color(0xFF1392EC)),
                          const SizedBox(width: 6),
                          Text(
                            "${appState.selectedProfession} Perspective",
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1392EC)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: complexityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: complexityColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.equalizer, size: 16, color: complexityColor),
                          const SizedBox(width: 6),
                          Text(
                            result.complexity,
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: complexityColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
                
                const SizedBox(height: 24),
                
                _buildQASection("What is it?", Icons.help, const Color(0xFF1392EC), result.answers.what),
                _buildQASection("How does it work?", Icons.settings, const Color(0xFF6366F1), result.answers.how),
                _buildQASection("Why it matters?", Icons.lightbulb, const Color(0xFF10B981), result.answers.why),
                
                const SizedBox(height: 8),
                _buildSmallCard("Who", Icons.group, result.answers.who),
                const SizedBox(height: 16),
                _buildSmallCard("Where", Icons.location_on, result.answers.where),
                const SizedBox(height: 16),
                _buildSmallCard("When", Icons.schedule, result.answers.when),
                
                const SizedBox(height: 100), // padding for bottom bar
              ],
            ),
          ),
          
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    const Color(0xFFF8FAFC),
                    const Color(0xFFF8FAFC).withOpacity(0.8),
                    const Color(0xFFF8FAFC).withOpacity(0.0),
                  ],
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => ProfessionScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
                icon: const Icon(Icons.tune, color: Color(0xFF334155)),
                label: Text(
                  "Adjust Role",
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF334155)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF334155),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300)
                  ),
                  elevation: 2,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
