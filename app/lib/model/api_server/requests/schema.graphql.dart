enum Enum$Additive {
  COLORANT,
  PRESERVING_AGENTS,
  ANTIOXIDANT_AGENTS,
  FLAVOUR_ENHANCER,
  PHOSPHATE,
  SURFACE_WAXED,
  SULPHUR,
  ARTIFICIALLY_BLACKENED_OLIVES,
  SWEETENER,
  LAXATIVE_IF_OVERUSED,
  PHENYLALANINE,
  ALCOHOL,
  PRESSED_MEAT,
  GLAZING_WITH_CACAO,
  PRESSED_FISH,
  $unknown;

  factory Enum$Additive.fromJson(String value) => fromJson$Enum$Additive(value);

  String toJson() => toJson$Enum$Additive(this);
}

String toJson$Enum$Additive(Enum$Additive e) {
  switch (e) {
    case Enum$Additive.COLORANT:
      return r'COLORANT';
    case Enum$Additive.PRESERVING_AGENTS:
      return r'PRESERVING_AGENTS';
    case Enum$Additive.ANTIOXIDANT_AGENTS:
      return r'ANTIOXIDANT_AGENTS';
    case Enum$Additive.FLAVOUR_ENHANCER:
      return r'FLAVOUR_ENHANCER';
    case Enum$Additive.PHOSPHATE:
      return r'PHOSPHATE';
    case Enum$Additive.SURFACE_WAXED:
      return r'SURFACE_WAXED';
    case Enum$Additive.SULPHUR:
      return r'SULPHUR';
    case Enum$Additive.ARTIFICIALLY_BLACKENED_OLIVES:
      return r'ARTIFICIALLY_BLACKENED_OLIVES';
    case Enum$Additive.SWEETENER:
      return r'SWEETENER';
    case Enum$Additive.LAXATIVE_IF_OVERUSED:
      return r'LAXATIVE_IF_OVERUSED';
    case Enum$Additive.PHENYLALANINE:
      return r'PHENYLALANINE';
    case Enum$Additive.ALCOHOL:
      return r'ALCOHOL';
    case Enum$Additive.PRESSED_MEAT:
      return r'PRESSED_MEAT';
    case Enum$Additive.GLAZING_WITH_CACAO:
      return r'GLAZING_WITH_CACAO';
    case Enum$Additive.PRESSED_FISH:
      return r'PRESSED_FISH';
    case Enum$Additive.$unknown:
      return r'$unknown';
  }
}

Enum$Additive fromJson$Enum$Additive(String value) {
  switch (value) {
    case r'COLORANT':
      return Enum$Additive.COLORANT;
    case r'PRESERVING_AGENTS':
      return Enum$Additive.PRESERVING_AGENTS;
    case r'ANTIOXIDANT_AGENTS':
      return Enum$Additive.ANTIOXIDANT_AGENTS;
    case r'FLAVOUR_ENHANCER':
      return Enum$Additive.FLAVOUR_ENHANCER;
    case r'PHOSPHATE':
      return Enum$Additive.PHOSPHATE;
    case r'SURFACE_WAXED':
      return Enum$Additive.SURFACE_WAXED;
    case r'SULPHUR':
      return Enum$Additive.SULPHUR;
    case r'ARTIFICIALLY_BLACKENED_OLIVES':
      return Enum$Additive.ARTIFICIALLY_BLACKENED_OLIVES;
    case r'SWEETENER':
      return Enum$Additive.SWEETENER;
    case r'LAXATIVE_IF_OVERUSED':
      return Enum$Additive.LAXATIVE_IF_OVERUSED;
    case r'PHENYLALANINE':
      return Enum$Additive.PHENYLALANINE;
    case r'ALCOHOL':
      return Enum$Additive.ALCOHOL;
    case r'PRESSED_MEAT':
      return Enum$Additive.PRESSED_MEAT;
    case r'GLAZING_WITH_CACAO':
      return Enum$Additive.GLAZING_WITH_CACAO;
    case r'PRESSED_FISH':
      return Enum$Additive.PRESSED_FISH;
    default:
      return Enum$Additive.$unknown;
  }
}

