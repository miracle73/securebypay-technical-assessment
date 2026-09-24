class AppUser {
  const AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        id: j['id'] as String,
        firstName: j['firstName'] as String,
        lastName: j['lastName'] as String,
        email: j['email'] as String,
      );

  final String id;
  final String firstName;
  final String lastName;
  final String email;

  String get initials =>
      '${firstName.isEmpty ? '' : firstName[0]}${lastName.isEmpty ? '' : lastName[0]}'.toUpperCase();
}

class Overview {
  const Overview({
    required this.balance,
    required this.totalShipments,
    required this.totalExports,
    required this.totalImports,
  });

  factory Overview.fromJson(Map<String, dynamic> j) => Overview(
        balance: double.parse(j['balance'].toString()),
        totalShipments: j['totalShipments'] as int,
        totalExports: j['totalExports'] as int,
        totalImports: j['totalImports'] as int,
      );

  final double balance;
  final int totalShipments;
  final int totalExports;
  final int totalImports;
}

enum ShipmentStatus { inTransit, delayed, delivered }

class Shipment {
  const Shipment({
    required this.trackingId,
    required this.sender,
    required this.receiver,
    required this.pickUpFrom,
    required this.deliveryTo,
    required this.amount,
    required this.status,
    required this.paid,
    required this.processingHours,
  });

  factory Shipment.fromJson(Map<String, dynamic> j) => Shipment(
        trackingId: j['trackingId'] as String,
        sender: j['sender'] as String,
        receiver: j['receiver'] as String,
        pickUpFrom: j['pickUpFrom'] as String,
        deliveryTo: j['deliveryTo'] as String,
        amount: double.parse(j['amount'].toString()),
        status: switch (j['status']) {
          'delayed' => ShipmentStatus.delayed,
          'delivered' => ShipmentStatus.delivered,
          _ => ShipmentStatus.inTransit,
        },
        paid: j['paid'] as bool,
        processingHours: j['processingHours'] as int,
      );

  final String trackingId;
  final String sender;
  final String receiver;
  final String pickUpFrom;
  final String deliveryTo;
  final double amount;
  final ShipmentStatus status;
  final bool paid;
  final int processingHours;
}
