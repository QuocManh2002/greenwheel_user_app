
import '../view_models/supplier.dart';
import 'menu_item_cart.dart';
import 'service_type.dart';
import 'session.dart';

class OrderInputModel {
  final Session? session;
  final DateTime? startDate;
  final DateTime? endDate;
  final SupplierViewModel? supplier;
  final ServiceType? serviceType;
  final List<ItemCart>? currentCart;
  final List<ItemCart>? initCart;
  final String? iniNote;
  final int? numberOfMember;
  final bool? isOrder;
  final String? period;
  final int? availableGcoinAmount;
  final void Function(dynamic tempOrder)? callbackFunction;
  final String? orderGuid;

  final List<DateTime>? servingDates;
  final List<DateTime>? holidayServingDates;
  final int? holidayUpPCT;

  OrderInputModel(
      {this.availableGcoinAmount,
      this.callbackFunction,
      this.currentCart,
      this.endDate,
      this.iniNote,
      this.initCart,
      this.isOrder,
      this.numberOfMember,
      this.orderGuid,
      this.period,
      this.serviceType,
      this.session,
      this.startDate,
      this.holidayServingDates,
      this.servingDates,
      this.holidayUpPCT,
      this.supplier});
}