enum Enum$Allergen {
  CA,
  DI,
  EI,
  ER,
  FI,
  GE,
  HF,
  HA,
  KA,
  KR,
  LU,
  MA,
  ML,
  PA,
  PE,
  PI,
  QU,
  RO,
  SA,
  SE,
  SF,
  SN,
  SO,
  WA,
  WE,
  WT,
  LA,
  GL,
  $unknown;

  factory Enum$Allergen.fromJson(String value) => fromJson$Enum$Allergen(value);

  String toJson() => toJson$Enum$Allergen(this);
}

String toJson$Enum$Allergen(Enum$Allergen e) {
  switch (e) {
    case Enum$Allergen.CA:
      return r'CA';
    case Enum$Allergen.DI:
      return r'DI';
    case Enum$Allergen.EI:
      return r'EI';
    case Enum$Allergen.ER:
      return r'ER';
    case Enum$Allergen.FI:
      return r'FI';
    case Enum$Allergen.GE:
      return r'GE';
    case Enum$Allergen.HF:
      return r'HF';
    case Enum$Allergen.HA:
      return r'HA';
    case Enum$Allergen.KA:
      return r'KA';
    case Enum$Allergen.KR:
      return r'KR';
    case Enum$Allergen.LU:
      return r'LU';
    case Enum$Allergen.MA:
      return r'MA';
    case Enum$Allergen.ML:
      return r'ML';
    case Enum$Allergen.PA:
      return r'PA';
    case Enum$Allergen.PE:
      return r'PE';
    case Enum$Allergen.PI:
      return r'PI';
    case Enum$Allergen.QU:
      return r'QU';
    case Enum$Allergen.RO:
      return r'RO';
    case Enum$Allergen.SA:
      return r'SA';
    case Enum$Allergen.SE:
      return r'SE';
    case Enum$Allergen.SF:
      return r'SF';
    case Enum$Allergen.SN:
      return r'SN';
    case Enum$Allergen.SO:
      return r'SO';
    case Enum$Allergen.WA:
      return r'WA';
    case Enum$Allergen.WE:
      return r'WE';
    case Enum$Allergen.WT:
      return r'WT';
    case Enum$Allergen.LA:
      return r'LA';
    case Enum$Allergen.GL:
      return r'GL';
    case Enum$Allergen.$unknown:
      return r'$unknown';
  }
}

Enum$Allergen fromJson$Enum$Allergen(String value) {
  switch (value) {
    case r'CA':
      return Enum$Allergen.CA;
    case r'DI':
      return Enum$Allergen.DI;
    case r'EI':
      return Enum$Allergen.EI;
    case r'ER':
      return Enum$Allergen.ER;
    case r'FI':
      return Enum$Allergen.FI;
    case r'GE':
      return Enum$Allergen.GE;
    case r'HF':
      return Enum$Allergen.HF;
    case r'HA':
      return Enum$Allergen.HA;
    case r'KA':
      return Enum$Allergen.KA;
    case r'KR':
      return Enum$Allergen.KR;
    case r'LU':
      return Enum$Allergen.LU;
    case r'MA':
      return Enum$Allergen.MA;
    case r'ML':
      return Enum$Allergen.ML;
    case r'PA':
      return Enum$Allergen.PA;
    case r'PE':
      return Enum$Allergen.PE;
    case r'PI':
      return Enum$Allergen.PI;
    case r'QU':
      return Enum$Allergen.QU;
    case r'RO':
      return Enum$Allergen.RO;
    case r'SA':
      return Enum$Allergen.SA;
    case r'SE':
      return Enum$Allergen.SE;
    case r'SF':
      return Enum$Allergen.SF;
    case r'SN':
      return Enum$Allergen.SN;
    case r'SO':
      return Enum$Allergen.SO;
    case r'WA':
      return Enum$Allergen.WA;
    case r'WE':
      return Enum$Allergen.WE;
    case r'WT':
      return Enum$Allergen.WT;
    case r'LA':
      return Enum$Allergen.LA;
    case r'GL':
      return Enum$Allergen.GL;
    default:
      return Enum$Allergen.$unknown;
  }
}

