import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/view_models/profile_viewmodels/transaction.dart';
import 'package:greenwheel_user_app/view_models/transaction_detail.dart';

class TransactionService {
  GraphQlConfig graphQlConfig = GraphQlConfig();

  Future<List<Transaction>?> getTransactionList() async {
    try {
      GraphQLClient client = graphQlConfig.getClient();
      QueryResult result = await client.query(
          QueryOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
{
  transactions(order: { id: DESC }) {
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
        return [];
      }
      List<Transaction> rs =
          res.map((e) => Transaction.fromJson(e['node'])).toList();
      return rs;
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
}
