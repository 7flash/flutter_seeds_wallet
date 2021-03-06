import 'package:seeds/v2/components/amount_entry/interactor/viewmodels/amount_entry_state.dart';
import 'package:seeds/v2/datasource/local/settings_storage.dart';
import 'package:seeds/v2/domain-shared/ui_constants.dart';

String handleInfoRowText({
  required CurrencyInput currentCurrencyInput,
  required String fiatToSeeds,
  required String seedsToFiat,
}) {
  switch (currentCurrencyInput) {
    case CurrencyInput.FIAT:
      return fiatToSeeds + " " + currencySeedsCode;
    case CurrencyInput.SEEDS:
      return seedsToFiat + " " + settingsStorage.selectedFiatCurrency.toString();
  }
}