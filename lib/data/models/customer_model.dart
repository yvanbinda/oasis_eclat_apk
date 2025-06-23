class Customer {
  final int? id;
  final String customerName;
  final String service;
  final String address;
  final String phone;
  final String dateTime; // ISO 8601 format: "2024-12-25T14:30:00"
  final double amountToBePaid;
  final bool isCleaned;

  Customer({
    this.id,
    required this.customerName,
    required this.service,
    required this.address,
    required this.phone,
    required this.dateTime,
    required this.amountToBePaid,
    this.isCleaned = false,
  });

  // Convert Customer object to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_name': customerName,
      'service': service,
      'address': address,
      'phone': phone,
      'date_time': dateTime,
      'amount_to_be_paid': amountToBePaid,
      'is_paid': isCleaned ? 1 : 0, // SQLite uses integers for booleans
    };
  }

  // Create Customer object from Map (database result)
  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id']?.toInt(),
      customerName: map['customer_name'] ?? '',
      service: map['service'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      dateTime: map['date_time'] ?? '',
      amountToBePaid: map['amount_to_be_paid']?.toDouble() ?? 0.0,
      isCleaned: (map['is_paid'] ?? 0) == 1, // Convert integer back to boolean
    );
  }

  // Create a copy of Customer with some fields updated
  Customer copyWith({
    int? id,
    String? customerName,
    String? service,
    String? address,
    String? phone,
    String? dateTime,
    double? amountToBePaid,
    bool? isCleaned,
  }) {
    return Customer(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      service: service ?? this.service,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      dateTime: dateTime ?? this.dateTime,
      amountToBePaid: amountToBePaid ?? this.amountToBePaid,
      isCleaned: isCleaned ?? this.isCleaned,
    );
  }

  // Convert to JSON string
  String toJson() {
    return '''
    {
      "id": $id,
      "customerName": "$customerName",
      "service": "$service",
      "address": "$address",
      "phone": "$phone",
      "dateTime": "$dateTime",
      "amountToBePaid": $amountToBePaid,
      "isCleaned": $isCleaned
    }
    ''';
  }

  @override
  String toString() {
    return 'Customer(id: $id, customerName: $customerName, service: $service, address: $address, phone: $phone, dateTime: $dateTime, amountToBePaid: $amountToBePaid, isCleaned: $isCleaned)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Customer &&
        other.id == id &&
        other.customerName == customerName &&
        other.service == service &&
        other.address == address &&
        other.phone == phone &&
        other.dateTime == dateTime &&
        other.amountToBePaid == amountToBePaid &&
        other.isCleaned == isCleaned;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    customerName.hashCode ^
    service.hashCode ^
    address.hashCode ^
    phone.hashCode ^
    dateTime.hashCode ^
    amountToBePaid.hashCode ^
    isCleaned.hashCode;
  }
}