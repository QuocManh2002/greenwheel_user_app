import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/plan_detail.dart';
import 'package:greenwheel_user_app/view_models/profile_viewmodels/transaction.dart';

class TransactionDetailViewModel {
  Transaction? transaction;
  PlanDetail? plan;
  OrderViewModel? order;
  int? memberWeight;

  TransactionDetailViewModel(
      {this.transaction, this.plan, this.order, this.memberWeight});

  factory TransactionDetailViewModel.fromJson(Map<String, dynamic> json) =>
      TransactionDetailViewModel(
          plan: json['planMember'] != null
              ? PlanDetail(
                  name: json['planMember']['plan']['name'],
                  gcoinBudgetPerCapita: json['planMember']['plan']
                      ['gcoinBudgetPerCapita'],
                  locationName: json['planMember']['plan']['destination']
                      ['name'],
                  departDate:
                      DateTime.parse(json['planMember']['plan']['departDate']),
                  endDate:
                      DateTime.parse(json['planMember']['plan']['endDate']),
                  maxMemberCount: json['planMember']['plan']['maxMemberCount'],
                  memberCount: json['planMember']['plan']['memberCount'],
                  maxMemberWeight: json['planMember']['plan']
                      ['maxMemberWeight'])
              : null,
          memberWeight:
              json['planMember'] != null ? json['planMember']['weight'] : null,
          order: json['order'] != null ? OrderViewModel.fromJson(json['order']):null);
}
