class GlobalConstant {
  final String backIcon = "assets/images/back_arrow.png";
  final String upIcon = "assets/images/up.png";
  final String downIcon = "assets/images/down.png";
  final String cartEmptyIcon = "assets/images/cart-empty.png";
  final String baseGoongUrl = "https://rsapi.goong.io/";
  final List<String> northSide = [
    "Hà Nội",
    "Quảng Ninh",
    "Vĩnh Phúc",
    "Bắc Ninh",
    "Hải Dương",
    "Hải Phòng",
    "Hưng Yên",
    "Thái Bình",
    "Hà Nam",
    "Nam Định",
    "Ninh Bình",
    "Hà Giang",
    "Cao Bằng",
    "Lào Cai",
    "Bắc Kạn",
    "Lạng Sơn",
    "Tuyên Quang",
    "Yên Bái",
    "Thái Nguyên",
    "Phú Thọ",
    "Bắc Giang",
    "Lai Châu",
    "Điện Biên",
    "Sơn La",
    "Hòa Bình",
  ];

  final List<String> midSide = [
    "Bình Định",
    "Phú Yên",
    "Khánh Hòa",
    "Ninh Thuận",
    "Bình Thuận",
    "Kon Tum",
    "Gia Lai",
    "Đắk Lắk",
    "Đắk Nông",
    "Lâm Đồng",
  ];

  final List<String> southSide = [
    "Bình Phước",
    "Bình Dương",
    "Đồng Nai",
    "Tây Ninh",
    "Bà Rịa - Vũng Tàu",
    "TP Hồ Chí Minh",
    "Long An",
    "Đồng Tháp",
    "Tiền Giang",
    "An Giang",
    "Bến Tre",
    "Vĩnh Long",
    "Trà Vinh",
    "Hậu Giang",
    "Kiên Giang",
    "Sóc Trăng",
    "Bạc Liêu",
    "Cà Mau",
    "Cần Thơ",
  ];

  final int VND_CONVERT_RATE = 1000;
  final double BUDGET_ASSURANCE_RATE = 1.1;
  final int SURCHARGE_MIN_AMOUNT = 10;
  final int SURCHARGE_MAX_AMOUNT = 10000;
  final int SURCHARGE_MIN_NOTE_LENGTH = 2;
  final int SURCHARGE_MAX_NOTE_LENGTH = 40;
  final int ACTIVITY_SHORT_DESCRIPTION_MIN_LENGTH = 2;
  final int ACTIVITY_SHORT_DESCRIPTION_MAX_LENGTH = 40;
  final int ACTIVITY_DESCRIPTION_MIN_LENGTH = 1;
  final int ACTIVITY_DESCRIPTION_MAX_LENGTH = 300;
  final int PLAN_MIN_MEMBER_COUNT = 1;
  final int PLAN_MAX_MEMBER_COUNT = 20;
  final int HALF_EVENING = 20;
  final int HALF_AFTERNOON = 16;
  final int MORNING_START = 6;
  final int NOON_START = 10;
  final int AFTERNOON_START = 14;
  final int EVENING_START = 18;
  final int EVENING_END = 22;
  final Duration MAX_SUM_ACTIVITY_TIME = const Duration(hours: 16);
  final Duration MIN_ACTIVITY_TIME = const Duration(minutes: 15);
  final int ORDER_ITEM_MAX_COUNT = 10;
  final int PLAN_SURCHARGE_MAX_COUNT = 10;
  final Duration MIN_DURATION_REPORT_PLAN = const Duration(days: 3);
  final Duration MIN_DURATION_REPORT_ORDER = const Duration(days: 3);
  final int ORDER_COMMENT_MAX_LENGTH = 300;
  final int ORDER_COMMENT_MIN_LENGTH = 10;
  final int ORDER_MIN_RATING_NO_COMMENT = 4;
  final int ADDRESS_MIN_LENGTH = 20;
  final int ADDRESS_MAX_LENGTH = 120;
  final int PLAN_NAME_MIN_LENGTH = 3;
  final int PLAN_NAME_MAX_LENGTH = 30;
  final int ACCOUNT_NAME_MIN_LENGTH = 4;
  final int ACCOUNT_NAME_MAX_LENGTH = 30;
  final int PLAN_COMMENT_MIN_LENGTH = 10;
  final int PLAN_COMMENT_MAX_LENGTH = 300;
  final int MEMBER_REFUND_SELF_REMOVE_1_DAY_PCT = 50;
  final int ORDER_PROCESSING_DATE_DURATION = 3;
  final int ORDER_REFUND_CUSTOMER_CANCEL_1_DAY_PCT = 70;
  final int ORDER_REFUND_CUSTOMER_CANCEL_2_DAY_PCT = 40;
  final int MIN_TOPUP = 15;
  final int MAX_TOPUP = 10000;
  final int HOLIDAY_MEAL_UP_PCT = 10;
  final int HOLIDAY_LODGING_UP_PCT = 50;
  final int HOLIDAY_RIDING_UP_PCT = 10;
  final int PLAN_COMPLETE_AFTER_DAYS = 3;
  final int ORDER_COMPLETE_AFTER_DAYS = 3;
  final int MIN_PLAN_MEMBER = 1;
  final int MAX_PLAN_MEMBER = 20;
  final int MIN_DEPART_DIFF = 7;
  final int MAX_DEPART_DIFF = 30;
  final int MIN_PERIOD = 2;
  final int MAX_PERIOD = 30;
}
