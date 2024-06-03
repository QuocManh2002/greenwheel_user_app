import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:phuot_app/config/graphql_config.dart';
import 'package:phuot_app/models/pagination.dart';
import 'package:phuot_app/view_models/profile_viewmodels/transaction.dart';
import 'package:phuot_app/view_models/transaction_detail.dart';

import '../helpers/util.dart';
import '../view_models/topup_request.dart';

class TransactionService {
  GraphQlConfig graphQlConfig = GraphQlConfig();

  Future<Pagination<TransactionViewModel>?> getTransactionList(
      String? cursor) async {
    try {
      GraphQLClient client = graphQlConfig.getClient();
      QueryResult result = await client.query(
          QueryOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
{
  transactions(
    where: { type: { in: [PLAN_FUND, PLAN_REFUND, TOPUP, GIFT] } }
    order: { id: DESC }
    after: ${cursor == null ? null : json.encode(cursor)}
    first: 15
    ) {
      pageInfo {
      endCursor
    }
    edges {
      node {
        id
        providerId
        planMemberId
        orderId
        type
        status
        amount
        description
        gateway
        bankTransCode
        createdAt
        accountId
      }
    }
  }
}

""")));
      if (result.hasException) {
        throw Exception(result.exception);
      }
      List? res = result.data!['transactions']['edges'];
      if (res == null || res.isEmpty) {
        return Pagination(pageSize: 15, cursor: cursor, objects: []);
      }

      cursor = result.data!['transactions']['pageInfo']['endCursor'];
      final listObjects =
          res.map((e) => TransactionViewModel.fromJson(e['node'])).toList();
      return Pagination(pageSize: 15, cursor: cursor, objects: listObjects);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<TransactionDetailViewModel?> getTransactionDetail(
      String type, int id) async {
    GraphQLClient client = graphQlConfig.getClient();
    try {
      QueryResult result = await client.query(QueryOptions(document: gql("""
      {
  transactions (where: {
    id:{
      eq:$id
    }
  }) {
    edges{
      node{
        order{
        id
        planId
        total
        serveDates
        note
        createdAt
        period
        type
        provider {
          type
          id
          phone
          name
          imagePath
          address
          coordinate{
            coordinates
          }
        }
        details {
          id
          price
          quantity
          product {
            id
            name
            type
            price
          }
        }
      }
        planMember{
          weight
          plan{
            name
            gcoinBudgetPerCapita
            destination{
              name
            }
            utcDepartAt
            utcEndAt
            maxMemberCount
            memberCount
            maxMemberWeight
          }
        }
      }
    }
  }
}
""")));
      if (result.hasException) {
        throw Exception(result.exception);
      }
      var rs = result.data!['transactions']['edges'][0]['node'];
      return TransactionDetailViewModel.fromJson(rs);
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<TopupRequestViewModel?> topUpRequest(
      int amount, BuildContext context) async {
    try {
      GraphQLClient client = graphQlConfig.getClient();
      final QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql('''
mutation {
  createTopUp(dto: { amount: $amount, gateway: VNPAY }) {
    transaction {
      id
    }
    paymentUrl
  }
}
          '''),
        ),
      );

      if (result.hasException) {
        dynamic rs = result.exception!.linkException!;
        Utils().handleServerException(
            rs.parsedResponse.errors.first.message.toString(),
            // ignore: use_build_context_synchronously
            context);

        throw Exception(result.exception!.linkException!);
      }
      final rs = result.data!['createTopUp'];
      if (rs == null) {
        return null;
      } else {
        return TopupRequestViewModel.fromJson(rs);
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<Stream<QueryResult<Object?>>> topUpSubcription(
      int transactionId) async {
    try {
      final GraphQLClient client = graphQlConfig.getClient();
      final result = client.subscribe(SubscriptionOptions(document: gql('''
subscription {
  topUpStatus(transactionId: $transactionId) {
    id
    providerId
    planMemberId
    orderId
    type
    status
    amount
    description
    gateway
    bankTransCode
    createdAt
    accountId
  }
}
''')));
      // final res = await result.first;
      // log(result.isBroadcast.toString());
      // log(result.)
      // if (res.data != null) {
      //   return TransactionViewModel.fromJson(res.data!['topUpStatus']);
      // }else {
      //   return null;
      // }
      return result;
    } catch (error) {
      throw Exception(error);
    }
  }
}
