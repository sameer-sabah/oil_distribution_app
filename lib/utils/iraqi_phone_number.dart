class IraqiPhoneNumber {
  const IraqiPhoneNumber._();

  /// يحول أرقام الموبايل العراقية إلى صيغة واتساب الدولية بدون علامة +.
  ///
  /// الصيغ المقبولة مثلاً:
  /// 07822231110
  /// 7822231110
  /// +9647822231110
  /// 009647822231110
  static String? forWhatsApp(String value) {
    var digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.startsWith('00964')) {
      digits = digits.substring(2);
    }

    if (digits.startsWith('9640')) {
      digits = '964${digits.substring(4)}';
    } else if (digits.startsWith('0')) {
      digits = '964${digits.substring(1)}';
    } else if (digits.startsWith('7')) {
      digits = '964$digits';
    }

    if (!RegExp(r'^9647[0-9]{9}$').hasMatch(digits)) {
      return null;
    }

    return digits;
  }
}