enum Enum$FoodType {
  VEGAN,
  VEGETARIAN,
  BEEF,
  BEEF_AW,
  PORK,
  PORK_AW,
  POULTRY,
  FISH,
  UNKNOWN,
  $unknown;

  factory Enum$FoodType.fromJson(String value) => fromJson$Enum$FoodType(value);

  String toJson() => toJson$Enum$FoodType(this);
}

String toJson$Enum$FoodType(Enum$FoodType e) {
  switch (e) {
    case Enum$FoodType.VEGAN:
      return r'VEGAN';
    case Enum$FoodType.VEGETARIAN:
      return r'VEGETARIAN';
    case Enum$FoodType.BEEF:
      return r'BEEF';
    case Enum$FoodType.BEEF_AW:
      return r'BEEF_AW';
    case Enum$FoodType.PORK:
      return r'PORK';
    case Enum$FoodType.PORK_AW:
      return r'PORK_AW';
    case Enum$FoodType.POULTRY:
      return r'POULTRY';
    case Enum$FoodType.FISH:
      return r'FISH';
    case Enum$FoodType.UNKNOWN:
      return r'UNKNOWN';
    case Enum$FoodType.$unknown:
      return r'$unknown';
  }
}

Enum$FoodType fromJson$Enum$FoodType(String value) {
  switch (value) {
    case r'VEGAN':
      return Enum$FoodType.VEGAN;
    case r'VEGETARIAN':
      return Enum$FoodType.VEGETARIAN;
    case r'BEEF':
      return Enum$FoodType.BEEF;
    case r'BEEF_AW':
      return Enum$FoodType.BEEF_AW;
    case r'PORK':
      return Enum$FoodType.PORK;
    case r'PORK_AW':
      return Enum$FoodType.PORK_AW;
    case r'POULTRY':
      return Enum$FoodType.POULTRY;
    case r'FISH':
      return Enum$FoodType.FISH;
    case r'UNKNOWN':
      return Enum$FoodType.UNKNOWN;
    default:
      return Enum$FoodType.$unknown;
  }
}

enum Enum$ReportReason {
  OFFENSIVE,
  ADVERT,
  NO_MEAL,
  WRONG_MEAL,
  VIOLATES_RIGHTS,
  OTHER,
  $unknown;

  factory Enum$ReportReason.fromJson(String value) =>
      fromJson$Enum$ReportReason(value);

  String toJson() => toJson$Enum$ReportReason(this);
}

String toJson$Enum$ReportReason(Enum$ReportReason e) {
  switch (e) {
    case Enum$ReportReason.OFFENSIVE:
      return r'OFFENSIVE';
    case Enum$ReportReason.ADVERT:
      return r'ADVERT';
    case Enum$ReportReason.NO_MEAL:
      return r'NO_MEAL';
    case Enum$ReportReason.WRONG_MEAL:
      return r'WRONG_MEAL';
    case Enum$ReportReason.VIOLATES_RIGHTS:
      return r'VIOLATES_RIGHTS';
    case Enum$ReportReason.OTHER:
      return r'OTHER';
    case Enum$ReportReason.$unknown:
      return r'$unknown';
  }
}

