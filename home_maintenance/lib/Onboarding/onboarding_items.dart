
import 'onboarding_info.dart';

class OnboardingItems {
  static final List<OnboardingInfo> list = [
    OnboardingInfo(
      title: 'Welcome to Homely',
      description: 'Homely is a simple app that helps you keep track of your home maintenance tasks.',
      imageUrl: 'assets/images/welcome.png',
    ),
    OnboardingInfo(
      title: 'Professional Home Maintenance',
      description: 'We have professionals ready and able to assist you',
      imageUrl: 'assets/images/pro.png',
    ),
    OnboardingInfo(
      title: 'Get Notified',
      description: 'Receive notifications when a task is due.',
      imageUrl: 'assets/images/book.png',
    ),
    OnboardingInfo(
      title: '',
      description: "Let's find your professional together, shall we?",
      imageUrl: 'assets/images/splash.png',
    ),
  ];
}