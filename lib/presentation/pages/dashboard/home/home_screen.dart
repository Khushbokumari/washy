import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scroll_indicator/scroll_indicator.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:washry/application/auth.dart';
import '../../../../domain/service_model.dart';
import '../../../../application/banners.dart';
import '../../../../application/cart.dart';
import '../../../../application/locations.dart';
import '../../../../application/services.dart';
import '../../../../presentation/pages/dashboard/dashboard_screen.dart';
import '../../location/location_search_screen.dart';
import '../../../components/cart/cart_icon_button.dart';
import '../../../components/home/banner_carousel.dart';
import '../../../components/home/services/service_card.dart';
import '../../../components/home/services/service_node_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  ScrollController scrollController = ScrollController();
  ScrollController verticalScrollController = ScrollController();
  ScrollController horizontalScrollController = ScrollController();
  double width = 0.0;
  double height = 0.0;

  Widget _getAppbar(BuildContext context, LocationProvider locationData) =>
      AppBar(
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.all(5.0),
          child: _getLocationSelectionWidget(context, locationData),
        ),
        actions: const [CartIconButton()],
      );

  Widget _getLocationSelectionWidget(
      BuildContext context, LocationProvider locationData) {
    return GestureDetector(
      onTap: () => _locationChangeCallback(context),
      child: Row(
        children: [
          const Icon(Icons.home),
          const SizedBox(
            width: 5.0,
          ),
          Text(
            locationData.savedLocation.locality,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                .copyWith(color: Colors.white),
          ),
          const SizedBox(
            width: 5.0,
          ),
          const Icon(
            Icons.expand_more,
            size: 25.0,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Future<void> _locationChangeCallback(BuildContext context) async {
    var didUserChooseLocation =
        await Navigator.of(context).pushNamed(LocationSearchScreen.routeName);
    if (didUserChooseLocation) {
      Provider.of<CartProvider>(context, listen: false).clearCart();
      Navigator.of(context).pushReplacementNamed(DashboardScreen.routeName);
    }
  }

  String uid = "";
  var bannerData;
  var locationData;
  var services;

  @override
  void initState() {
    bannerData = Provider.of<BannerProvider>(context, listen: false);
    locationData = Provider.of<LocationProvider>(context, listen: false);
    services = Provider.of<ServiceProvider>(context, listen: false);
    scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    Orientation orientation = MediaQuery.of(context).orientation;
    final theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blue,
        appBar: _getAppbar(context, locationData),
        body: locationData.currentOperationLocation == null
            ? _locationNotAvailableWidget(theme)
            : _locationAvailableWidget(orientation, size),
      ),
    );
  }

  Widget _locationNotAvailableWidget(ThemeData theme) => Center(
        child: Container(
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Sorry :( We do not operate in this location',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    _launchWhatsApp();
                  },
                  child: const Text("Notify Me"),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _locationAvailableWidget(Orientation orientation, Size size) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(35),
        topRight: Radius.circular(35),
      ),
      child: Container(
        height: height,
        color: Colors.white,
        child: SingleChildScrollView(
          controller: verticalScrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 10, left: 20),
                child: Text(
                  'Welcome',
                  style: GoogleFonts.poppins(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 5),
              Container(
                margin: const EdgeInsets.only(left: 20),
                child: Text(
                  'Need Laundry Service ?',
                  style:
                      GoogleFonts.poppins(fontSize: 13, color: Colors.black45),
                ),
              ),
              const SizedBox(height: 5),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    SizedBox(
                      width: size.width * 0.95,
                      height: orientation == Orientation.landscape
                          ? size.height * 0.35
                          : size.height * 0.13,
                      child: _getServiceGridWidgetTwoTime(
                        context,
                        services.getTwoTimeService(),
                      ),
                    ),
                    services.getTwoTimeService().length >= 4
                        ? ScrollIndicator(
                            scrollController: scrollController,
                            width: 5.0 * services.getTwoTimeService().length,
                            height: 5,
                            indicatorWidth: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey[300],
                            ),
                            indicatorDecoration: BoxDecoration(
                              color: Colors.blue[900],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.only(top: 5, left: 20),
                child: Text(
                  'Offers & News',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: BannerCarousel(
                      bannerData.banners, bannerData.banners.length),
                ),
              ),
              SizedBox(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, left: 20),
                  child: Text(
                    'Other Services',
                    style: GoogleFonts.roboto(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              _getServiceGridWidgetOneTime(services.getOneTimeService()),
              Consumer<AuthProvider>(builder: (ctx, authData, _) {
                return FutureBuilder<bool>(
                    future: authData.isAuth(),
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox();
                      } else {
                        uid = authData.userId;
                        return snapshot.data
                            ? GestureDetector(
                                onTap: () {
                                  final RenderBox box =
                                      context.findRenderObject();
                                  String code = uid.toString().substring(0, 4);

                                  final String text =
                                      "https://play.google.com/store/apps/details?id=washry.com.example.washry  Referral Code = $code";

                                  Share.share(text,
                                      subject: code,
                                      sharePositionOrigin:
                                          box.localToGlobal(Offset.zero) &
                                              box.size);
                                },
                                child: SizedBox(
                                  height: orientation == Orientation.portrait
                                      ? height * .13
                                      : height * 0.2,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Row(
                                      children: [
                                        Column(
                                          children: [
                                            SizedBox(
                                              height: height * .08,
                                              child: Image.asset(
                                                'assets/images/app_logo.png',
                                                width: width * .13,
                                                height: height * .93,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          width: width * .02,
                                        ),
                                        SizedBox(
                                          width: width * .7,
                                          child: Column(
                                            children: [
                                              Container(
                                                alignment: Alignment.topLeft,
                                                width: width * .8,
                                                child: const Text(
                                                  "Help your friends get a safe service",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.blue,
                                                      fontSize: 17),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8),
                                                child: Container(
                                                  width: width * .8,
                                                  alignment: Alignment.topLeft,
                                                  child: const Text(
                                                    "Refer & earn upto "
                                                    '\u{20B9}'
                                                    "5,000",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black87,
                                                        fontSize: 17),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            SizedBox(
                                              height: height * .035,
                                            ),
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              size: 18,
                                              color: Colors.grey[600],
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox();
                      }
                    });
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _launchWhatsApp() async {
    String phoneNumber = '+918079013893';
    String message =
        "Hello, Please notify me Whenever your services will be starting in area.";
    var whatsappUrl = "whatsapp://send?phone=$phoneNumber&text=$message";
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl));
    } else {
      throw 'Could not launch $whatsappUrl';
    }
  }

  Widget _getServiceGridWidgetOneTime(List<ServiceModel> serviceList) {
    final mediaQuery = MediaQuery.of(context);
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: mediaQuery.orientation == Orientation.portrait
          ? const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.9,
            )
          : SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: mediaQuery.size.width / 4,
              childAspectRatio: 1.2 / 0.9,
            ),
      children: serviceList
          .map((item) {
            if (item is SingleServiceModel) {
              return SingleServiceComponent(item);
            } else if (item is MultiServiceModel) {
              return MultiServiceComponent(item);
            }
          })
          .toList()
          .cast<Widget>(),
    );
  }

  Widget _getServiceGridWidgetTwoTime(
      BuildContext context, List<ServiceModel> serviceList) {
    return ListView(
      controller: scrollController,
      scrollDirection: Axis.horizontal,
      children: serviceList
          .map((item) {
            if (item is SingleServiceModel) {
              return SingleServiceComponent(item);
            } else if (item is MultiServiceModel) {
              return MultiServiceComponent(item);
            }
          })
          .toList()
          .cast<Widget>(),
    );
  }
}
