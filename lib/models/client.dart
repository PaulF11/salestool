class Client {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String company;
  final String address;
  final String productInterest;
  final String productModel;
  final String budget;
  final String paymentType;
  final String status;
  final String leadSource;
  final String followUpDate;
  final String followUpTime;
  final String followUpReason;
  final String estimatedDealValue;
  final String lastContactDate;
  final String lastContactResult;
  final String notes;
  final List<Map<String, dynamic>> contactHistory;

  Client({
    required this.id,
    required this.name,
    required this.phone,
    this.email = '',
    this.company = '',
    this.address = '',
    this.productInterest = '',
    this.productModel = '',
    this.budget = '',
    this.paymentType = '',
    this.status = 'New',
    this.leadSource = '',
    this.followUpDate = '',
    this.followUpTime = '',
    this.followUpReason = '',
    this.estimatedDealValue = '',
    this.lastContactDate = '',
    this.lastContactResult = '',
    this.notes = '',
    this.contactHistory = const [],
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    final history = json['contactHistory'];

    return Client(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      company: json['company'] ?? '',
      address: json['address'] ?? '',
      productInterest: json['productInterest'] ?? '',
      productModel: json['productModel'] ?? '',
      budget: json['budget'] ?? '',
      paymentType: json['paymentType'] ?? '',
      status: json['status'] ?? 'New',
      leadSource: json['leadSource'] ?? '',
      followUpDate: json['followUpDate'] ?? '',
      followUpTime: json['followUpTime'] ?? '',
      followUpReason: json['followUpReason'] ?? '',
      estimatedDealValue: json['estimatedDealValue'] ?? '',
      lastContactDate: json['lastContactDate'] ?? '',
      lastContactResult: json['lastContactResult'] ?? '',
      notes: json['notes'] ?? '',
      contactHistory: history is List
          ? history.map((item) => Map<String, dynamic>.from(item)).toList()
          : [],
    );
  }
}
