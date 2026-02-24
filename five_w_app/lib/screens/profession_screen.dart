import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_state.dart';
import 'topic_screen.dart';

class ProfessionScreen extends StatefulWidget {
  @override
  _ProfessionScreenState createState() => _ProfessionScreenState();
}

class _ProfessionScreenState extends State<ProfessionScreen> {
  String _selectedRole = '';
  final TextEditingController _customRoleController = TextEditingController();

  final List<Map<String, dynamic>> _roles = [
    {'title': 'Student', 'icon': Icons.school},
    {'title': 'Teacher', 'icon': Icons.cast_for_education},
    {'title': 'Engineer', 'icon': Icons.engineering},
    {'title': 'Doctor', 'icon': Icons.medical_services},
    {'title': 'Marketer', 'icon': Icons.campaign},
    {'title': 'Researcher', 'icon': Icons.biotech},
    {'title': 'Designer', 'icon': Icons.design_services},
    {'title': 'Developer', 'icon': Icons.code},
  ];

  @override
  void initState() {
    super.initState();
    _customRoleController.addListener(() {
      if (_customRoleController.text.isNotEmpty && _selectedRole.isNotEmpty) {
        setState(() {
          _selectedRole = '';
        });
      }
      setState(() {}); // allow button to update state
    });
  }

  void _onContinue() {
    final role = _customRoleController.text.isNotEmpty ? _customRoleController.text : _selectedRole;
    if (role.isNotEmpty) {
      Provider.of<AppState>(context, listen: false).setProfession(role);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TopicScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = _selectedRole.isNotEmpty || _customRoleController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {}, // Not needed for first screen unless closing app
        ),
        backgroundColor: Colors.transparent,
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
                Expanded(flex: 1, child: Container(decoration: BoxDecoration(color: const Color(0xFF1392EC), borderRadius: BorderRadius.circular(2)))),
                Expanded(flex: 2, child: Container()),
              ],
            ),
          ),
        ),
        actions: [const SizedBox(width: 48)],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Let's customize your experience.",
                      style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF111518)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Select your profession to get answers adapted to your specific needs.",
                      style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFF637588)),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: _roles.length,
                      itemBuilder: (context, index) {
                        final role = _roles[index];
                        final isSelected = _selectedRole == role['title'];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedRole = role['title'];
                              _customRoleController.clear();
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF1392EC).withOpacity(0.05) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF1392EC) : Colors.grey[200]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF1392EC) : const Color(0xFF1392EC).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    role['icon'],
                                    color: isSelected ? Colors.white : const Color(0xFF1392EC),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  role['title'],
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    color: isSelected ? const Color(0xFF1392EC) : Colors.black87,
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: TextField(
                        controller: _customRoleController,
                        decoration: InputDecoration(
                          hintText: "Or type your profession...",
                          hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
                          prefixIcon: Icon(Icons.edit, color: Colors.grey[400]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: hasSelection ? _onContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1392EC),
                    disabledBackgroundColor: const Color(0xFF1392EC).withOpacity(0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Continue',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
