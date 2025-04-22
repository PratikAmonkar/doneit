import 'package:intl/intl.dart';

class CommonUtil {
  String getDate({required int option, required String value}) {
    try {
      switch (option) {
        case 1:
          DateTime parsedDate = DateTime.parse(value);
          final formatter = DateFormat("dd MMM yy, hh:mm a");
          return formatter.format(parsedDate);
        default:
          return "-";
      }
    } catch (e) {
      return "-";
    }
  }

  String greetUser() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return "Good Morning";
    } else if (hour >= 12 && hour < 17) {
      return "Good Afternoon";
    } else if (hour >= 17 && hour < 21) {
      return "Good Evening";
    } else {
      return "";
    }
  }
}
