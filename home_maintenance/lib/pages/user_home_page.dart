import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:home_maintenance/Components/service_categories.dart';

class HomeOwnerHomePage extends StatelessWidget {
  const HomeOwnerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> imageList = [
      "assets/images/salon.png",
      "assets/images/painter.png",
    ];
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            child: Column(
          children: [
            CarouselSlider.builder(
              itemCount: imageList.length,
              itemBuilder: (context, index, realIndex) {
                return Stack(
                  children: [
                    // image
                    Image.asset(
                      imageList[index],
                      width: double.infinity,
                      fit: BoxFit.cover,
                      height: MediaQuery.of(context).size.height / 3,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height / 3,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              colors: [Colors.black, Colors.transparent],
                              begin: Alignment.bottomCenter,
                              end: Alignment.center)),
                    ),
                    const Positioned(
                      bottom: 0,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 25.0, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Homely",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            Text(
                              "services",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
              options: CarouselOptions(
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 5),
                height: MediaQuery.of(context).size.height / 3,
                viewportFraction: 1.0,
                enableInfiniteScroll: true,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Service Categories",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  // view all
                  Text(
                    "View All",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey),
                  ),
                ],
              ),

              // service categories
            ),
            ServiceCategories(),
          ],
        )));
  }
}
