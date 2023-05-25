import 'package:flutter/material.dart';

import '../../../../domain/service_model.dart';
import '../../../pages/dashboard/home/services/service_inactive_screen.dart';
import '../../../pages/dashboard/home/services/services_list_screen.dart';

class MultiServiceComponent extends StatelessWidget {
  final MultiServiceModel service;

  const MultiServiceComponent(this.service, {Key key}) : super(key: key);

  Widget _getServiceImageWidget(double maxHeight) => SizedBox(
        width: double.infinity,
        height: maxHeight * 0.3,
        child: FadeInImage.assetNetwork(
          fit: BoxFit.contain,
          placeholder: 'assets/images/app_logo.png',
          image: service.imageUrl,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.2,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.primaryColor,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => service.isActive
            ? Navigator.of(context)
                .pushNamed(ServiceListScreen.routeName, arguments: service)
            : Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return ServiceNonActiveStatus(
                      serviceMessage: service.message,
                      serviceName: service.parentName,
                    );
                  },
                ),
              ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _getServiceImageWidget(size.height * 0.15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              child: Text(
                service.parentName,
                textAlign: TextAlign.center,
                overflow: TextOverflow.clip,
                style: theme.textTheme.titleLarge.copyWith(
                  color: theme.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
