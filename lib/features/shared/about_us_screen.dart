import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/localization/app_localizations.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.about),
        backgroundColor: const Color(0xFF3F51B5),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.code_rounded,
                size: 70,
                color: Color(0xFF3F51B5),
              ),
              const SizedBox(height: 24),
              Text(
                isAr ? 'تم برمجة هذا التطبيق بواسطة' : 'This application was programmed by',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildDevList([
                'محمد المدي',
                'وائل الجبري',
                'محمد الشعيبي',
                'محمد شنطر',
                'صفوان الحاج',
                'عبدالحسيب السماوي',
              ]),
              const SizedBox(height: 48),
              Container(
                height: 1,
                width: 100,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 32),
              Text(
                isAr ? 'للتواصل' : 'Contact Us',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialIcon(
                    icon: Icons.phone,
                    color: Colors.green[600]!,
                    onTap: () => _launchUrl('tel:+967778262576'
                        ''),
                  ),
                  const SizedBox(width: 24),
                  _buildSocialIcon(
                    icon: FontAwesomeIcons.instagram,
                    color: const Color(0xFFE1306C),
                    onTap: () => _launchUrl('https://instagram.com'),
                  ),
                  const SizedBox(width: 24),
                  _buildSocialIcon(
                    icon: FontAwesomeIcons.facebook,
                    color: const Color(0xFF1877F2),
                    onTap: () => _launchUrl('https://facebook.com'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () => _launchUrl('mailto:doctormohammed7788n@gmail.com'),
                child: const Text(
                  'doctormohammed7788n@gmail.com',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF3F51B5),
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDevList(List<String> names) {
    return Column(
      children: names.map((name) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Text(
          name,
          style: const TextStyle(
            fontSize: 19,
            color: Color(0xFF444444),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
      )).toList(),
    );
  }

  Widget _buildSocialIcon({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.1), width: 1),
        ),
        child: Center(
          child: FaIcon(
            icon,
            color: color,
            size: 26,
          ),
        ),
      ),
    );
  }
}
