import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:seeds/v2/blocs/rates/viewmodels/rates_bloc.dart';
import 'package:seeds/v2/blocs/rates/viewmodels/rates_state.dart';
import 'package:seeds/v2/components/amount_entry/interactor/viewmodels/page_command.dart';
import 'package:seeds/v2/design/app_theme.dart';
import 'package:seeds/v2/domain-shared/user_input_decimal_precision.dart';
import 'package:seeds/v2/domain-shared/user_input_number_formatter.dart';

import 'interactor/amount_entry_bloc.dart';
import 'interactor/viewmodels/amount_entry_events.dart';
import 'interactor/viewmodels/amount_entry_state.dart';

class AmountEntryWidget extends StatelessWidget {
  final ValueSetter<String> onValueChange;
  final bool autoFocus;

  const AmountEntryWidget({
    Key? key,
    required this.onValueChange,
    required this.autoFocus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RatesState rates = BlocProvider.of<RatesBloc>(context).state;
    return BlocProvider(
      create: (BuildContext context) => AmountEntryBloc(rates),
      child: BlocListener<AmountEntryBloc, AmountEntryState>(
        listenWhen: (_, current) => current.pageCommand != null,
        listener: (context, state) {
          // ignore: cast_nullable_to_non_nullable
          onValueChange((state.pageCommand as SendTextInputDataBack).textToSend);

          BlocProvider.of<AmountEntryBloc>(context).add(ClearPageCommand());
        },
        child: BlocBuilder<AmountEntryBloc, AmountEntryState>(
          builder: (BuildContext context, AmountEntryState state) {
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.headline4,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "0.0",
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                        autofocus: autoFocus,
                        onChanged: (String value) => BlocProvider.of<AmountEntryBloc>(context).add(OnAmountChange(
                          amountChanged: value,
                        )),
                        inputFormatters: [
                          UserInputNumberFormatter(),
                          DecimalTextInputFormatter(decimalRange: state.currentCurrencyInput.toDecimalPrecision())
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Column(
                            children: [
                              Text(
                                state.enteringCurrencyName,
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                              const SizedBox(height: 18)
                            ],
                          ),
                          Positioned(
                            bottom: -16,
                            left: 70,
                            child: Container(
                              height: 60,
                              width: 60,
                              child: IconButton(
                                icon: SvgPicture.asset(
                                  'assets/images/currency_switch_button.svg',
                                  height: 60,
                                  width: 60,
                                ),
                                onPressed: () =>
                                    {BlocProvider.of<AmountEntryBloc>(context).add(OnCurrencySwitchButtonTapped())},
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  state.infoRowText,
                  style: Theme.of(context).textTheme.subtitle2OpacityEmphasis,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
