import 'package:flutter_easyloading/flutter_easyloading.dart';

class TTToast {
  /*toast*/
  static showToast(String msg) {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..toastPosition = EasyLoadingToastPosition.center;
    EasyLoading.showToast(msg);
  }

  /*显示loading*/
  static showLoading() {
    EasyLoading.instance
      ..loadingStyle = EasyLoadingStyle.dark
      ..indicatorType = EasyLoadingIndicatorType.threeBounce;
    EasyLoading.show(
      maskType: EasyLoadingMaskType.black,
    );
  }

  /*隐藏 loading*/
  static hideLoading() {
    EasyLoading.dismiss();
  }

  /*显示错误信息*/
  static showErrorInfo(String errorInfo,{int duration = 2000}) {
    EasyLoading.instance.displayDuration =  Duration(milliseconds: duration);
    EasyLoading.showError(errorInfo);
  }

  /*显示成功信息*/
  static showSuccessInfo(String successInfo) {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000);
    EasyLoading.showSuccess(successInfo);
  }
}
