import 'dart:convert';

import 'package:greenwheel_user_app/main.dart';
import 'package:http/http.dart' as http;
import 'package:stripe_checkout/stripe_checkout.dart';

class StripeConfig {
  static String secretKey =
      "sk_test_51Nzv5VFKpwfqvOeOttFjaJZ7SjQa17mXtsP9TOT7y9Ne18MTqpeeobv47HwFeUoo5eukBgnoJ8v1La4re0hBPZ4S00gqbpOePs";
  static String publishableKey =
      "pk_test_51Nzv5VFKpwfqvOeOBfe5Ffzz7p2aUxsJX7aw55pEDP4PWeFnO5O64eobUkYBLI8OdHOrYW8rj51yM9lWeJKSLJXV00BmwHqsxl";

  static Future<dynamic> createCheckoutSession(
    List<dynamic> productItems,
    totalAmmount,
  ) async {
    final url = Uri.parse("https://api.stripe.com/v1/checkout/sessions");

    String lineItems = "";
    int index = 0;

    productItems.forEach(
      (element) {
        lineItems +=
            "&line_items[$index][price_data][product_data][name]=${element['productName']}";
        lineItems +=
            "&line_items[$index][price_data][unit_amount]=${element['productPrice']}";
        lineItems += "&line_items[$index][price_data][currency]=VND";
        // lineItems +=
        //     "&line_items[$index][price]=price_1O3t4mFKpwfqvOeOxfcOP2Kp";
        lineItems +=
            "&line_items[$index][quantity]=${element['qty'].toString()}";

        index++;
      },
    );

    final response = await http.post(url,
        body:
            'success_url=https://checkout.stripe.dev/success&mode=payment${lineItems}',
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        });

    print(json.decode(response.body));
    return json.decode(response.body)["id"];
  }

  static Future<dynamic> stripePaymentCheckout(
      productItems, subTotal, context, mounted,
      {onSuccess, onCancel, onError}) async {
    final String sessionId =
        await createCheckoutSession(productItems, subTotal);

    final result = await redirectToCheckout(
      context: context,
      sessionId: sessionId,
      publishableKey: publishableKey,
      successUrl: "https://checkout.stripe.dev/success",
      canceledUrl: "https://checkout.stripe.dev/cancel",
    );

    final url = Uri.parse("https://api.stripe.com/v1/payment_intents");

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $secretKey',
        'Content-Type': 'application/x-www-form-urlencoded'
      },
    );

    print(json.decode(response.body));
    sharedPreferences.setString(
        'transactionId', json.decode(response.body)["data"][0]["id"]);

    if (mounted) {
      final text = result.when(
        redirected: () => "Redirect successfully",
        success: () => onSuccess(),
        canceled: () => onCancel(),
        error: (e) => onError(),
      );

      return text;
    }
  }
}
