import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:seeds/v2/constants/app_colors.dart';
import 'package:seeds/utils/string_extension.dart';
import 'package:seeds/widgets/read_times_tamp.dart';
import 'package:seeds/widgets/transaction_avatar.dart';
import 'package:seeds/v2/design/app_theme.dart';

class TransactionInfoCard extends StatelessWidget {
  final String profileAccount;
  final String? profileNickname;
  final String? profileImage;
  final String timestamp;
  final String amount;
  final bool incoming;
  final GestureTapCallback onTap;

  const TransactionInfoCard({
    Key? key,
    required this.amount,
    required this.onTap,
    required this.profileAccount,
    this.profileNickname,
    this.profileImage,
    required this.timestamp,
    required this.incoming,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Ink(
        decoration: const BoxDecoration(
          color: AppColors.primary,
        ),
        child: Container(
          padding: const EdgeInsets.only(top: 10, bottom: 10, right: 20, left: 20),
          child: Row(
            children: <Widget>[
              TransactionAvatar(
                size: 60,
                account: profileAccount,
                nickname: profileNickname,
                image: profileImage,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.lightGreen2,
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                              child: Text(
                            (profileNickname == null || profileNickname == "") ? profileAccount : profileNickname!,
                            style: Theme.of(context).textTheme.button,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          )),
                          const SizedBox(width: 40),
                          Text(amount.seedsFormatted.toString(), style: Theme.of(context).textTheme.button),
                          const SizedBox(width: 4),
                          SvgPicture.asset(
                              incoming ? 'assets/images/wallet/arrow_up.svg' : 'assets/images/wallet/arrow_down.svg',
                              height: 16)
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          Expanded(
                              child: Text(timesTampToTimeAgo(timestamp),
                                  style: Theme.of(context).textTheme.subtitle2OpacityEmphasis)),
                          Text(amount.symbolFromAmount, style: Theme.of(context).textTheme.subtitle2OpacityEmphasis)
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}