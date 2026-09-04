// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a es locale. All the
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
  String get localeName => 'es';

  static String m0(number) => "Mínimo de caracteres ${number}";

  static String m1(email) => "El correo ${email} ya está registrado";

  static String m2(minPurchaseAmountCard, coin) =>
      "El importe mínimo de compra con tarjeta de crédito es de ${minPurchaseAmountCard} ${coin}. Por favor, añada más productos a la cesta. O pague en efectivo";

  static String m3(name) => "El nombre ${name} ya está registrado";

  static String m4(phone) => "El celular ${phone} ya está registrado";

  static String m5(email) =>
      "El correo ${email} no figura en nuestros registros";

  static String m6(phone) => "Tu celular es: ${phone}";

  static String m7(labelCancelButton) =>
      "Si está seguro de querer cancelar el pedido, toque el botón (${labelCancelButton})";

  static String m8(company) =>
      "La empresa ${company}, no envía unidades a su ubicación. Por favor seleccione otra dirección en la pantalla principal y seleccione otra empresa";

  static String m9(distance) =>
      "La distancia mínima del recorrido no puede ser inferior a ${distance} metros";

  static String m10(amount, coin, phone) =>
      "La recarga de\n\n${amount} ${coin} al número\n\n${phone}\n\nse ha completado con éxito";

  static String m11(email) =>
      "Contraseña enviada a ${email}, si no vez el correo revisa en tu bandeja de SPAM";

  static String m12(alias) => "Cerca de ${alias}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "bAccept": MessageLookupByLibrary.simpleMessage("Aceptar"),
        "bCancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "bChangePassword":
            MessageLookupByLibrary.simpleMessage("Cambiar contraseña"),
        "bConfirm": MessageLookupByLibrary.simpleMessage("Confirmar"),
        "bContinue": MessageLookupByLibrary.simpleMessage("Continuar"),
        "bDone": MessageLookupByLibrary.simpleMessage("Hecho"),
        "bEstablishLocation":
            MessageLookupByLibrary.simpleMessage("Establecer ubicación"),
        "bFinish": MessageLookupByLibrary.simpleMessage("Finalizar"),
        "bLogin": MessageLookupByLibrary.simpleMessage("Ingresar"),
        "bNewAddress":
            MessageLookupByLibrary.simpleMessage("Añadir una nueva dirección"),
        "bNewProduct": MessageLookupByLibrary.simpleMessage("Nuevo producto"),
        "bOffline": MessageLookupByLibrary.simpleMessage("Fuera de línea"),
        "bOnline": MessageLookupByLibrary.simpleMessage("En línea"),
        "bPay": MessageLookupByLibrary.simpleMessage("Pagar"),
        "bQualify": MessageLookupByLibrary.simpleMessage("Calificar"),
        "bRecoverAccount":
            MessageLookupByLibrary.simpleMessage("Recuperar cuenta"),
        "bRequestCabt": MessageLookupByLibrary.simpleMessage("Solicitar taxi"),
        "bReturn": MessageLookupByLibrary.simpleMessage("Regresar"),
        "bRouteClient": MessageLookupByLibrary.simpleMessage("Ruta al cliente"),
        "bRouteStore": MessageLookupByLibrary.simpleMessage("Ruta a la tienda"),
        "bSaveChanges": MessageLookupByLibrary.simpleMessage("Guardar"),
        "bSelectAddress":
            MessageLookupByLibrary.simpleMessage("Seleccione una dirección"),
        "bSelectPhoto":
            MessageLookupByLibrary.simpleMessage("Seleccione una foto"),
        "bSetDestinationPoint":
            MessageLookupByLibrary.simpleMessage("Fijar punto de destino"),
        "bSetPickUpPoint":
            MessageLookupByLibrary.simpleMessage("Fijar punto de recogida"),
        "bSignin": MessageLookupByLibrary.simpleMessage("Acceder"),
        "bSignup": MessageLookupByLibrary.simpleMessage("Registrarse"),
        "bUpload": MessageLookupByLibrary.simpleMessage("Subir"),
        "eValidatoAmount":
            MessageLookupByLibrary.simpleMessage("Monto Incorrecto"),
        "eValidatoCharacters": m0,
        "eValidatoEmail": MessageLookupByLibrary.simpleMessage(
            "El formato del correo es incorrecto"),
        "eValidatoPhone": MessageLookupByLibrary.simpleMessage(
            "El formato del celular es incorrecto"),
        "emptyTab2": MessageLookupByLibrary.simpleMessage(
            " No tienes pedidos pendientes"),
        "errDeleteAllAddress": MessageLookupByLibrary.simpleMessage(
            "No puedes eliminar todas las direcciones. Debes tener al menos una"),
        "errDeliverymanNotFound": MessageLookupByLibrary.simpleMessage(
            "El número que proporciono no pertenece a ningún repartidor registrado"),
        "errEmailUnique": m1,
        "errManagerCannotBeDeliveryman": MessageLookupByLibrary.simpleMessage(
            "El número de teléfono que proporciono está asignado a una tienda (rol manager) por lo que no puede ser repartidor (rol deliveryman)"),
        "errMinPurchaseAmountCard": m2,
        "errNameUnique": m3,
        "errPhoneNumber": MessageLookupByLibrary.simpleMessage(
            "Por favor agrega un número de teléfono"),
        "errPhoneNumberAgain": MessageLookupByLibrary.simpleMessage(
            "Por favor agrega de nuevo el número de teléfono"),
        "errPhoneUnique": m4,
        "errPleaseUploadImage":
            MessageLookupByLibrary.simpleMessage("Por favor, sube una imagen"),
        "errRecoverAccount": m5,
        "errUnknown": MessageLookupByLibrary.simpleMessage(
            "Oops, algo parece haber ido mal, por favor, inténtelo de nuevo más tarde"),
        "errdeliverymanCannotBeManager": MessageLookupByLibrary.simpleMessage(
            "El número de teléfono que proporciono está asignado a un repartidor (rol deliveryman) por lo que no puede ser tienda (rol manager)"),
        "hAddress": MessageLookupByLibrary.simpleMessage("Dirección"),
        "hAlias": MessageLookupByLibrary.simpleMessage("Alias"),
        "hChat": MessageLookupByLibrary.simpleMessage("Escribe tu mensaje"),
        "hEmail": MessageLookupByLibrary.simpleMessage("Correo"),
        "hFilter":
            MessageLookupByLibrary.simpleMessage("Hoy, que se te antoja?"),
        "hFullName": MessageLookupByLibrary.simpleMessage("Nombre completo"),
        "hNoteProdcut":
            MessageLookupByLibrary.simpleMessage("Nota para el producto"),
        "hPassword": MessageLookupByLibrary.simpleMessage("Contraseña"),
        "hPhone": MessageLookupByLibrary.simpleMessage("Celular"),
        "hProductDescription":
            MessageLookupByLibrary.simpleMessage("Descripción del producto"),
        "hProductName":
            MessageLookupByLibrary.simpleMessage("Nombre del producto"),
        "hYourPhoneNumber": m6,
        "lAddedCart":
            MessageLookupByLibrary.simpleMessage("Agregado al carrito"),
        "lAmount": MessageLookupByLibrary.simpleMessage("Monto"),
        "lClient": MessageLookupByLibrary.simpleMessage("Cliente"),
        "lClosed": MessageLookupByLibrary.simpleMessage("Cerrado"),
        "lDeliveryAddress":
            MessageLookupByLibrary.simpleMessage("Dirección de entrega"),
        "lDeliveryFee": MessageLookupByLibrary.simpleMessage("Envío"),
        "lDeliveryman": MessageLookupByLibrary.simpleMessage("Repartidor"),
        "lFriday": MessageLookupByLibrary.simpleMessage("Viernes"),
        "lHAmounValid": MessageLookupByLibrary.simpleMessage(
            "Importe a reembolsar por tarjeta de crédito"),
        "lHBalanceValid": MessageLookupByLibrary.simpleMessage(
            "Balance para poder tomar pedidos"),
        "lHMoneyValid": MessageLookupByLibrary.simpleMessage(
            "Este importe reduce automáticamente el pago"),
        "lMonday": MessageLookupByLibrary.simpleMessage("Lunes"),
        "lNewAddress": MessageLookupByLibrary.simpleMessage("Nueva dirección"),
        "lNumber": MessageLookupByLibrary.simpleMessage("Cantidad"),
        "lOrderBy": MessageLookupByLibrary.simpleMessage("Orden a cargo de"),
        "lPayCash": MessageLookupByLibrary.simpleMessage("Pagar en efectivo"),
        "lPayMoney": MessageLookupByLibrary.simpleMessage("Pagar con tarjeta"),
        "lPaymentMethods":
            MessageLookupByLibrary.simpleMessage("Métodos de pago"),
        "lPrice": MessageLookupByLibrary.simpleMessage("Precio"),
        "lProduct": MessageLookupByLibrary.simpleMessage("Producto"),
        "lSaturday": MessageLookupByLibrary.simpleMessage("Sábado"),
        "lSearch": MessageLookupByLibrary.simpleMessage("Buscar"),
        "lSelect": MessageLookupByLibrary.simpleMessage("Seleccionar"),
        "lStatusOrderAssigned": MessageLookupByLibrary.simpleMessage(
            "🛵 El repartidor se dirige a recoger tu pedido"),
        "lStatusOrderCancelled": MessageLookupByLibrary.simpleMessage(
            "🥺 Oops. Lo sentimos, pero el pedido ha sido cancelado. Por favor, califiqua tu experiencia"),
        "lStatusOrderDelivered": MessageLookupByLibrary.simpleMessage(
            "🥳 Gracias por preferirnos. Por favor, califiqua tu experiencia"),
        "lStatusOrderQualified":
            MessageLookupByLibrary.simpleMessage("Gracias por preferirnos"),
        "lStatusOrderStarted": MessageLookupByLibrary.simpleMessage(
            "👨🏼‍🍳 El restaurante esta preparando tu pedido"),
        "lStatusOrderTaken": MessageLookupByLibrary.simpleMessage(
            "💚 El repartidor ya tiene tu pedido"),
        "lStatusTaxiAssigned": MessageLookupByLibrary.simpleMessage(
            "🚖 Se le ha asignado un taxi. 🚕 El taxi se dirige a su ubicación"),
        "lStatusTaxiCancelled": MessageLookupByLibrary.simpleMessage(
            "🥺 Oops. Lo sentimos, pero el pedido ha sido cancelado. Por favor, califiqua tu experiencia"),
        "lStatusTaxiDelivered": MessageLookupByLibrary.simpleMessage(
            "🥳 Gracias por preferirnos. Por favor, califiqua tu experiencia"),
        "lStatusTaxiQualified":
            MessageLookupByLibrary.simpleMessage("Gracias por preferirnos"),
        "lStatusTaxiStarted": MessageLookupByLibrary.simpleMessage(
            "🔎 Estamos buscando una unidad cercana"),
        "lStatusTaxiTaken": MessageLookupByLibrary.simpleMessage(
            "💚 El conductor ha informado de que ha subido al vehículo"),
        "lSunday": MessageLookupByLibrary.simpleMessage("Domingo"),
        "lTMoneyValid": MessageLookupByLibrary.simpleMessage(
            "Money. Válido sólo con tarjeta de crédito"),
        "lThursday": MessageLookupByLibrary.simpleMessage("Jueves"),
        "lTotal": MessageLookupByLibrary.simpleMessage("Total"),
        "lTuesday": MessageLookupByLibrary.simpleMessage("Martes"),
        "lWednesday": MessageLookupByLibrary.simpleMessage("Miércoles"),
        "lselectCategory":
            MessageLookupByLibrary.simpleMessage("Selecciona una categoría"),
        "lselectGroup":
            MessageLookupByLibrary.simpleMessage("Selecciona un grupo"),
        "lselectPayment": MessageLookupByLibrary.simpleMessage(
            "Selecciona un método de pago"),
        "mDCancelOrder": m7,
        "mDConfirmOrder": MessageLookupByLibrary.simpleMessage(
            "Confirma que has recogido el pedido"),
        "mDFinish": MessageLookupByLibrary.simpleMessage(
            "Por favor califica al cliente"),
        "mDLogoutSession": MessageLookupByLibrary.simpleMessage(
            "Seguro que quieres cerrar la sesión?"),
        "mDStoreClosed": MessageLookupByLibrary.simpleMessage(
            "Esta tienda está cerrada, puedes ver sus productos pero no podrás hacer una compra hasta que la tienda esté abierta"),
        "mEither": MessageLookupByLibrary.simpleMessage("o bien"),
        "mIncorrectLogin": MessageLookupByLibrary.simpleMessage(
            "Usuario o contraseña incorrectos"),
        "mMaximumDistanceStoreStartingPoint": m8,
        "mMinimumTravelDistance": m9,
        "mRAddressRemoved":
            MessageLookupByLibrary.simpleMessage("Dirección eliminada"),
        "mRChangesMadeCorrectly": MessageLookupByLibrary.simpleMessage(
            "Cambios realizados correctamente"),
        "mRConfirmOrde": MessageLookupByLibrary.simpleMessage(
            "En hora buena. Notificamos que has recogido el pedido"),
        "mRStoreCongratulations": MessageLookupByLibrary.simpleMessage(
            "Felicitaciones, has registrado correctamente tu tienda. Ahora crea tus productos y empieza a vender"),
        "mRTopUpBalance": m10,
        "mRecoverAccount": m11,
        "mRinsufficientBalance": MessageLookupByLibrary.simpleMessage(
            "Fondos insuficientes. Por favor, recarga tu saldo"),
        "mRorderFulfilled": MessageLookupByLibrary.simpleMessage(
            "Oops, la solicitud ya se ha atendido"),
        "sFeatured":
            MessageLookupByLibrary.simpleMessage("Las personas los aman"),
        "sSlideApply":
            MessageLookupByLibrary.simpleMessage("Desliza para aplicar"),
        "sTCategory":
            MessageLookupByLibrary.simpleMessage("Filtrar por categoria"),
        "sTCompanyPopular":
            MessageLookupByLibrary.simpleMessage("No te los puedes perder"),
        "sTCompanyTop":
            MessageLookupByLibrary.simpleMessage("Tienes que probarlos"),
        "sTOrders": MessageLookupByLibrary.simpleMessage("En camnino"),
        "tAbout": MessageLookupByLibrary.simpleMessage("Acerca de"),
        "tAddress": MessageLookupByLibrary.simpleMessage("Direccion"),
        "tAddresses": MessageLookupByLibrary.simpleMessage("Direcciones"),
        "tAppBarOrders": MessageLookupByLibrary.simpleMessage("Pedidos"),
        "tCartSummary": MessageLookupByLibrary.simpleMessage(
            "Resumen y dirección de entrega"),
        "tCategories": MessageLookupByLibrary.simpleMessage("Categorias"),
        "tCloseTo": m12,
        "tClosingTime": MessageLookupByLibrary.simpleMessage("HORA DE CIERRE"),
        "tCompanyPopular":
            MessageLookupByLibrary.simpleMessage("Lo más comprado"),
        "tCompanyTop":
            MessageLookupByLibrary.simpleMessage("Los mejor valorados"),
        "tDestination": MessageLookupByLibrary.simpleMessage("Destino"),
        "tFeatured": MessageLookupByLibrary.simpleMessage("Destacados"),
        "tMyOrder": MessageLookupByLibrary.simpleMessage("Mi pedido"),
        "tNotifications":
            MessageLookupByLibrary.simpleMessage("Notificaciones"),
        "tOpeningTime":
            MessageLookupByLibrary.simpleMessage("HORA DE APERTURA"),
        "tOrders": MessageLookupByLibrary.simpleMessage("🛵"),
        "tPetitions": MessageLookupByLibrary.simpleMessage("Pedidos"),
        "tPetitionsHistory": MessageLookupByLibrary.simpleMessage("Historial"),
        "tPickupLocation":
            MessageLookupByLibrary.simpleMessage("Lugar de recogida"),
        "tRegisterStore":
            MessageLookupByLibrary.simpleMessage("Registra tu tienda"),
        "tRequestCab": MessageLookupByLibrary.simpleMessage("Solicitar taxi"),
        "tRequests": MessageLookupByLibrary.simpleMessage("Pedidos"),
        "tRequestsHistory": MessageLookupByLibrary.simpleMessage("Historial"),
        "tStore": MessageLookupByLibrary.simpleMessage("Productos"),
        "tStores": MessageLookupByLibrary.simpleMessage("Mis tiendas"),
        "tTStore": MessageLookupByLibrary.simpleMessage("Solo para ti"),
        "tTopUpBalance":
            MessageLookupByLibrary.simpleMessage("Recarga de saldo"),
        "tWelcome": MessageLookupByLibrary.simpleMessage(
            "Dinos de que lugar te mostramos los mejores restaurantes"),
        "tab1": MessageLookupByLibrary.simpleMessage("Tiendas"),
        "tab2": MessageLookupByLibrary.simpleMessage("En camino")
      };
}
