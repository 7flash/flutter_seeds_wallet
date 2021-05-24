import 'package:seeds/v2/blocs/rates/viewmodels/rates_state.dart';
import 'package:seeds/v2/datasource/local/settings_storage.dart';
import 'package:seeds/v2/datasource/remote/model/balance_model.dart';
import 'package:seeds/v2/domain-shared/page_state.dart';
import 'package:seeds/v2/domain-shared/result_to_state_mapper.dart';
import 'package:seeds/v2/screens/explore_screens/invite/interactor/viewmodels/invite_state.dart';
import 'package:seeds/v2/utils/rate_states_extensions.dart';

class UserBalanceStateMapper extends StateMapper {
  InviteState mapResultToState(InviteState currentState, Result result, RatesState rateState) {
    if (result.isError) {
      return currentState.copyWith(pageState: PageState.failure, errorMessage: "Error loading current balance");
    } else {
      BalanceModel balance = result.asValue!.value as BalanceModel;
      String? selectedFiat = settingsStorage.selectedFiatCurrency;

      return currentState.copyWith(
        pageState: PageState.success,
        fiatAmount: rateState.fromSeedsToFiat(0, selectedFiat),
        availableBalance: balance,
        availableBalanceFiat: rateState.fromSeedsToFiat(balance.quantity, selectedFiat),
      );
    }
  }
}