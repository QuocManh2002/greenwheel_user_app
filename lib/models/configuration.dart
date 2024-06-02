
import 'package:phuot_app/models/holiday.dart';

class ConfigurationModel {
  List<Holiday>? HOLIDAYS;
  int? HOLIDAY_RIDING_UP_PCT;
  int? HOLIDAY_LODGING_UP_PCT;
  int? HOLIDAY_MEAL_UP_PCT;
  int? PRODUCT_MAX_PRICE_UP_PCT;
  bool? USE_FIXED_OTP;
  int? ORDER_REFUND_CUSTOMER_CANCEL_1_DAY_PCT;
  int? ORDER_REFUND_CUSTOMER_CANCEL_2_DAY_PCT;
  DateTime? LAST_MODIFIED;
  int? DEFAULT_PRESTIGE_POINT;
  int? MIN_TOPUP;
  int? MAX_TOPUP;
  int? ORDER_DATE_MIN_DIFF;
  int? ORDER_CANCEL_DATE_DURATION;
  int? MEMBER_REFUND_SELF_REMOVE_1_DAY_PCT;

  ConfigurationModel(
      {this.DEFAULT_PRESTIGE_POINT,
      this.HOLIDAY_LODGING_UP_PCT,
      this.HOLIDAY_MEAL_UP_PCT,
      this.HOLIDAY_RIDING_UP_PCT,
      this.LAST_MODIFIED,
      this.MAX_TOPUP,
      this.MEMBER_REFUND_SELF_REMOVE_1_DAY_PCT,
      this.MIN_TOPUP,
      this.ORDER_CANCEL_DATE_DURATION,
      this.ORDER_DATE_MIN_DIFF,
      this.ORDER_REFUND_CUSTOMER_CANCEL_1_DAY_PCT,
      this.ORDER_REFUND_CUSTOMER_CANCEL_2_DAY_PCT,
      this.PRODUCT_MAX_PRICE_UP_PCT,
      this.USE_FIXED_OTP,
      this.HOLIDAYS});

  factory ConfigurationModel.fromJson(Map<String, dynamic> json) =>
      ConfigurationModel(
          HOLIDAYS: List<Holiday>.from(
              json['HOLIDAYS'].map((e) => Holiday.fromJson(e))).toList(),
          HOLIDAY_RIDING_UP_PCT: json['HOLIDAY_RIDING_UP_PCT'],
          HOLIDAY_LODGING_UP_PCT: json['HOLIDAY_LODGING_UP_PCT'],
          HOLIDAY_MEAL_UP_PCT: json['HOLIDAY_MEAL_UP_PCT'],
          PRODUCT_MAX_PRICE_UP_PCT: json['PRODUCT_MAX_PRICE_UP_PCT'],
          USE_FIXED_OTP: json['USE_FIXED_OTP'],
          ORDER_REFUND_CUSTOMER_CANCEL_1_DAY_PCT:
              json['ORDER_REFUND_CUSTOMER_CANCEL_1_DAY_PCT'],
          ORDER_REFUND_CUSTOMER_CANCEL_2_DAY_PCT:
              json['ORDER_REFUND_CUSTOMER_CANCEL_2_DAY_PCT'],
          LAST_MODIFIED: json['LAST_MODIFIED'] != null ? DateTime.parse(json['LAST_MODIFIED']) : null,
          DEFAULT_PRESTIGE_POINT: json['DEFAULT_PRESTIGE_POINT'],
          MIN_TOPUP: json['MIN_TOPUP'],
          MAX_TOPUP: json['MAX_TOPUP'],
          ORDER_DATE_MIN_DIFF: json['ORDER_DATE_MIN_DIFF'],
          ORDER_CANCEL_DATE_DURATION: json['ORDER_CANCEL_DATE_DURATION'],
          MEMBER_REFUND_SELF_REMOVE_1_DAY_PCT:
              json['MEMBER_REFUND_SELF_REMOVE_1_DAY_PCT']);
}
