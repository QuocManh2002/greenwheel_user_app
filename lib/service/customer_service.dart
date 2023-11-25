import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:greenwheel_user_app/config/graphql_config.dart';
import 'package:greenwheel_user_app/view_models/customer.dart';

class CustomerService {
  static GraphQlConfig graphQlConfig = GraphQlConfig();
  static GraphQLClient client = graphQlConfig.getClient();

  Future<CustomerViewModel?> GetCustomerByPhone(String phone) async {
    try {
      QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql("""
            query getCustomerByPhone(\$phone: String) {
    customers
    (
      where: { 
        phone: {eq: \$phone } 
        isBlocked: {eq: false}
        }
      )
        {
        nodes{
          id
          name
          email
          isMale
          avatarUrl
          birthday
          phone
          balance
        }
    }
}
          """),
          variables: {"phone": phone},
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      List? res = result.data!['customers']['nodes'];
      if (res == null || res.isEmpty) {
        return null;
      }
      print(res);
      List<CustomerViewModel> users =
          res.map((users) => CustomerViewModel.fromJson(users)).toList();
      var rs = users[0];
      return rs;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<String?> addBalance(int balance) async{
    try{
      QueryResult result =await client.mutate(
        MutationOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql(
            """
mutation{
  createTopUpRequest(model: {
    amount: $balance
    gateway:STRIPE
  })
}
"""
          ))
      );
      if (result.hasException) {
        throw Exception(result.exception);
      } else {
        String transactionId = result.data!['createTopUpRequest'];
        return transactionId;
      } 
    }catch (error) {
      throw Exception(error);
    }
  }
}
