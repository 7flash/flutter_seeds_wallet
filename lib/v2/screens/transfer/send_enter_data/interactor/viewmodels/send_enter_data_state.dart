import 'package:equatable/equatable.dart';
import 'package:seeds/v2/blocs/rates/viewmodels/rates_state.dart';
import 'package:seeds/v2/datasource/remote/model/balance_model.dart';
import 'package:seeds/v2/datasource/remote/model/member_model.dart';
import 'package:seeds/v2/domain-shared/page_state.dart';
import 'package:seeds/v2/screens/transfer/send_enter_data/interactor/viewmodels/show_send_confirm_dialog_data.dart';

class SendEnterDataPageState extends Equatable {
  final PageState pageState;
  final String? error;
  final MemberModel sendTo;
  final String? fiatAmount;
  final RatesState ratesState;
  final BalanceModel? balance;
  final String? availableBalance;
  final String? availableBalanceFiat;
  final bool isNextButtonEnabled;
  final ShowSendConfirmDialog? showSendConfirmDialog;
  final double quantity;

  const SendEnterDataPageState(
      {required this.pageState,
      this.error,
      required this.sendTo,
      this.fiatAmount,
      required this.ratesState,
      this.availableBalance,
      this.availableBalanceFiat,
      required this.isNextButtonEnabled,
      this.balance,
      required this.quantity,
      this.showSendConfirmDialog});

  @override
  List<Object?> get props => [
        pageState,
        sendTo,
        fiatAmount,
        error,
        ratesState,
        availableBalance,
        availableBalanceFiat,
        isNextButtonEnabled,
        balance,
        quantity,
        showSendConfirmDialog
      ];

  SendEnterDataPageState copyWith({
    PageState? pageState,
    String? error,
    MemberModel? sendTo,
    String? fiatAmount,
    RatesState? ratesState,
    String? availableBalance,
    String? availableBalanceFiat,
    BalanceModel? balance,
    bool? isNextButtonEnabled,
    ShowSendConfirmDialog? showSendConfirmDialog,
    double? quantity,
  }) {
    return SendEnterDataPageState(
        pageState: pageState ?? this.pageState,
        error: error ?? this.error,
        sendTo: sendTo ?? this.sendTo,
        fiatAmount: fiatAmount ?? this.fiatAmount,
        ratesState: ratesState ?? this.ratesState,
        availableBalance: availableBalance ?? this.availableBalance,
        availableBalanceFiat: availableBalanceFiat ?? this.availableBalanceFiat,
        balance: balance ?? this.balance,
        isNextButtonEnabled: isNextButtonEnabled ?? this.isNextButtonEnabled,
        showSendConfirmDialog: showSendConfirmDialog ?? this.showSendConfirmDialog,
        quantity: quantity ?? this.quantity);
  }

  factory SendEnterDataPageState.initial(MemberModel memberModel, RatesState ratesState) {
    return SendEnterDataPageState(
      pageState: PageState.initial,
      sendTo: memberModel,
      ratesState: ratesState,
      isNextButtonEnabled: false,
      quantity: 0,
    );
  }
}
