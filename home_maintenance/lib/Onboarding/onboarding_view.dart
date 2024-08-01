import 'package:flutter/material.dart';
import 'package:home_maintenance/Onboarding/onboarding_items.dart';
import 'package:home_maintenance/constants/colors.dart';
import 'package:home_maintenance/home.dart';
import 'package:home_maintenance/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';


class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final pageController = PageController();
  final controller = OnboardingItems();

  bool isLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: isLastPage? getStarted() : Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // skip button
            TextButton(
              onPressed: () =>
                  pageController.jumpToPage(OnboardingItems.list.length - 1),
              child: const Text('Skip'),
            ),

            // page indicator
            SmoothPageIndicator(
              controller: pageController,
              count: OnboardingItems.list.length,
              onDotClicked: (index) => pageController.animateToPage(index,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeIn),
              effect: const WormEffect(
                dotColor: Colors.black26,
                activeDotColor: AppColors.primaryColor,
                dotHeight: 8,
                dotWidth: 8,
              ),
            ),

            // next button
            TextButton(
              onPressed: () => pageController.nextPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeIn),
              child: const Text('Next'),
            ),
          ],
        ),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15),
        child: PageView.builder(
          onPageChanged: (index) =>setState(() {
            isLastPage = index == OnboardingItems.list.length - 1;
          }),
          controller: pageController,
          itemCount: OnboardingItems.list.length,
          itemBuilder: (context, index) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(OnboardingItems.list[index].imageUrl ?? ''),
                const SizedBox(height: 15),
                Text(OnboardingItems.list[index].title,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                Text(
                  OnboardingItems.list[index].description,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget getStarted() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      width: MediaQuery.of(context).size.width * 9,
      height: 55,
      child: TextButton(
        onPressed: () async {
          final press = await SharedPreferences.getInstance();
          press.setBool('onboarding', true);

          if(!mounted) return;
          Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
        },
        child: const Text(
          'Get Started',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
       
      ));

  }
}
