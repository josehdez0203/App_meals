// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Tell us from which location we show you the best restaurants`
  String get tWelcome {
    return Intl.message(
      'Tell us from which location we show you the best restaurants',
      name: 'tWelcome',
      desc: '',
      args: [],
    );
  }

  /// `either`
  String get mEither {
    return Intl.message(
      'either',
      name: 'mEither',
      desc: '',
      args: [],
    );
  }

  /// `Featured`
  String get tFeatured {
    return Intl.message(
      'Featured',
      name: 'tFeatured',
      desc: '',
      args: [],
    );
  }

  /// `People love them`
  String get sFeatured {
    return Intl.message(
      'People love them',
      name: 'sFeatured',
      desc: '',
      args: [],
    );
  }

  /// `Categories`
  String get tCategories {
    return Intl.message(
      'Categories',
      name: 'tCategories',
      desc: '',
      args: [],
    );
  }

  /// `Filter by category`
  String get sTCategory {
    return Intl.message(
      'Filter by category',
      name: 'sTCategory',
      desc: '',
      args: [],
    );
  }

  /// `The best rated`
  String get tCompanyTop {
    return Intl.message(
      'The best rated',
      name: 'tCompanyTop',
      desc: '',
      args: [],
    );
  }

  /// `You have to try them`
  String get sTCompanyTop {
    return Intl.message(
      'You have to try them',
      name: 'sTCompanyTop',
      desc: '',
      args: [],
    );
  }

  /// `Most purchased`
  String get tCompanyPopular {
    return Intl.message(
      'Most purchased',
      name: 'tCompanyPopular',
      desc: '',
      args: [],
    );
  }

  /// `You can't miss them`
  String get sTCompanyPopular {
    return Intl.message(
      'You can\'t miss them',
      name: 'sTCompanyPopular',
      desc: '',
      args: [],
    );
  }

  /// `🛵`
  String get tOrders {
    return Intl.message(
      '🛵',
      name: 'tOrders',
      desc: '',
      args: [],
    );
  }

  /// `on its way`
  String get sTOrders {
    return Intl.message(
      'on its way',
      name: 'sTOrders',
      desc: '',
      args: [],
    );
  }

  /// `Address`
  String get tAddress {
    return Intl.message(
      'Address',
      name: 'tAddress',
      desc: '',
      args: [],
    );
  }

  /// `Addresses`
  String get tAddresses {
    return Intl.message(
      'Addresses',
      name: 'tAddresses',
      desc: '',
      args: [],
    );
  }

  /// `My stores`
  String get tStores {
    return Intl.message(
      'My stores',
      name: 'tStores',
      desc: '',
      args: [],
    );
  }

  /// `Register your store`
  String get tRegisterStore {
    return Intl.message(
      'Register your store',
      name: 'tRegisterStore',
      desc: '',
      args: [],
    );
  }

  /// `Top up balance`
  String get tTopUpBalance {
    return Intl.message(
      'Top up balance',
      name: 'tTopUpBalance',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get tNotifications {
    return Intl.message(
      'Notifications',
      name: 'tNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Stores`
  String get tab1 {
    return Intl.message(
      'Stores',
      name: 'tab1',
      desc: '',
      args: [],
    );
  }

  /// `On its way`
  String get tab2 {
    return Intl.message(
      'On its way',
      name: 'tab2',
      desc: '',
      args: [],
    );
  }

  /// `Products`
  String get tStore {
    return Intl.message(
      'Products',
      name: 'tStore',
      desc: '',
      args: [],
    );
  }

  /// `Only for you`
  String get tTStore {
    return Intl.message(
      'Only for you',
      name: 'tTStore',
      desc: '',
      args: [],
    );
  }

  /// `Orders`
  String get tAppBarOrders {
    return Intl.message(
      'Orders',
      name: 'tAppBarOrders',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get tAbout {
    return Intl.message(
      'About',
      name: 'tAbout',
      desc: '',
      args: [],
    );
  }

  /// `Close to {alias}`
  String tCloseTo(Object alias) {
    return Intl.message(
      'Close to $alias',
      name: 'tCloseTo',
      desc: '',
      args: [alias],
    );
  }

  /// `Petitions`
  String get tPetitions {
    return Intl.message(
      'Petitions',
      name: 'tPetitions',
      desc: '',
      args: [],
    );
  }

  /// `History`
  String get tPetitionsHistory {
    return Intl.message(
      'History',
      name: 'tPetitionsHistory',
      desc: '',
      args: [],
    );
  }

  /// `Requests`
  String get tRequests {
    return Intl.message(
      'Requests',
      name: 'tRequests',
      desc: '',
      args: [],
    );
  }

  /// `History`
  String get tRequestsHistory {
    return Intl.message(
      'History',
      name: 'tRequestsHistory',
      desc: '',
      args: [],
    );
  }

  /// `Pickup location`
  String get tPickupLocation {
    return Intl.message(
      'Pickup location',
      name: 'tPickupLocation',
      desc: '',
      args: [],
    );
  }

  /// `Destination`
  String get tDestination {
    return Intl.message(
      'Destination',
      name: 'tDestination',
      desc: '',
      args: [],
    );
  }

  /// `Request cab`
  String get tRequestCab {
    return Intl.message(
      'Request cab',
      name: 'tRequestCab',
      desc: '',
      args: [],
    );
  }

  /// `OPENING TIME`
  String get tOpeningTime {
    return Intl.message(
      'OPENING TIME',
      name: 'tOpeningTime',
      desc: '',
      args: [],
    );
  }

  /// `CLOSING TIME`
  String get tClosingTime {
    return Intl.message(
      'CLOSING TIME',
      name: 'tClosingTime',
      desc: '',
      args: [],
    );
  }

  /// `Shipment`
  String get lDeliveryFee {
    return Intl.message(
      'Shipment',
      name: 'lDeliveryFee',
      desc: '',
      args: [],
    );
  }

  /// `Added to cart`
  String get lAddedCart {
    return Intl.message(
      'Added to cart',
      name: 'lAddedCart',
      desc: '',
      args: [],
    );
  }

  /// `Order by`
  String get lOrderBy {
    return Intl.message(
      'Order by',
      name: 'lOrderBy',
      desc: '',
      args: [],
    );
  }

  /// `Deliveryman`
  String get lDeliveryman {
    return Intl.message(
      'Deliveryman',
      name: 'lDeliveryman',
      desc: '',
      args: [],
    );
  }

  /// `Client`
  String get lClient {
    return Intl.message(
      'Client',
      name: 'lClient',
      desc: '',
      args: [],
    );
  }

  /// `Total`
  String get lTotal {
    return Intl.message(
      'Total',
      name: 'lTotal',
      desc: '',
      args: [],
    );
  }

  /// `Price`
  String get lPrice {
    return Intl.message(
      'Price',
      name: 'lPrice',
      desc: '',
      args: [],
    );
  }

  /// `Amount`
  String get lAmount {
    return Intl.message(
      'Amount',
      name: 'lAmount',
      desc: '',
      args: [],
    );
  }

  /// `Product`
  String get lProduct {
    return Intl.message(
      'Product',
      name: 'lProduct',
      desc: '',
      args: [],
    );
  }

  /// `Number`
  String get lNumber {
    return Intl.message(
      'Number',
      name: 'lNumber',
      desc: '',
      args: [],
    );
  }

  /// `Delivery address`
  String get lDeliveryAddress {
    return Intl.message(
      'Delivery address',
      name: 'lDeliveryAddress',
      desc: '',
      args: [],
    );
  }

  /// `Payment methods`
  String get lPaymentMethods {
    return Intl.message(
      'Payment methods',
      name: 'lPaymentMethods',
      desc: '',
      args: [],
    );
  }

  /// `New address`
  String get lNewAddress {
    return Intl.message(
      'New address',
      name: 'lNewAddress',
      desc: '',
      args: [],
    );
  }

  /// `Select`
  String get lSelect {
    return Intl.message(
      'Select',
      name: 'lSelect',
      desc: '',
      args: [],
    );
  }

  /// `Closed`
  String get lClosed {
    return Intl.message(
      'Closed',
      name: 'lClosed',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get lSearch {
    return Intl.message(
      'Search',
      name: 'lSearch',
      desc: '',
      args: [],
    );
  }

  /// `Select a category`
  String get lselectCategory {
    return Intl.message(
      'Select a category',
      name: 'lselectCategory',
      desc: '',
      args: [],
    );
  }

  /// `Select a payment method`
  String get lselectPayment {
    return Intl.message(
      'Select a payment method',
      name: 'lselectPayment',
      desc: '',
      args: [],
    );
  }

  /// `Select a group`
  String get lselectGroup {
    return Intl.message(
      'Select a group',
      name: 'lselectGroup',
      desc: '',
      args: [],
    );
  }

  /// `Pay in cash`
  String get lPayCash {
    return Intl.message(
      'Pay in cash',
      name: 'lPayCash',
      desc: '',
      args: [],
    );
  }

  /// `Pay by credit card`
  String get lPayMoney {
    return Intl.message(
      'Pay by credit card',
      name: 'lPayMoney',
      desc: '',
      args: [],
    );
  }

  /// `Money. Valid only with credit card`
  String get lTMoneyValid {
    return Intl.message(
      'Money. Valid only with credit card',
      name: 'lTMoneyValid',
      desc: '',
      args: [],
    );
  }

  /// `This amount automatically reduces the payment`
  String get lHMoneyValid {
    return Intl.message(
      'This amount automatically reduces the payment',
      name: 'lHMoneyValid',
      desc: '',
      args: [],
    );
  }

  /// `Balance to be able to take orders`
  String get lHBalanceValid {
    return Intl.message(
      'Balance to be able to take orders',
      name: 'lHBalanceValid',
      desc: '',
      args: [],
    );
  }

  /// `Amount to be refunded by credit card`
  String get lHAmounValid {
    return Intl.message(
      'Amount to be refunded by credit card',
      name: 'lHAmounValid',
      desc: '',
      args: [],
    );
  }

  /// `My order`
  String get tMyOrder {
    return Intl.message(
      'My order',
      name: 'tMyOrder',
      desc: '',
      args: [],
    );
  }

  /// `Summary & Address of delivery`
  String get tCartSummary {
    return Intl.message(
      'Summary & Address of delivery',
      name: 'tCartSummary',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get bContinue {
    return Intl.message(
      'Continue',
      name: 'bContinue',
      desc: '',
      args: [],
    );
  }

  /// `Pay`
  String get bPay {
    return Intl.message(
      'Pay',
      name: 'bPay',
      desc: '',
      args: [],
    );
  }

  /// `Set location`
  String get bEstablishLocation {
    return Intl.message(
      'Set location',
      name: 'bEstablishLocation',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get bLogin {
    return Intl.message(
      'Login',
      name: 'bLogin',
      desc: '',
      args: [],
    );
  }

  /// `Sign in`
  String get bSignin {
    return Intl.message(
      'Sign in',
      name: 'bSignin',
      desc: '',
      args: [],
    );
  }

  /// `Sign up`
  String get bSignup {
    return Intl.message(
      'Sign up',
      name: 'bSignup',
      desc: '',
      args: [],
    );
  }

  /// `Recover account`
  String get bRecoverAccount {
    return Intl.message(
      'Recover account',
      name: 'bRecoverAccount',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get bSaveChanges {
    return Intl.message(
      'Save',
      name: 'bSaveChanges',
      desc: '',
      args: [],
    );
  }

  /// `Upload`
  String get bUpload {
    return Intl.message(
      'Upload',
      name: 'bUpload',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get bCancel {
    return Intl.message(
      'Cancel',
      name: 'bCancel',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get bConfirm {
    return Intl.message(
      'Confirm',
      name: 'bConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Finish`
  String get bFinish {
    return Intl.message(
      'Finish',
      name: 'bFinish',
      desc: '',
      args: [],
    );
  }

  /// `Route to the client`
  String get bRouteClient {
    return Intl.message(
      'Route to the client',
      name: 'bRouteClient',
      desc: '',
      args: [],
    );
  }

  /// `Route to the store`
  String get bRouteStore {
    return Intl.message(
      'Route to the store',
      name: 'bRouteStore',
      desc: '',
      args: [],
    );
  }

  /// `Qualify`
  String get bQualify {
    return Intl.message(
      'Qualify',
      name: 'bQualify',
      desc: '',
      args: [],
    );
  }

  /// `Online`
  String get bOnline {
    return Intl.message(
      'Online',
      name: 'bOnline',
      desc: '',
      args: [],
    );
  }

  /// `Offline`
  String get bOffline {
    return Intl.message(
      'Offline',
      name: 'bOffline',
      desc: '',
      args: [],
    );
  }

  /// `Add a new address`
  String get bNewAddress {
    return Intl.message(
      'Add a new address',
      name: 'bNewAddress',
      desc: '',
      args: [],
    );
  }

  /// `Accept`
  String get bAccept {
    return Intl.message(
      'Accept',
      name: 'bAccept',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get bDone {
    return Intl.message(
      'Done',
      name: 'bDone',
      desc: '',
      args: [],
    );
  }

  /// `Change password`
  String get bChangePassword {
    return Intl.message(
      'Change password',
      name: 'bChangePassword',
      desc: '',
      args: [],
    );
  }

  /// `Select a photo`
  String get bSelectPhoto {
    return Intl.message(
      'Select a photo',
      name: 'bSelectPhoto',
      desc: '',
      args: [],
    );
  }

  /// `Select an address`
  String get bSelectAddress {
    return Intl.message(
      'Select an address',
      name: 'bSelectAddress',
      desc: '',
      args: [],
    );
  }

  /// `New product`
  String get bNewProduct {
    return Intl.message(
      'New product',
      name: 'bNewProduct',
      desc: '',
      args: [],
    );
  }

  /// `Return`
  String get bReturn {
    return Intl.message(
      'Return',
      name: 'bReturn',
      desc: '',
      args: [],
    );
  }

  /// `Set pick-up point`
  String get bSetPickUpPoint {
    return Intl.message(
      'Set pick-up point',
      name: 'bSetPickUpPoint',
      desc: '',
      args: [],
    );
  }

  /// `Set destination point`
  String get bSetDestinationPoint {
    return Intl.message(
      'Set destination point',
      name: 'bSetDestinationPoint',
      desc: '',
      args: [],
    );
  }

  /// `Request cab`
  String get bRequestCabt {
    return Intl.message(
      'Request cab',
      name: 'bRequestCabt',
      desc: '',
      args: [],
    );
  }

  /// `Slide to apply`
  String get sSlideApply {
    return Intl.message(
      'Slide to apply',
      name: 'sSlideApply',
      desc: '',
      args: [],
    );
  }

  /// `Type a note for the product`
  String get hNoteProdcut {
    return Intl.message(
      'Type a note for the product',
      name: 'hNoteProdcut',
      desc: '',
      args: [],
    );
  }

  /// `Type your message`
  String get hChat {
    return Intl.message(
      'Type your message',
      name: 'hChat',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get hEmail {
    return Intl.message(
      'Email',
      name: 'hEmail',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get hPassword {
    return Intl.message(
      'Password',
      name: 'hPassword',
      desc: '',
      args: [],
    );
  }

  /// `Phone number`
  String get hPhone {
    return Intl.message(
      'Phone number',
      name: 'hPhone',
      desc: '',
      args: [],
    );
  }

  /// `Full name`
  String get hFullName {
    return Intl.message(
      'Full name',
      name: 'hFullName',
      desc: '',
      args: [],
    );
  }

  /// `Address`
  String get hAddress {
    return Intl.message(
      'Address',
      name: 'hAddress',
      desc: '',
      args: [],
    );
  }

  /// `Alias`
  String get hAlias {
    return Intl.message(
      'Alias',
      name: 'hAlias',
      desc: '',
      args: [],
    );
  }

  /// `Your phone number is: {phone}`
  String hYourPhoneNumber(Object phone) {
    return Intl.message(
      'Your phone number is: $phone',
      name: 'hYourPhoneNumber',
      desc: '',
      args: [phone],
    );
  }

  /// `Product name`
  String get hProductName {
    return Intl.message(
      'Product name',
      name: 'hProductName',
      desc: '',
      args: [],
    );
  }

  /// `Product description`
  String get hProductDescription {
    return Intl.message(
      'Product description',
      name: 'hProductDescription',
      desc: '',
      args: [],
    );
  }

  /// `What do you want to eat today?`
  String get hFilter {
    return Intl.message(
      'What do you want to eat today?',
      name: 'hFilter',
      desc: '',
      args: [],
    );
  }

  /// `The mail format is incorrect`
  String get eValidatoEmail {
    return Intl.message(
      'The mail format is incorrect',
      name: 'eValidatoEmail',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect Amount`
  String get eValidatoAmount {
    return Intl.message(
      'Incorrect Amount',
      name: 'eValidatoAmount',
      desc: '',
      args: [],
    );
  }

  /// `Minimum of characters {number}`
  String eValidatoCharacters(Object number) {
    return Intl.message(
      'Minimum of characters $number',
      name: 'eValidatoCharacters',
      desc: '',
      args: [number],
    );
  }

  /// `The phone number format is incorrect`
  String get eValidatoPhone {
    return Intl.message(
      'The phone number format is incorrect',
      name: 'eValidatoPhone',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect username or password`
  String get mIncorrectLogin {
    return Intl.message(
      'Incorrect username or password',
      name: 'mIncorrectLogin',
      desc: '',
      args: [],
    );
  }

  /// `Oops, something seems to have gone wrong, please try again later`
  String get errUnknown {
    return Intl.message(
      'Oops, something seems to have gone wrong, please try again later',
      name: 'errUnknown',
      desc: '',
      args: [],
    );
  }

  /// `The email {email} is already registered`
  String errEmailUnique(Object email) {
    return Intl.message(
      'The email $email is already registered',
      name: 'errEmailUnique',
      desc: '',
      args: [email],
    );
  }

  /// `The phone number {phone} is already registered`
  String errPhoneUnique(Object phone) {
    return Intl.message(
      'The phone number $phone is already registered',
      name: 'errPhoneUnique',
      desc: '',
      args: [phone],
    );
  }

  /// `The name {name} is already registered`
  String errNameUnique(Object name) {
    return Intl.message(
      'The name $name is already registered',
      name: 'errNameUnique',
      desc: '',
      args: [name],
    );
  }

  /// `The email address {email} is not in our records.`
  String errRecoverAccount(Object email) {
    return Intl.message(
      'The email address $email is not in our records.',
      name: 'errRecoverAccount',
      desc: '',
      args: [email],
    );
  }

  /// `You cannot delete all addresses. You must have at least one`
  String get errDeleteAllAddress {
    return Intl.message(
      'You cannot delete all addresses. You must have at least one',
      name: 'errDeleteAllAddress',
      desc: '',
      args: [],
    );
  }

  /// `Please add the phone number again`
  String get errPhoneNumberAgain {
    return Intl.message(
      'Please add the phone number again',
      name: 'errPhoneNumberAgain',
      desc: '',
      args: [],
    );
  }

  /// `Please upload an image`
  String get errPleaseUploadImage {
    return Intl.message(
      'Please upload an image',
      name: 'errPleaseUploadImage',
      desc: '',
      args: [],
    );
  }

  /// `Please add a phone number`
  String get errPhoneNumber {
    return Intl.message(
      'Please add a phone number',
      name: 'errPhoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `The minimum credit card purchase amount is {minPurchaseAmountCard} {coin}. Please add more products to the cart. Or pay cash`
  String errMinPurchaseAmountCard(Object minPurchaseAmountCard, Object coin) {
    return Intl.message(
      'The minimum credit card purchase amount is $minPurchaseAmountCard $coin. Please add more products to the cart. Or pay cash',
      name: 'errMinPurchaseAmountCard',
      desc: '',
      args: [minPurchaseAmountCard, coin],
    );
  }

  /// `The number I provide does not belong to any registered deliveryman`
  String get errDeliverymanNotFound {
    return Intl.message(
      'The number I provide does not belong to any registered deliveryman',
      name: 'errDeliverymanNotFound',
      desc: '',
      args: [],
    );
  }

  /// `The phone number I provide is assigned to a store (manager role) so it cannot deliveryman (deliveryman role)`
  String get errManagerCannotBeDeliveryman {
    return Intl.message(
      'The phone number I provide is assigned to a store (manager role) so it cannot deliveryman (deliveryman role)',
      name: 'errManagerCannotBeDeliveryman',
      desc: '',
      args: [],
    );
  }

  /// `The phone number I provide is assigned to a deliveryman (deliveryman role) so it cannot manager (manager role)`
  String get errdeliverymanCannotBeManager {
    return Intl.message(
      'The phone number I provide is assigned to a deliveryman (deliveryman role) so it cannot manager (manager role)',
      name: 'errdeliverymanCannotBeManager',
      desc: '',
      args: [],
    );
  }

  /// `👨🏼‍🍳 The restaurant is preparing your order`
  String get lStatusOrderStarted {
    return Intl.message(
      '👨🏼‍🍳 The restaurant is preparing your order',
      name: 'lStatusOrderStarted',
      desc: '',
      args: [],
    );
  }

  /// `🛵 The delivery man is on his way to pick up your order`
  String get lStatusOrderAssigned {
    return Intl.message(
      '🛵 The delivery man is on his way to pick up your order',
      name: 'lStatusOrderAssigned',
      desc: '',
      args: [],
    );
  }

  /// `💚 The driver has reported boarding the vehicle`
  String get lStatusOrderTaken {
    return Intl.message(
      '💚 The driver has reported boarding the vehicle',
      name: 'lStatusOrderTaken',
      desc: '',
      args: [],
    );
  }

  /// `🥳 Thank you for choosing us. Please rate your experience`
  String get lStatusOrderDelivered {
    return Intl.message(
      '🥳 Thank you for choosing us. Please rate your experience',
      name: 'lStatusOrderDelivered',
      desc: '',
      args: [],
    );
  }

  /// `🥺 Oops. Sorry, but the order has been cancelled. Please rate your experience`
  String get lStatusOrderCancelled {
    return Intl.message(
      '🥺 Oops. Sorry, but the order has been cancelled. Please rate your experience',
      name: 'lStatusOrderCancelled',
      desc: '',
      args: [],
    );
  }

  /// `Thank you for choosing us`
  String get lStatusOrderQualified {
    return Intl.message(
      'Thank you for choosing us',
      name: 'lStatusOrderQualified',
      desc: '',
      args: [],
    );
  }

  /// `🔎 We are looking for a nearby unit`
  String get lStatusTaxiStarted {
    return Intl.message(
      '🔎 We are looking for a nearby unit',
      name: 'lStatusTaxiStarted',
      desc: '',
      args: [],
    );
  }

  /// `🚖 You have been assigned a cab. 🚕 The cab is heading to your location`
  String get lStatusTaxiAssigned {
    return Intl.message(
      '🚖 You have been assigned a cab. 🚕 The cab is heading to your location',
      name: 'lStatusTaxiAssigned',
      desc: '',
      args: [],
    );
  }

  /// `💚 The driver has reported boarding the vehicle.`
  String get lStatusTaxiTaken {
    return Intl.message(
      '💚 The driver has reported boarding the vehicle.',
      name: 'lStatusTaxiTaken',
      desc: '',
      args: [],
    );
  }

  /// `🥳 Thank you for choosing us. Please rate your experience`
  String get lStatusTaxiDelivered {
    return Intl.message(
      '🥳 Thank you for choosing us. Please rate your experience',
      name: 'lStatusTaxiDelivered',
      desc: '',
      args: [],
    );
  }

  /// `🥺 Oops. Sorry, but the order has been cancelled. Please rate your experience`
  String get lStatusTaxiCancelled {
    return Intl.message(
      '🥺 Oops. Sorry, but the order has been cancelled. Please rate your experience',
      name: 'lStatusTaxiCancelled',
      desc: '',
      args: [],
    );
  }

  /// `Thank you for choosing us`
  String get lStatusTaxiQualified {
    return Intl.message(
      'Thank you for choosing us',
      name: 'lStatusTaxiQualified',
      desc: '',
      args: [],
    );
  }

  /// `Confirm that you have picked up the order`
  String get mDConfirmOrder {
    return Intl.message(
      'Confirm that you have picked up the order',
      name: 'mDConfirmOrder',
      desc: '',
      args: [],
    );
  }

  /// `Cool. We notify that you have picked up the order`
  String get mRConfirmOrde {
    return Intl.message(
      'Cool. We notify that you have picked up the order',
      name: 'mRConfirmOrde',
      desc: '',
      args: [],
    );
  }

  /// `Congratulations, you have successfully registered your store. Now create your products and start selling`
  String get mRStoreCongratulations {
    return Intl.message(
      'Congratulations, you have successfully registered your store. Now create your products and start selling',
      name: 'mRStoreCongratulations',
      desc: '',
      args: [],
    );
  }

  /// `Address removed`
  String get mRAddressRemoved {
    return Intl.message(
      'Address removed',
      name: 'mRAddressRemoved',
      desc: '',
      args: [],
    );
  }

  /// `Changes made correctly`
  String get mRChangesMadeCorrectly {
    return Intl.message(
      'Changes made correctly',
      name: 'mRChangesMadeCorrectly',
      desc: '',
      args: [],
    );
  }

  /// `The recharge of\n\n{amount} {coin} to the number\n\n{phone}\n\nhas been successfully completed`
  String mRTopUpBalance(Object amount, Object coin, Object phone) {
    return Intl.message(
      'The recharge of\n\n$amount $coin to the number\n\n$phone\n\nhas been successfully completed',
      name: 'mRTopUpBalance',
      desc: '',
      args: [amount, coin, phone],
    );
  }

  /// `Please rate the client`
  String get mDFinish {
    return Intl.message(
      'Please rate the client',
      name: 'mDFinish',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to log out?`
  String get mDLogoutSession {
    return Intl.message(
      'Are you sure you want to log out?',
      name: 'mDLogoutSession',
      desc: '',
      args: [],
    );
  }

  /// `This store is closed, you can view their products but you will not be able to make a purchase until the store is open`
  String get mDStoreClosed {
    return Intl.message(
      'This store is closed, you can view their products but you will not be able to make a purchase until the store is open',
      name: 'mDStoreClosed',
      desc: '',
      args: [],
    );
  }

  /// `If you are sure you want to cancel the order, touch on the ({labelCancelButton}) button`
  String mDCancelOrder(Object labelCancelButton) {
    return Intl.message(
      'If you are sure you want to cancel the order, touch on the ($labelCancelButton) button',
      name: 'mDCancelOrder',
      desc: '',
      args: [labelCancelButton],
    );
  }

  /// `Password sent to {email}, if you don't see the email check your SPAM folder`
  String mRecoverAccount(Object email) {
    return Intl.message(
      'Password sent to $email, if you don\'t see the email check your SPAM folder',
      name: 'mRecoverAccount',
      desc: '',
      args: [email],
    );
  }

  /// `Oops, the request has already been fulfilled`
  String get mRorderFulfilled {
    return Intl.message(
      'Oops, the request has already been fulfilled',
      name: 'mRorderFulfilled',
      desc: '',
      args: [],
    );
  }

  /// `Insufficient funds. Please top up your balance`
  String get mRinsufficientBalance {
    return Intl.message(
      'Insufficient funds. Please top up your balance',
      name: 'mRinsufficientBalance',
      desc: '',
      args: [],
    );
  }

  /// `The company {company}, does not ship units to your location. Please select another address on the main screen and select another company`
  String mMaximumDistanceStoreStartingPoint(Object company) {
    return Intl.message(
      'The company $company, does not ship units to your location. Please select another address on the main screen and select another company',
      name: 'mMaximumDistanceStoreStartingPoint',
      desc: '',
      args: [company],
    );
  }

  /// `The minimum distance of the route cannot be less than {distance} meters`
  String mMinimumTravelDistance(Object distance) {
    return Intl.message(
      'The minimum distance of the route cannot be less than $distance meters',
      name: 'mMinimumTravelDistance',
      desc: '',
      args: [distance],
    );
  }

  /// `You have does not pending orders`
  String get emptyTab2 {
    return Intl.message(
      'You have does not pending orders',
      name: 'emptyTab2',
      desc: '',
      args: [],
    );
  }

  /// `Monday`
  String get lMonday {
    return Intl.message(
      'Monday',
      name: 'lMonday',
      desc: '',
      args: [],
    );
  }

  /// `Tuesday`
  String get lTuesday {
    return Intl.message(
      'Tuesday',
      name: 'lTuesday',
      desc: '',
      args: [],
    );
  }

  /// `Wednesday`
  String get lWednesday {
    return Intl.message(
      'Wednesday',
      name: 'lWednesday',
      desc: '',
      args: [],
    );
  }

  /// `Thursday`
  String get lThursday {
    return Intl.message(
      'Thursday',
      name: 'lThursday',
      desc: '',
      args: [],
    );
  }

  /// `Friday`
  String get lFriday {
    return Intl.message(
      'Friday',
      name: 'lFriday',
      desc: '',
      args: [],
    );
  }

  /// `Saturday`
  String get lSaturday {
    return Intl.message(
      'Saturday',
      name: 'lSaturday',
      desc: '',
      args: [],
    );
  }

  /// `Sunday`
  String get lSunday {
    return Intl.message(
      'Sunday',
      name: 'lSunday',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'es'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