Enum$ReportReason fromJson$Enum$ReportReason(String value) {
  switch (value) {
    case r'OFFENSIVE':
      return Enum$ReportReason.OFFENSIVE;
    case r'ADVERT':
      return Enum$ReportReason.ADVERT;
    case r'NO_MEAL':
      return Enum$ReportReason.NO_MEAL;
    case r'WRONG_MEAL':
      return Enum$ReportReason.WRONG_MEAL;
    case r'VIOLATES_RIGHTS':
      return Enum$ReportReason.VIOLATES_RIGHTS;
    case r'OTHER':
      return Enum$ReportReason.OTHER;
    default:
      return Enum$ReportReason.$unknown;
  }
}

enum Enum$__TypeKind {
  SCALAR,
  OBJECT,
  INTERFACE,
  UNION,
  ENUM,
  INPUT_OBJECT,
  LIST,
  NON_NULL,
  $unknown;

  factory Enum$__TypeKind.fromJson(String value) =>
      fromJson$Enum$__TypeKind(value);

  String toJson() => toJson$Enum$__TypeKind(this);
}

String toJson$Enum$__TypeKind(Enum$__TypeKind e) {
  switch (e) {
    case Enum$__TypeKind.SCALAR:
      return r'SCALAR';
    case Enum$__TypeKind.OBJECT:
      return r'OBJECT';
    case Enum$__TypeKind.INTERFACE:
      return r'INTERFACE';
    case Enum$__TypeKind.UNION:
      return r'UNION';
    case Enum$__TypeKind.ENUM:
      return r'ENUM';
    case Enum$__TypeKind.INPUT_OBJECT:
      return r'INPUT_OBJECT';
    case Enum$__TypeKind.LIST:
      return r'LIST';
    case Enum$__TypeKind.NON_NULL:
      return r'NON_NULL';
    case Enum$__TypeKind.$unknown:
      return r'$unknown';
  }
}

Enum$__TypeKind fromJson$Enum$__TypeKind(String value) {
  switch (value) {
    case r'SCALAR':
      return Enum$__TypeKind.SCALAR;
    case r'OBJECT':
      return Enum$__TypeKind.OBJECT;
    case r'INTERFACE':
      return Enum$__TypeKind.INTERFACE;
    case r'UNION':
      return Enum$__TypeKind.UNION;
    case r'ENUM':
      return Enum$__TypeKind.ENUM;
    case r'INPUT_OBJECT':
      return Enum$__TypeKind.INPUT_OBJECT;
    case r'LIST':
      return Enum$__TypeKind.LIST;
    case r'NON_NULL':
      return Enum$__TypeKind.NON_NULL;
    default:
      return Enum$__TypeKind.$unknown;
  }
}

enum Enum$__DirectiveLocation {
  QUERY,
  MUTATION,
  SUBSCRIPTION,
  FIELD,
  FRAGMENT_DEFINITION,
  FRAGMENT_SPREAD,
  INLINE_FRAGMENT,
  VARIABLE_DEFINITION,
  SCHEMA,
  SCALAR,
  OBJECT,
  FIELD_DEFINITION,
  ARGUMENT_DEFINITION,
  INTERFACE,
  UNION,
  ENUM,
  ENUM_VALUE,
  INPUT_OBJECT,
  INPUT_FIELD_DEFINITION,
  $unknown;

  factory Enum$__DirectiveLocation.fromJson(String value) =>
      fromJson$Enum$__DirectiveLocation(value);

  String toJson() => toJson$Enum$__DirectiveLocation(this);
}

