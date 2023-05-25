import 'package:flutter/material.dart';

import '../../../../domain/service_model.dart';
import '../../../pages/dashboard/home/services/service_product_screen.dart';
import '../../../pages/dashboard/home/services/service_inactive_screen.dart';

class SingleServiceComponent extends StatelessWidget {
  final SingleServiceModel service;

  const SingleServiceComponent(this.service, {Key key}) : super(key: key);

  Widget _getServiceImageWidget(double maxHeight) => SizedBox(
        width: double.infinity,
        height: maxHeight * .4,
        child: FadeInImage.assetNetwork(
          fit: BoxFit.contain,
          placeholder: 'assets/images/app_logo.png',
          image: service.imageUrl,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: theme.primaryColor,
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: () => service.isActive
                ? Navigator.of(context).pushNamed(
                    ServiceProductScreen.routeName,
                    arguments: service.serviceId,
                  )
                : Navigator.of(context).push(
                    MaterialPageRoute(builder: (BuildContext context) {
                      return ServiceNonActiveStatus(
                        serviceMessage: service.message,
                        serviceName: service.serviceName,
                      );
                    }),
                  ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _getServiceImageWidget(constraints.maxHeight),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    service.serviceName,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.clip,
                    style: theme.textTheme.titleLarge
                        .copyWith(color: theme.primaryColor, fontSize: 14),
                  ),
                ),
                Text(
                  'Min ${service.minTime} hours',
                  style: theme.textTheme.titleSmall.copyWith(fontSize: 12),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
