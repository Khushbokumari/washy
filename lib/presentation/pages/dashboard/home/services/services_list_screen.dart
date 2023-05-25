import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:washry/domain/service_model.dart';
import '../../../cart/cart_screen.dart';
import 'service_inactive_screen.dart';
import '../../../../components/cart/cart_icon_button.dart';
import '../../../../components/home/banner_carousel.dart';

class ServiceListScreen extends StatefulWidget {
  static const String routeName = 'service-list-screen';

  const ServiceListScreen({Key ?key}) : super(key: key);

  @override
  ServiceListScreenState createState() => ServiceListScreenState();
}

class ServiceListScreenState extends State<ServiceListScreen> {
  MultiServiceModel node;
  bool init = true;
  BetterPlayerController _betterPlayerController;

  @override
  void dispose() {
    _betterPlayerController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (init) {
      init = false;
      node = ModalRoute.of(context).settings.arguments;
      BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        node.banners[0],
      );
      _betterPlayerController = BetterPlayerController(
        BetterPlayerConfiguration(
          errorBuilder: (context, errorMessage) {
            return const Center(
              child: Text(
                "Video is stuck in traffic. It'll be available soon",
                style: TextStyle(color: Colors.white),
              ),
            );
          },
          controlsConfiguration: const BetterPlayerControlsConfiguration(
            showControlsOnInitialize: false,
            enableSkips: false,
            enableOverflowMenu: false,
          ),
        ),
        betterPlayerDataSource: betterPlayerDataSource,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);
    final height = mediaQuery.orientation == Orientation.portrait
        ? mediaQuery.size.height * .25
        : mediaQuery.size.height > 1000
            ? mediaQuery.size.height * .4
            : mediaQuery.size.height * .3;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(node.parentName),
          actions: const <Widget>[CartIconButton()],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            node.isBannerVideo
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: height,
                      width: mediaQuery.size.width,
                      color: Colors.black,
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: BetterPlayer(
                          controller: _betterPlayerController,
                        ),
                      ),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(8.0),
                    child: BannerCarousel(node.banners, node.banners.length),
                  ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(2.0),
                gridDelegate: mediaQuery.orientation == Orientation.portrait
                    ? const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1 / 1,
                      )
                    : SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: mediaQuery.size.width / 5,
                        childAspectRatio: 1.2 / 0.9,
                      ),
                itemCount: node.children.length,
                itemBuilder: (ctx, index) {
                  var curr = node.children[index];
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.lightBlue,
                        width: 0.2,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        if (curr is SingleServiceModel) {
                          if (curr.isActive) {
                            Navigator.of(context).pushNamed(
                                CartScreen.routeName,
                                arguments: curr.serviceId);
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return ServiceNonActiveStatus(
                                  serviceMessage: curr.message,
                                  serviceName: curr.serviceName,
                                );
                              }),
                            );
                          }
                        } else if (curr is MultiServiceModel) {
                          if (curr.isActive) {
                            Navigator.of(context).pushNamed(
                              ServiceListScreen.routeName,
                              arguments: curr,
                            );
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return ServiceNonActiveStatus(
                                  serviceName: node.parentName,
                                  serviceMessage: node.message,
                                );
                              }),
                            );
                          }
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          FadeInImage.assetNetwork(
                            fit: BoxFit.contain,
                            height:
                                mediaQuery.orientation == Orientation.portrait
                                    ? mediaQuery.size.height / 5 * 0.3
                                    : mediaQuery.size.height / 5 * 0.8,
                            placeholder: 'assets/images/app_logo.png',
                            placeholderCacheWidth: 60,
                            placeholderCacheHeight: 60,
                            image: (curr is SingleServiceModel)
                                ? curr.imageUrl
                                : (curr as MultiServiceModel).imageUrl,
                          ),
                          FittedBox(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                (curr is SingleServiceModel)
                                    ? curr.serviceName
                                    : (curr as MultiServiceModel).parentName,
                                style: theme.textTheme.titleLarge.copyWith(
                                    color: theme.primaryColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          curr is SingleServiceModel
                              ? Text(
                                  '${curr.minTime} hours',
                                  style: theme.textTheme.titleSmall
                                      .copyWith(fontSize: 12),
                                )
                              : Container()
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
