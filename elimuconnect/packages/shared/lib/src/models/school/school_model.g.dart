// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SchoolModel _$SchoolModelFromJson(Map<String, dynamic> json) => SchoolModel(
      id: json['id'] as String,
      name: json['name'] as String,
      nemisCode: json['nemisCode'] as String,
      schoolType: $enumDecode(_$SchoolTypeEnumMap, json['schoolType']),
      county: $enumDecode(_$CountyEnumMap, json['county']),
      subcounty: json['subcounty'] as String,
      ward: json['ward'] as String,
      address: json['address'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      lowestGrade: $enumDecode(_$GradeLevelEnumMap, json['lowestGrade']),
      highestGrade: $enumDecode(_$GradeLevelEnumMap, json['highestGrade']),
      totalStudents: (json['totalStudents'] as num?)?.toInt() ?? 0,
      totalTeachers: (json['totalTeachers'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      establishedDate: DateTime.parse(json['establishedDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$SchoolModelToJson(SchoolModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'nemisCode': instance.nemisCode,
      'schoolType': _$SchoolTypeEnumMap[instance.schoolType]!,
      'county': _$CountyEnumMap[instance.county]!,
      'subcounty': instance.subcounty,
      'ward': instance.ward,
      'address': instance.address,
      'phoneNumber': instance.phoneNumber,
      'email': instance.email,
      'website': instance.website,
      'lowestGrade': _$GradeLevelEnumMap[instance.lowestGrade]!,
      'highestGrade': _$GradeLevelEnumMap[instance.highestGrade]!,
      'totalStudents': instance.totalStudents,
      'totalTeachers': instance.totalTeachers,
      'isActive': instance.isActive,
      'establishedDate': instance.establishedDate.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$SchoolTypeEnumMap = {
  SchoolType.public: 'public',
  SchoolType.private: 'private',
  SchoolType.international: 'international',
  SchoolType.specialNeeds: 'special_needs',
};

const _$CountyEnumMap = {
  County.baringo: 'baringo',
  County.bomet: 'bomet',
  County.bungoma: 'bungoma',
  County.busia: 'busia',
  County.elgeyoMarakwet: 'elgeyo_marakwet',
  County.embu: 'embu',
  County.garissa: 'garissa',
  County.homaBay: 'homa_bay',
  County.isiolo: 'isiolo',
  County.kajiado: 'kajiado',
  County.kakamega: 'kakamega',
  County.kericho: 'kericho',
  County.kiambu: 'kiambu',
  County.kilifi: 'kilifi',
  County.kirinyaga: 'kirinyaga',
  County.kisii: 'kisii',
  County.kisumu: 'kisumu',
  County.kitui: 'kitui',
  County.kwale: 'kwale',
  County.laikipia: 'laikipia',
  County.lamu: 'lamu',
  County.machakos: 'machakos',
  County.makueni: 'makueni',
  County.mandera: 'mandera',
  County.marsabit: 'marsabit',
  County.meru: 'meru',
  County.migori: 'migori',
  County.mombasa: 'mombasa',
  County.murangA: 'murang_a',
  County.nairobi: 'nairobi',
  County.nakuru: 'nakuru',
  County.nandi: 'nandi',
  County.narok: 'narok',
  County.nyamira: 'nyamira',
  County.nyandarua: 'nyandarua',
  County.nyeri: 'nyeri',
  County.samburu: 'samburu',
  County.siaya: 'siaya',
  County.taitaTaveta: 'taita_taveta',
  County.tanaRiver: 'tana_river',
  County.tharakaNithi: 'tharaka_nithi',
  County.transNzoia: 'trans_nzoia',
  County.turkana: 'turkana',
  County.uasinGishu: 'uasin_gishu',
  County.vihiga: 'vihiga',
  County.wajir: 'wajir',
  County.westPokot: 'west_pokot',
};

const _$GradeLevelEnumMap = {
  GradeLevel.pp1: 'pp1',
  GradeLevel.pp2: 'pp2',
  GradeLevel.grade1: 'grade_1',
  GradeLevel.grade2: 'grade_2',
  GradeLevel.grade3: 'grade_3',
  GradeLevel.grade4: 'grade_4',
  GradeLevel.grade5: 'grade_5',
  GradeLevel.grade6: 'grade_6',
  GradeLevel.grade7: 'grade_7',
  GradeLevel.grade8: 'grade_8',
  GradeLevel.grade9: 'grade_9',
  GradeLevel.form1: 'form_1',
  GradeLevel.form2: 'form_2',
  GradeLevel.form3: 'form_3',
  GradeLevel.form4: 'form_4',
};

SchoolRegistrationRequest _$SchoolRegistrationRequestFromJson(
        Map<String, dynamic> json) =>
    SchoolRegistrationRequest(
      name: json['name'] as String,
      nemisCode: json['nemisCode'] as String,
      schoolType: $enumDecode(_$SchoolTypeEnumMap, json['schoolType']),
      county: $enumDecode(_$CountyEnumMap, json['county']),
      subcounty: json['subcounty'] as String,
      ward: json['ward'] as String,
      address: json['address'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      lowestGrade: $enumDecode(_$GradeLevelEnumMap, json['lowestGrade']),
      highestGrade: $enumDecode(_$GradeLevelEnumMap, json['highestGrade']),
      establishedDate: DateTime.parse(json['establishedDate'] as String),
    );

Map<String, dynamic> _$SchoolRegistrationRequestToJson(
        SchoolRegistrationRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'nemisCode': instance.nemisCode,
      'schoolType': _$SchoolTypeEnumMap[instance.schoolType]!,
      'county': _$CountyEnumMap[instance.county]!,
      'subcounty': instance.subcounty,
      'ward': instance.ward,
      'address': instance.address,
      'phoneNumber': instance.phoneNumber,
      'email': instance.email,
      'website': instance.website,
      'lowestGrade': _$GradeLevelEnumMap[instance.lowestGrade]!,
      'highestGrade': _$GradeLevelEnumMap[instance.highestGrade]!,
      'establishedDate': instance.establishedDate.toIso8601String(),
    };
