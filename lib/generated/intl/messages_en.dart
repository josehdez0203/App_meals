// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(number) => "Minimum of characters ${number}";

  static String m1(email) => "The email ${email} is already registered";

  static String m2(minPurchaseAmountCard, coin) =>
      "The minimum credit card purchase amount is ${minPurchaseAmountCard} ${coin}. Please add more products to the cart. Or pay cash";

  static String m3(name) => "The name ${name} is already registered";

  static String m4(phone) => "The phone number ${phone} is already registered";

  static String m5(email) =>
      "The email address ${email} is not in our records.";

  static String m6(phone) => "Your phone number is: ${phone}";

  static String m7(labelCancelButton) =>
      "If you are sure you want to cancel the order, touch on the (${labelCancelButton}) button";

  static String m8(company) =>
      "The company ${company}, does not ship units to your location. Please select another address on the main screen and select another company";

  static String m9(distance) =>
      "The minimum distance of the route cannot be less than ${distance} meters";

  static String m10(amount, coin, phone) =>
      "The recharge of\n\n${amount} ${coin} to the number\n\n${phone}\n\nhas been successfully completed";

  static String m11(email) =>
      "Password sent to ${email}, if you don\'t see the email check your SPAM folder";

  static String m12(alias) => "Close to ${alias}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "bAccept": MessageLookupByLibrary.simpleMessage("Accept"),
        "bCancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "bChangePassword":
            MessageLookupByLibrary.simpleMessage("Change password"),
        "bConfirm": MessageLookupByLibrary.simpleMessage("Confirm"),
        "bContinue": MessageLookupByLibrary.simpleMessage("Continue"),
        "bDone": MessageLookupByLibrary.simpleMessage("Done"),
        "bEstablishLocation":
            MessageLookupByLibrary.simpleMessage("Set location"),
        "bFinish": MessageLookupByLibrary.simpleMessage("Finish"),
        "bLogin": MessageLookupByLibrary.simpleMessage("Login"),
        "bNewAddress":
            MessageLookupByLibrary.simpleMessage("Add a new address"),
        "bNewProduct": MessageLookupByLibrary.simpleMessage("New product"),
        "bOffline": MessageLookupByLibrary.simpleMessage("Offline"),
        "bOnline": MessageLookupByLibrary.simpleMessage("Online"),
        "bPay": MessageLookupByLibrary.simpleMessage("Pay"),
        "bQualify": MessageLookupByLibrary.simpleMessage("Qualify"),
        "bRecoverAccount":
            MessageLookupByLibrary.simpleMessage("Recover account"),
        "bRequestCabt": MessageLookupByLibrary.simpleMessage("Request cab"),
        "bReturn": MessageLookupByLibrary.simpleMessage("Return"),
        "bRouteClient":
            MessageLookupByLibrary.simpleMessage("Route to the client"),
        "bRouteStore":
            MessageLookupByLibrary.simpleMessage("Route to the store"),
        "bSaveChanges": MessageLookupByLibrary.simpleMessage("Save"),
        "bSelectAddress":
            MessageLookupByLibrary.simpleMessage("Select an address"),
        "bSelectPhoto": MessageLookupByLibrary.simpleMessage("Select a photo"),
        "bSetDestinationPoint":
            MessageLookupByLibrary.simpleMessage("Set destination point"),
        "bSetPickUpPoint":
            MessageLookupByLibrary.simpleMessage("Set pick-up point"),
        "bSignin": MessageLookupByLibrary.simpleMessage("Sign in"),
        "bSignup": MessageLookupByLibrary.simpleMessage("Sign up"),
        "bUpload": MessageLookupByLibrary.simpleMessage("Upload"),
        "eValidatoAmount":
            MessageLookupByLibrary.simpleMessage("Incorrect Amount"),
        "eValidatoCharacters": m0,
        "eValidatoEmail": MessageLookupByLibrary.simpleMessage(
            "The mail format is incorrect"),
        "eValidatoPhone": MessageLookupByLibrary.simpleMessage(
            "The phone number format is incorrect"),
        "emptyTab2": MessageLookupByLibrary.simpleMessage(
            "You have does not pending orders"),
        "errDeleteAllAddress": MessageLookupByLibrary.simpleMessage(
            "You cannot delete all addresses. You must have at least one"),
        "errDeliverymanNotFound": MessageLookupByLibrary.simpleMessage(
            "The number I provide does not belong to any registered deliveryman"),
        "errEmailUnique": m1,
        "errManagerCannotBeDeliveryman": MessageLookupByLibrary.simpleMessage(
            "The phone number I provide is assigned to a store (manager role) so it cannot deliveryman (deliveryman role)"),
        "errMinPurchaseAmountCard": m2,
        "errNameUnique": m3,
        "errPhoneNumber":
            MessageLookupByLibrary.simpleMessage("Please add a phone number"),
        "errPhoneNumberAgain": MessageLookupByLibrary.simpleMessage(
            "Please add the phone number again"),
        "errPhoneUnique": m4,
        "errPleaseUploadImage":
            MessageLookupByLibrary.simpleMessage("Please upload an image"),
        "errRecoverAccount": m5,
        "errUnknown": MessageLookupByLibrary.simpleMessage(
            "Oops, something seems to have gone wrong, please try again later"),
        "errdeliverymanCannotBeManager": MessageLookupByLibrary.simpleMessage(
            "The phone number I provide is assigned to a deliveryman (deliveryman role) so it cannot manager (manager role)"),
        "hAddress": MessageLookupByLibrary.simpleMessage("Address"),
        "hAlias": MessageLookupByLibrary.simpleMessage("Alias"),
        "hChat": MessageLookupByLibrary.simpleMessage("Type your message"),
        "hEmail": MessageLookupByLibrary.simpleMessage("Email"),
        "hFilter": MessageLookupByLibrary.simpleMessage(
            "What do you want to eat today?"),
        "hFullName": MessageLookupByLibrary.simpleMessage("Full name"),
        "hNoteProdcut":
            MessageLookupByLibrary.simpleMessage("Type a note for the product"),
        "hPassword": MessageLookupByLibrary.simpleMessage("Password"),
        "hPhone": MessageLookupByLibrary.simpleMessage("Phone number"),
        "hProductDescription":
            MessageLookupByLibrary.simpleMessage("Product description"),
        "hProductName": MessageLookupByLibrary.simpleMessage("Product name"),
        "hYourPhoneNumber": m6,
        "lAddedCart": MessageLookupByLibrary.simpleMessage("Added to cart"),
        "lAmount": MessageLookupByLibrary.simpleMessage("Amount"),
        "lClient": MessageLookupByLibrary.simpleMessage("Client"),
        "lClosed": MessageLookupByLibrary.simpleMessage("Closed"),
        "lDeliveryAddress":
            MessageLookupByLibrary.simpleMessage("Delivery address"),
        "lDeliveryFee": MessageLookupByLibrary.simpleMessage("Shipment"),
        "lDeliveryman": MessageLookupByLibrary.simpleMessage("Deliveryman"),
        "lFriday": MessageLookupByLibrary.simpleMessage("Friday"),
        "lHAmounValid": MessageLookupByLibrary.simpleMessage(
            "Amount to be refunded by credit card"),
        "lHBalanceValid": MessageLookupByLibrary.simpleMessage(
            "Balance to be able to take orders"),
        "lHMoneyValid": MessageLookupByLibrary.simpleMessage(
            "This amount automatically reduces the payment"),
        "lMonday": MessageLookupByLibrary.simpleMessage("Monday"),
        "lNewAddress": MessageLookupByLibrary.simpleMessage("New address"),
        "lNumber": MessageLookupByLibrary.simpleMessage("Number"),
        "lOrderBy": MessageLookupByLibrary.simpleMessage("Order by"),
        "lPayCash": MessageLookupByLibrary.simpleMessage("Pay in cash"),
        "lPayMoney": MessageLookupByLibrary.simpleMessage("Pay by credit card"),
        "lPaymentMethods":
            MessageLookupByLibrary.simpleMessage("Payment methods"),
        "lPrice": MessageLookupByLibrary.simpleMessage("Price"),
        "lProduct": MessageLookupByLibrary.simpleMessage("Product"),
        "lSaturday": MessageLookupByLibrary.simpleMessage("Saturday"),
        "lSearch": MessageLookupByLibrary.simpleMessage("Search"),
        "lSelect": MessageLookupByLibrary.simpleMessage("Select"),
        "lStatusOrderAssigned": MessageLookupByLibrary.simpleMessage(
            "🛵 The delivery man is on his way to pick up your order"),
        "lStatusOrderCancelled": MessageLookupByLibrary.simpleMessage(
            "🥺 Oops. Sorry, but the order has been cancelled. Please rate your experience"),
        "lStatusOrderDelivered": MessageLookupByLibrary.simpleMessage(
            "🥳 Thank you for choosing us. Please rate your experience"),
        "lStatusOrderQualified":
            MessageLookupByLibrary.simpleMessage("Thank you for choosing us"),
        "lStatusOrderStarted": MessageLookupByLibrary.simpleMessage(
            "👨🏼‍🍳 The restaurant is preparing your order"),
        "lStatusOrderTaken": MessageLookupByLibrary.simpleMessage(
            "💚 The driver has reported boarding the vehicle"),
        "lStatusTaxiAssigned": MessageLookupByLibrary.simpleMessage(
            "🚖 You have been assigned a cab. 🚕 The cab is heading to your location"),
        "lStatusTaxiCancelled": MessageLookupByLibrary.simpleMessage(
            "🥺 Oops. Sorry, but the order has been cancelled. Please rate your experience"),
        "lStatusTaxiDelivered": MessageLookupByLibrary.simpleMessage(
            "🥳 Thank you for choosing us. Please rate your experience"),
        "lStatusTaxiQualified":
            MessageLookupByLibrary.simpleMessage("Thank you for choosing us"),
        "lStatusTaxiStarted": MessageLookupByLibrary.simpleMessage(
            "🔎 We are looking for a nearby unit"),
        "lStatusTaxiTaken": MessageLookupByLibrary.simpleMessage(
            "💚 The driver has reported boarding the vehicle."),
        "lSunday": MessageLookupByLibrary.simpleMessage("Sunday"),
        "lTMoneyValid": MessageLookupByLibrary.simpleMessage(
            "Money. Valid only with credit card"),
        "lThursday": MessageLookupByLibrary.simpleMessage("Thursday"),
        "lTotal": MessageLookupByLibrary.simpleMessage("Total"),
        "lTuesday": MessageLookupByLibrary.simpleMessage("Tuesday"),
        "lWednesday": MessageLookupByLibrary.simpleMessage("Wednesday"),
        "lselectCategory":
            MessageLookupByLibrary.simpleMessage("Select a category"),
        "lselectGroup": MessageLookupByLibrary.simpleMessage("Select a group"),
        "lselectPayment":
            MessageLookupByLibrary.simpleMessage("Select a payment method"),
        "mDCancelOrder": m7,
        "mDConfirmOrder": MessageLookupByLibrary.simpleMessage(
            "Confirm that you have picked up the order"),
        "mDFinish":
            MessageLookupByLibrary.simpleMessage("Please rate the client"),
        "mDLogoutSession": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to log out?"),
        "mDStoreClosed": MessageLookupByLibrary.simpleMessage(
            "This store is closed, you can view their products but you will not be able to make a purchase until the store is open"),
        "mEither": MessageLookupByLibrary.simpleMessage("either"),
        "mIncorrectLogin": MessageLookupByLibrary.simpleMessage(
            "Incorrect username or password"),
        "mMaximumDistanceStoreStartingPoint": m8,
        "mMinimumTravelDistance": m9,
        "mRAddressRemoved":
            MessageLookupByLibrary.simpleMessage("Address removed"),
        "mRChangesMadeCorrectly":
            MessageLookupByLibrary.simpleMessage("Changes made correctly"),
        "mRConfirmOrde": MessageLookupByLibrary.simpleMessage(
            "Cool. We notify that you have picked up the order"),
        "mRStoreCongratulations": MessageLookupByLibrary.simpleMessage(
            "Congratulations, you have successfully registered your store. Now create your products and start selling"),
        "mRTopUpBalance": m10,
        "mRecoverAccount": m11,
        "mRinsufficientBalance": MessageLookupByLibrary.simpleMessage(
            "Insufficient funds. Please top up your balance"),
        "mRorderFulfilled": MessageLookupByLibrary.simpleMessage(
            "Oops, the request has already been fulfilled"),
        "sFeatured": MessageLookupByLibrary.simpleMessage("People love them"),
        "sSlideApply": MessageLookupByLibrary.simpleMessage("Slide to apply"),
        "sTCategory":
            MessageLookupByLibrary.simpleMessage("Filter by category"),
        "sTCompanyPopular":
            MessageLookupByLibrary.simpleMessage("You can\'t miss them"),
        "sTCompanyTop":
            MessageLookupByLibrary.simpleMessage("You have to try them"),
        "sTOrders": MessageLookupByLibrary.simpleMessage("on its way"),
        "tAbout": MessageLookupByLibrary.simpleMessage("About"),
        "tAddress": MessageLookupByLibrary.simpleMessage("Address"),
        "tAddresses": MessageLookupByLibrary.simpleMessage("Addresses"),
        "tAppBarOrders": MessageLookupByLibrary.simpleMessage("Orders"),
        "tCartSummary": MessageLookupByLibrary.simpleMessage(
            "Summary & Address of delivery"),
        "tCategories": MessageLookupByLibrary.simpleMessage("Categories"),
        "tCloseTo": m12,
        "tClosingTime": MessageLookupByLibrary.simpleMessage("CLOSING TIME"),
        "tCompanyPopular":
            MessageLookupByLibrary.simpleMessage("Most purchased"),
        "tCompanyTop": MessageLookupByLibrary.simpleMessage("The best rated"),
        "tDestination": MessageLookupByLibrary.simpleMessage("Destination"),
        "tFeatured": MessageLookupByLibrary.simpleMessage("Featured"),
        "tMyOrder": MessageLookupByLibrary.simpleMessage("My order"),
        "tNotifications": MessageLookupByLibrary.simpleMessage("Notifications"),
        "tOpeningTime": MessageLookupByLibrary.simpleMessage("OPENING TIME"),
        "tOrders": MessageLookupByLibrary.simpleMessage("🛵"),
        "tPetitions": MessageLookupByLibrary.simpleMessage("Petitions"),
        "tPetitionsHistory": MessageLookupByLibrary.simpleMessage("History"),
        "tPickupLocation":
            MessageLookupByLibrary.simpleMessage("Pickup location"),
        "tRegisterStore":
            MessageLookupByLibrary.simpleMessage("Register your store"),
        "tRequestCab": MessageLookupByLibrary.simpleMessage("Request cab"),
        "tRequests": MessageLookupByLibrary.simpleMessage("Requests"),
        "tRequestsHistory": MessageLookupByLibrary.simpleMessage("History"),
        "tStore": MessageLookupByLibrary.simpleMessage("Products"),
        "tStores": MessageLookupByLibrary.simpleMessage("My stores"),
        "tTStore": MessageLookupByLibrary.simpleMessage("Only for you"),
        "tTopUpBalance": MessageLookupByLibrary.simpleMessage("Top up balance"),
        "tWelcome": MessageLookupByLibrary.simpleMessage(
            "Tell us from which location we show you the best restaurants"),
        "tab1": MessageLookupByLibrary.simpleMessage("Stores"),
        "tab2": MessageLookupByLibrary.simpleMessage("On its way")
      };
}
