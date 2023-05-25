// ignore_for_file: unused_field

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class BannerCarousel extends StatefulWidget {
  final List<String> imagesUrl;
  final int length;
  const BannerCarousel(this.imagesUrl, this.length, {Key key})
      : super(key: key);

  @override
  BannerCarouselState createState() => BannerCarouselState();
}

class BannerCarouselState extends State<BannerCarousel> {
  int _index = 0;
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.orientation == Orientation.portrait
        ? mediaQuery.size.height * .25
        : mediaQuery.size.height > 1000
            ? mediaQuery.size.height * .4
            : mediaQuery.size.height * 0.4;

    return Column(
      children: [
        CarouselSlider.builder(
          options: CarouselOptions(
            initialPage: 0,
            autoPlay: true,
            height: height,
            pauseAutoPlayOnTouch: true,
            enableInfiniteScroll: true,
            viewportFraction: 0.9,
            autoPlayCurve: Curves.easeIn,
            onPageChanged: (int i, carouselPageChangedReason) {
              setState(() {
                _index = i;
              });
            },
          ),
          itemCount: widget.imagesUrl.length,
          itemBuilder: (ctx, index, i) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: FadeInImage.assetNetwork(
                  fit: BoxFit.fill,
                  image: widget.imagesUrl[index],
                  placeholder:
                      'assets/images/placeholders/banner_placeholder.jpg',
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
