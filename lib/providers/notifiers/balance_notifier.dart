

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeds/providers/services/http_service.dart';
import 'package:seeds/v2/datasource/remote/model/balance_model.dart';

class BalanceNotifier extends ChangeNotifier {
  BalanceModel? balance;

  HttpService? _http;

  static BalanceNotifier of(BuildContext context, {bool listen = false}) => Provider.of<BalanceNotifier>(context, listen: listen);

  void update({HttpService? http}) {
    _http = http;
  }

  Future<void> fetchBalance() {
    return _http!.getBalance().then((result) {
      balance = result;
      notifyListeners();
    });
  }
}
