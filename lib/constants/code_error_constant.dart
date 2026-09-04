class CodeError {
  static const int none = 0;
  static const int unknown = 100;
  static const int emailUnique = 101;
  static const int phoneUnique = 102;
  static const int nameUnique = 103;

  static const int unauthorized = 401;
  static const int accountnotexist = 402;

  static const int notBalance = 501;
  static const int insufficientBalance = 502;
  static const int orderFulfilled = 503;

  static const int deliverymanNotFound = 4001;

  //The deliveryman role cannot have the role of manager.
  static const int deliverymanCannotBeManager = 4002;

  //The manager role cannot have the role of deliveryman.
  static const int managerCannotBeDeliveryman = 4002;
}
