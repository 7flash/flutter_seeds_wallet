import 'package:flutter/material.dart';
import 'package:seeds/v2/constants/app_colors.dart';

class SecondButton extends StatelessWidget {
  final double height;
  final double fontSize;
  final String? title;
  final EdgeInsets? margin;
  final Function? onPressed;
  final Color color;

  const SecondButton({
    this.title,
    this.height = 55,
    this.fontSize = 18,
    this.margin,
    this.onPressed,
    this.color = AppColors.blue,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      margin: margin,
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        color: color.withOpacity(0.2),
      ),
      child: MaterialButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
        onPressed: onPressed as void Function()?,
        color: Colors.transparent,
        child: Container(
          height: height,
          alignment: Alignment.center,
          width: width,
          child: Text(
            title!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: color,
              fontSize: fontSize,
            ),
          ),
        ),
      ),
    );
  }
}
