import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_state.dart';
import '../services/settings_service.dart';
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
    _promptSettingsIfNeeded();
  }

  Future<void> _promptSettingsIfNeeded() async {
    final configured = await SettingsService.isConfigured();
    if (!configured && mounted) {
      // Show settings dialog on first launch
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _showSettingsDialog();
      });
    }
  }

  void _showSettingsDialog() async {
    final currentIp = await SettingsService.getBackendIp();
    final currentPort = await SettingsService.getBackendPort();
    final ipController = TextEditingController(text: currentIp);
    final portController = TextEditingController(text: currentPort);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: currentIp.isNotEmpty,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Backend Server',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter the IP address of the laptop running the backend server.',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ipController,
              decoration: InputDecoration(
                labelText: 'IP Address',
                hintText: '192.168.1.100',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.computer),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: portController,
              decoration: InputDecoration(
                labelText: 'Port',
                hintText: '8000',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.numbers),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          if (currentIp.isNotEmpty)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.inter()),
            ),
          ElevatedButton(
            onPressed: () async {
              final ip = ipController.text.trim();
              if (ip.isEmpty) return;
              await SettingsService.setBackendIp(ip);
              await SettingsService.setBackendPort(
                  portController.text.trim().isEmpty ? '8000' : portController.text.trim());
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1392EC),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Save', style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );
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
        leading: const SizedBox(width: 48),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF637588)),
            onPressed: _showSettingsDialog,
            tooltip: 'Backend settings',
          ),
        ],
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
