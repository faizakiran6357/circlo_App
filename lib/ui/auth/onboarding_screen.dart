
import 'package:circlo_app/ui/auth/login_screen.dart';
import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _pageIndex = 0;

  final List<Map<String, String>> _pages = [
    {
      "title": "Exchange Goods Easily",
      "desc": "List items you no longer need and find what others offer nearby."
    },
    {
      "title": "Build Community",
      "desc": "Connect with people around you and promote reuse and sustainability."
    },
    {
      "title": "Earn GoodPoints",
      "desc": "Get rewarded for every exchange and your eco-friendly actions!"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _pageIndex = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.recycling, size: 120, color: kGreen),
                      const SizedBox(height: 30),
                      Text(_pages[i]['title']!,
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      Text(_pages[i]['desc']!,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                      color: _pageIndex == index ? kGreen : Colors.grey[300],
                      shape: BoxShape.circle),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: kGreen,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  if (_pageIndex == _pages.length - 1) {
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                  } else {
                    _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  }
                },
                child: Text(_pageIndex == _pages.length - 1 ? "Get Started" : "Next"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
