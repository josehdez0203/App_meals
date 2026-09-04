class TypesNotification {
  static const String newOrder = '1010';
  static const String messageChat = '3001';
  static const String changeOrderStatust = '5001';
}

class TypesRol {
  static const String admin = 'admin';
  static const String client = 'client';
  static const String deliveryman = 'deliveryman';
  static const String manager = 'manager';
}

class TypesPayment {
  static const int cash = 5001;

  // Credit card
  static const int money = 6002;

  static const int none = 0;
}

class TypesCompany {
  static const int store = 10;
  static const int taxi = 20;
}
