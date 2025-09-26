enum AssetType {
  bond,
  deposit,
  insurance,
  mutualFund,
  stock,
  providentFund,
  other,
}

class Asset {
  final String id;
  final String userId;
  final String title;
  final AssetType type;
  final String description;
  final double value;
  final String institution;
  final String accountNumber;
  final DateTime createdAt;
  final DateTime? maturityDate;
  final Map<String, dynamic>? additionalDetails;

  Asset({
    required this.id,
    required this.userId,
    required this.title,
    required this.type,
    required this.description,
    required this.value,
    required this.institution,
    required this.accountNumber,
    required this.createdAt,
    this.maturityDate,
    this.additionalDetails,
  });

  String get typeDisplayName {
    switch (type) {
      case AssetType.bond:
        return 'Bond';
      case AssetType.deposit:
        return 'Fixed Deposit';
      case AssetType.insurance:
        return 'Insurance Policy';
      case AssetType.mutualFund:
        return 'Mutual Fund';
      case AssetType.stock:
        return 'Stock';
      case AssetType.providentFund:
        return 'Provident Fund';
      case AssetType.other:
        return 'Other';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'type': type.name,
      'description': description,
      'value': value,
      'institution': institution,
      'accountNumber': accountNumber,
      'createdAt': createdAt.toIso8601String(),
      'maturityDate': maturityDate?.toIso8601String(),
      'additionalDetails': additionalDetails,
    };
  }

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      type: AssetType.values.firstWhere((e) => e.name == json['type']),
      description: json['description'],
      value: json['value'].toDouble(),
      institution: json['institution'],
      accountNumber: json['accountNumber'],
      createdAt: DateTime.parse(json['createdAt']),
      maturityDate: json['maturityDate'] != null 
          ? DateTime.parse(json['maturityDate']) 
          : null,
      additionalDetails: json['additionalDetails'],
    );
  }
}