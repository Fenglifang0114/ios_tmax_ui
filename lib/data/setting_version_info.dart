import 'package:flutter/material.dart';
import 'package:t_max/pages/home_page_config.dart';
import 'package:t_max/pages/home_page_industry.dart';

import '../pages/home_page_retail.dart';

const int tConfig = 1;
const int tIndustry = 2;
const int tRetail = 3;
int mySystemVersion = tRetail;

class SystemVersionInfo {
  Widget getHomePage(int mySystemVersion) {
    if (mySystemVersion == tConfig) {
      return const HomePage();
    } else if (mySystemVersion == tIndustry) {
      return const IndustryHomePage();
    } else {
      return const RetailHomePage();
    }
  }

  String getTitle(int mySystemVersion) {
    if (mySystemVersion == tConfig) {
      return "T-CONFIG";
    } else if (mySystemVersion == tIndustry) {
      return "T-Industrial";
    } else {
      return "T-RETAIL";
    }
  }
}

SystemVersionInfo mySystemVersionInfo = SystemVersionInfo();