String toJson$Enum$__DirectiveLocation(Enum$__DirectiveLocation e) {
  switch (e) {
    case Enum$__DirectiveLocation.QUERY:
      return r'QUERY';
    case Enum$__DirectiveLocation.MUTATION:
      return r'MUTATION';
    case Enum$__DirectiveLocation.SUBSCRIPTION:
      return r'SUBSCRIPTION';
    case Enum$__DirectiveLocation.FIELD:
      return r'FIELD';
    case Enum$__DirectiveLocation.FRAGMENT_DEFINITION:
      return r'FRAGMENT_DEFINITION';
    case Enum$__DirectiveLocation.FRAGMENT_SPREAD:
      return r'FRAGMENT_SPREAD';
    case Enum$__DirectiveLocation.INLINE_FRAGMENT:
      return r'INLINE_FRAGMENT';
    case Enum$__DirectiveLocation.VARIABLE_DEFINITION:
      return r'VARIABLE_DEFINITION';
    case Enum$__DirectiveLocation.SCHEMA:
      return r'SCHEMA';
    case Enum$__DirectiveLocation.SCALAR:
      return r'SCALAR';
    case Enum$__DirectiveLocation.OBJECT:
      return r'OBJECT';
    case Enum$__DirectiveLocation.FIELD_DEFINITION:
      return r'FIELD_DEFINITION';
    case Enum$__DirectiveLocation.ARGUMENT_DEFINITION:
      return r'ARGUMENT_DEFINITION';
    case Enum$__DirectiveLocation.INTERFACE:
      return r'INTERFACE';
    case Enum$__DirectiveLocation.UNION:
      return r'UNION';
    case Enum$__DirectiveLocation.ENUM:
      return r'ENUM';
    case Enum$__DirectiveLocation.ENUM_VALUE:
      return r'ENUM_VALUE';
    case Enum$__DirectiveLocation.INPUT_OBJECT:
      return r'INPUT_OBJECT';
    case Enum$__DirectiveLocation.INPUT_FIELD_DEFINITION:
      return r'INPUT_FIELD_DEFINITION';
    case Enum$__DirectiveLocation.$unknown:
      return r'$unknown';
  }
}

Enum$__DirectiveLocation fromJson$Enum$__DirectiveLocation(String value) {
  switch (value) {
    case r'QUERY':
      return Enum$__DirectiveLocation.QUERY;
    case r'MUTATION':
      return Enum$__DirectiveLocation.MUTATION;
    case r'SUBSCRIPTION':
      return Enum$__DirectiveLocation.SUBSCRIPTION;
    case r'FIELD':
      return Enum$__DirectiveLocation.FIELD;
    case r'FRAGMENT_DEFINITION':
      return Enum$__DirectiveLocation.FRAGMENT_DEFINITION;
    case r'FRAGMENT_SPREAD':
      return Enum$__DirectiveLocation.FRAGMENT_SPREAD;
    case r'INLINE_FRAGMENT':
      return Enum$__DirectiveLocation.INLINE_FRAGMENT;
    case r'VARIABLE_DEFINITION':
      return Enum$__DirectiveLocation.VARIABLE_DEFINITION;
    case r'SCHEMA':
      return Enum$__DirectiveLocation.SCHEMA;
    case r'SCALAR':
      return Enum$__DirectiveLocation.SCALAR;
    case r'OBJECT':
      return Enum$__DirectiveLocation.OBJECT;
    case r'FIELD_DEFINITION':
      return Enum$__DirectiveLocation.FIELD_DEFINITION;
    case r'ARGUMENT_DEFINITION':
      return Enum$__DirectiveLocation.ARGUMENT_DEFINITION;
    case r'INTERFACE':
      return Enum$__DirectiveLocation.INTERFACE;
    case r'UNION':
      return Enum$__DirectiveLocation.UNION;
    case r'ENUM':
      return Enum$__DirectiveLocation.ENUM;
    case r'ENUM_VALUE':
      return Enum$__DirectiveLocation.ENUM_VALUE;
    case r'INPUT_OBJECT':
      return Enum$__DirectiveLocation.INPUT_OBJECT;
    case r'INPUT_FIELD_DEFINITION':
      return Enum$__DirectiveLocation.INPUT_FIELD_DEFINITION;
    default:
      return Enum$__DirectiveLocation.$unknown;
  }
}

const possibleTypesMap = <String, Set<String>>{};
