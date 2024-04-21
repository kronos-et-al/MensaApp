import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:app/model/api_server/requests/querys.graphql.dart';
import 'package:app/model/api_server/requests/schema.graphql.dart';
import 'package:app/view_model/repository/data_classes/filter/Frequency.dart';
import 'package:app/view_model/repository/data_classes/meal/Additive.dart';
import 'package:app/view_model/repository/data_classes/meal/Allergen.dart';
import 'package:app/view_model/repository/data_classes/meal/FoodType.dart';
import 'package:app/view_model/repository/data_classes/meal/ImageData.dart';

import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/meal/Price.dart';
import 'package:app/view_model/repository/data_classes/meal/Side.dart';

import 'package:app/view_model/repository/data_classes/mealplan/Canteen.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Line.dart';

import 'package:app/view_model/repository/data_classes/mealplan/MealPlan.dart';

import 'package:app/view_model/repository/data_classes/settings/ReportCategory.dart';
import 'package:app/view_model/repository/error_handling/ImageUploadException.dart';
import 'package:app/view_model/repository/error_handling/MealPlanException.dart';
import 'package:app/view_model/repository/error_handling/NoMealException.dart';

import 'package:app/view_model/repository/error_handling/Result.dart';
import 'package:crypto/crypto.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import "package:http/http.dart" as http;

import '../../view_model/repository/interface/IServerAccess.dart';
import 'requests/mutations.graphql.dart';

class _MensaClient extends http.BaseClient {
  final http.Client _client;
  final String _apiKey;
  final String _clientId;

  static const int _apiKeyIdentifierPrefixLength = 10;
  static const String _authenticationScheme = "Mensa";

  _MensaClient(this._clientId, this._apiKey, [http.Client? client])
      : _client = client ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    List<int> bytes = [];
    if (request is http.Request) {
      bytes = request.bodyBytes;
    }

    if (request is http.MultipartRequest) {
      bytes = utf8.encode(request.fields["operations"] ?? "");
    }

    final hmac = Hmac(sha512, utf8.encode(_apiKey));
    final hash = hmac.convert(bytes);
    final apiIndent = _apiKey.substring(0, min(_apiKeyIdentifierPrefixLength, _apiKey.length));

    final authInfo = "$_clientId:$apiIndent:${base64Encode(hash.bytes)}";
    request.headers["Authorization"] =
    "$_authenticationScheme ${base64Encode(utf8.encode(authInfo))}";


    return _client.send(request);
  }
}

/// This class is responsible for communicating with the server through the graphql api.
class GraphQlServerAccess implements IServerAccess {
  final String _apiKey;
  late final GraphQLClient _client;
  final String _clientId;
  final _dateFormat = DateFormat(dateFormatPattern);

  GraphQlServerAccess._(this._clientId, String server, this._apiKey) {
    _client = GraphQLClient(
        defaultPolicies: DefaultPolicies(
          query: Policies(fetch: FetchPolicy.networkOnly),
          mutate: Policies(fetch: FetchPolicy.networkOnly),
        ),
        link: HttpLink(server, httpClient: _MensaClient(_clientId, _apiKey)),
        cache: GraphQLCache());
  }

  /// This constructor returns an instance of the server access class.
  /// To connect to the server, its address has to be provided as `address`.
  /// To authenticate commands to the server, an api key has also to be specified.
  /// The client identifier is necessary to request user specific information from the server.
  factory GraphQlServerAccess(String address, String apiKey, String clientId) {
    return GraphQlServerAccess._(clientId, address, apiKey);
  }

  // ---------------------- mutations ----------------------

  @override
  Future<bool> deleteDownvote(ImageData image) async {
    final result = await _client.mutate$RemoveDownvote(
        Options$Mutation$RemoveDownvote(
            variables: Variables$Mutation$RemoveDownvote(imageId: image.id)));

    return result.parsedData?.removeDownvote ?? false;
  }

  @override
  Future<bool> deleteUpvote(ImageData image) async {
    final result = await _client.mutate$RemoveUpvote(
        Options$Mutation$RemoveUpvote(
            variables: Variables$Mutation$RemoveUpvote(imageId: image.id)));

    return result.parsedData?.removeUpvote ?? false;
  }

  @override
  Future<bool> downvoteImage(ImageData image) async {
    final result = await _client.mutate$AddDownvote(
        Options$Mutation$AddDownvote(
            variables: Variables$Mutation$AddDownvote(imageId: image.id)));

    return result.parsedData?.addDownvote ?? false;
  }

  @override
  Future<bool> upvoteImage(ImageData image) async {
    final result = await _client.mutate$AddUpvote(Options$Mutation$AddUpvote(
        variables: Variables$Mutation$AddUpvote(imageId: image.id)));

    return result.parsedData?.addUpvote ?? false;
  }

  @override
  Future<Result<bool, ImageUploadException>> linkImage(Uint8List imageFile,
      MediaType mimeType, Meal meal) async {
    final image = http.MultipartFile.fromBytes(
        "", imageFile, filename: "image", contentType: mimeType);
    final hash = base64Encode(sha512
        .convert(imageFile)
        .bytes);
    assert(image.filename != null);

    final result = await _client.mutate$LinkImage(Options$Mutation$LinkImage(
        variables:
        Variables$Mutation$LinkImage(
            image: image, mealId: meal.id, hash: hash)));

    if (result.hasException) {
      if (result.exception!.linkException != null) {
        return Failure(ImageUploadException("Verbindungsfehler"));
      } else if (result.exception!.graphqlErrors.isNotEmpty) {
        return Failure(
            ImageUploadException(result.exception!.graphqlErrors[0].message));
      }
      return Failure(ImageUploadException("Unbekannter Fehler"));
    }

    return Success(result.parsedData?.addImage ?? false);
  }

  @override
  Future<bool> reportImage(ImageData image, ReportCategory reportReason) async {
    final convertedReason = _convertToReportReason(reportReason);

    final result = await _client.mutate$ReportImage(
        Options$Mutation$ReportImage(
            variables: Variables$Mutation$ReportImage(
                imageId: image.id, reason: convertedReason)));

    return result.parsedData?.reportImage ?? false;
  }

  @override
  Future<bool> updateMealRating(int rating, Meal meal) async {
    final result = await _client.mutate$UpdateRating(
        Options$Mutation$UpdateRating(
            variables: Variables$Mutation$UpdateRating(
                mealId: meal.id, rating: rating)));

    return result.parsedData?.setRating ?? false;
  }

  // ---------------------- queries ----------------------
  static const daysToParse = 7;
  static const dateFormatPattern = "yyyy-MM-dd";

  @override
  Future<Result<List<MealPlan>, MealPlanException>> updateAll() async {
    final today = DateTime.now();

    var completeList = <MealPlan>[];

    // TODO parallel?
    for (int offset = 0; offset < daysToParse; offset++) {
      final date = today.add(Duration(days: offset));
      final result = await _client.query$GetMealPlanForDay(
          Options$Query$GetMealPlanForDay(
              fetchPolicy: FetchPolicy.networkOnly,
              variables: Variables$Query$GetMealPlanForDay(
                  date: _dateFormat.format(date))));

      final exception = result.exception;
      if (exception != null) {
        return Failure(NoConnectionException(exception.toString()));
      }

      final mealPlan =
      _convertMealPlan(result.parsedData?.getCanteens ?? [], date);

      switch (mealPlan) {
        case Success(value: final mealPlan):
          {
            completeList.addAll(mealPlan);
          }
        case Failure(exception: _):
          {}
      }
    }
    return Success(completeList);
  }

  @override
  Future<Result<Meal, Exception>> getMeal(Meal meal, Line line,
      DateTime date) async {
    final result = await _client.query$GetMeal(Options$Query$GetMeal(
        fetchPolicy: FetchPolicy.networkOnly,
        variables: Variables$Query$GetMeal(
            date: _dateFormat.format(date), mealId: meal.id, lineId: line.id)));

    final mealData = result.parsedData?.getMeal;
    final exception = result.exception;
    if (exception != null) {
      return Failure(NoConnectionException(exception.toString()));
    }

    if (mealData == null) {
      return Failure(NoMealException("Could not request meal from api"));
    }

    return Success(_convertMeal(mealData));
  }

  @override
  Future<Result<List<MealPlan>, MealPlanException>> updateCanteen(
      Canteen canteen, DateTime date) async {
    final result = await _client.query$GetCanteenDate(
        Options$Query$GetCanteenDate(
            fetchPolicy: FetchPolicy.networkOnly,
            variables: Variables$Query$GetCanteenDate(
                canteenId: canteen.id, date: _dateFormat.format(date))));

    final exception = result.exception;
    if (exception != null) {
      return Failure(NoConnectionException(exception.toString()));
    }

    final mealPlan = _convertMealPlan(
        [result.parsedData?.getCanteen].nonNulls.toList(), date);
    return mealPlan;
  }

  @override
  Future<Canteen?> getDefaultCanteen() async {
    final result = await _client
        .query$GetDefaultCanteen(Options$Query$GetDefaultCanteen());

    final exception = result.exception;
    if (exception != null) {
      return null;
    }

    var canteen = result.parsedData?.getCanteens.first;

    if (canteen == null) {
      return null;
    }
    return _convertCanteen(canteen);
  }

  @override
  Future<List<Canteen>?> getCanteens() async {
    final result = await _client
        .query$GetDefaultCanteen(Options$Query$GetDefaultCanteen());

    final exception = result.exception;
    if (exception != null) {
      return null;
    }

    var canteen = result.parsedData?.getCanteens.first;

    if (canteen == null) {
      return null;
    }
    return result.parsedData?.getCanteens
        .map((e) => _convertCanteen(e))
        .toList();
  }

// --------------- utility helper methods ---------------

  Result<List<MealPlan>, MealPlanException> _convertMealPlan(
      List<Fragment$mealPlan> mealPlans, DateTime date) {
    if (mealPlans
        .expand((mealPlan) => mealPlan.lines)
        .any((line) => line.meals == null)) {
      return Failure(NoDataException("No data for a line."));
    }

    return Success(mealPlans
        .expand(
          (mealPlan) =>
          mealPlan.lines
              .asMap()
              .map((idx, line) =>
              MapEntry(
                idx,
                MealPlan(
                  date: date,
                  line: Line(
                      id: line.id,
                      name: line.name,
                      canteen: _convertCanteen(line.canteen),
                      position: idx),
                  // mensa closed when data available but no meals in list
                  isClosed: line.meals!.isEmpty,
                  meals: line.meals!.map((e) => _convertMeal(e)).toList(),
                ),
              ))
              .values
              .toList(),
    )
        .toList());
  }

  Meal _convertMeal(Fragment$mealInfo meal) {
    return Meal(
      id: meal.id,
      name: meal.name,
      foodType: _convertMealType(meal.mealType),
      price: _convertPrice(meal.price),
      additives: meal.additives
          .map((e) => _convertAdditive(e))
          .nonNulls
          .toList(),
      allergens: meal.allergens
          .map((e) => _convertAllergen(e))
          .nonNulls
          .toList(),
      averageRating: meal.ratings.averageRating,
      individualRating: meal.ratings.personalRating,
      numberOfRatings: meal.ratings.ratingsCount,
      lastServed: _convertDate(meal.statistics.lastServed),
      nextServed: _convertDate(meal.statistics.nextServed),
      numberOfOccurance: meal.statistics.frequency,
      relativeFrequency: _specifyFrequency(meal.statistics),
      images: meal.images.map((e) => _convertImage(e)).toList(),
      sides: meal.sides.map((e) => _convertSide(e)).toList(),
    );
  }
}

const int _rareMealLimit = 2;

Frequency _specifyFrequency(Fragment$mealInfo$statistics statistics) {
  if (statistics.$new) {
    return Frequency.newMeal;
  } else if (statistics.frequency <= _rareMealLimit) {
    return Frequency.rare;
  } else {
    return Frequency.normal;
  }
}

DateTime? _convertDate(String? date) {
  final format = DateFormat(GraphQlServerAccess.dateFormatPattern);
  try {
    return format.parse(date ?? "");
  } catch (e) {
    return null;
  }
}

Side _convertSide(Fragment$mealInfo$sides e) {
  return Side(
      id: e.id,
      name: e.name,
      foodType: _convertMealType(e.mealType),
      price: _convertPrice(e.price),
      allergens: e.allergens.map((e) => _convertAllergen(e)).nonNulls.toList(),
      additives: e.additives.map((e) => _convertAdditive(e)).nonNulls.toList());
}

ImageData _convertImage(Fragment$mealInfo$images e) {
  return ImageData(
      id: e.id,
      url: e.url,
      imageRank: e.rank,
      positiveRating: e.upvotes,
      negativeRating: e.downvotes,
      individualRating: e.personalUpvote
          ? 1
          : e.personalDownvote
              ? -1
              : 0);
}

Allergen? _convertAllergen(Enum$Allergen e) {
  return switch (e) {
    Enum$Allergen.CA => Allergen.ca,
    Enum$Allergen.DI => Allergen.di,
    Enum$Allergen.EI => Allergen.ei,
    Enum$Allergen.ER => Allergen.er,
    Enum$Allergen.FI => Allergen.fi,
    Enum$Allergen.GE => Allergen.ge,
    Enum$Allergen.HF => Allergen.hf,
    Enum$Allergen.HA => Allergen.ha,
    Enum$Allergen.KA => Allergen.ka,
    Enum$Allergen.KR => Allergen.kr,
    Enum$Allergen.LU => Allergen.lu,
    Enum$Allergen.MA => Allergen.ma,
    Enum$Allergen.ML => Allergen.ml,
    Enum$Allergen.PA => Allergen.pa,
    Enum$Allergen.PE => Allergen.pe,
    Enum$Allergen.PI => Allergen.pi,
    Enum$Allergen.QU => Allergen.qu,
    Enum$Allergen.RO => Allergen.ro,
    Enum$Allergen.SA => Allergen.sa,
    Enum$Allergen.SE => Allergen.se,
    Enum$Allergen.SF => Allergen.sf,
    Enum$Allergen.SN => Allergen.sn,
    Enum$Allergen.SO => Allergen.so,
    Enum$Allergen.WA => Allergen.wa,
    Enum$Allergen.WE => Allergen.we,
    Enum$Allergen.WT => Allergen.wt,
    Enum$Allergen.LA => Allergen.la,
    Enum$Allergen.GL => Allergen.gl,
    Enum$Allergen.$unknown => null,
  };
}

Additive? _convertAdditive(Enum$Additive e) {
  return switch (e) {
    Enum$Additive.COLORANT => Additive.colorant,
    Enum$Additive.PRESERVING_AGENTS => Additive.preservingAgents,
    Enum$Additive.ANTIOXIDANT_AGENTS => Additive.antioxidantAgents,
    Enum$Additive.FLAVOUR_ENHANCER => Additive.flavourEnhancer,
    Enum$Additive.PHOSPHATE => Additive.phosphate,
    Enum$Additive.SURFACE_WAXED => Additive.surfaceWaxed,
    Enum$Additive.SULPHUR => Additive.sulphur,
    Enum$Additive.ARTIFICIALLY_BLACKENED_OLIVES =>
      Additive.artificiallyBlackenedOlives,
    Enum$Additive.SWEETENER => Additive.sweetener,
    Enum$Additive.LAXATIVE_IF_OVERUSED => Additive.laxativeIfOverused,
    Enum$Additive.PHENYLALANINE => Additive.phenylalanine,
    Enum$Additive.ALCOHOL => Additive.alcohol,
    Enum$Additive.PRESSED_MEAT => Additive.pressedMeat,
    Enum$Additive.GLAZING_WITH_CACAO => Additive.glazingWithCacao,
    Enum$Additive.PRESSED_FISH => Additive.pressedFish,
    Enum$Additive.$unknown => null,
  };
}

FoodType _convertMealType(Enum$MealType mealType) {
  switch (mealType) {
    case Enum$MealType.BEEF:
      return FoodType.beef;
    case Enum$MealType.BEEF_AW:
      return FoodType.beefAw;
    case Enum$MealType.FISH:
      return FoodType.fish;
    case Enum$MealType.PORK:
      return FoodType.pork;
    case Enum$MealType.PORK_AW:
      return FoodType.porkAw;
    case Enum$MealType.VEGAN:
      return FoodType.vegan;
    case Enum$MealType.VEGETARIAN:
      return FoodType.vegetarian;
    case Enum$MealType.POULTRY:
      return FoodType.poultry;
    case Enum$MealType.UNKNOWN:
      return FoodType.unknown;
    case Enum$MealType.$unknown:
      return FoodType.unknown;
  }
}

Price _convertPrice(Fragment$price price) {
  return Price(
      student: price.student,
      employee: price.employee,
      pupil: price.pupil,
      guest: price.guest);
}

Canteen _convertCanteen(Fragment$canteen canteen) {
  return Canteen(id: canteen.id, name: canteen.name);
}

Enum$ReportReason _convertToReportReason(ReportCategory reportReason) {
  switch (reportReason) {
    case ReportCategory.offensive:
      return Enum$ReportReason.OFFENSIVE;
    case ReportCategory.advert:
      return Enum$ReportReason.ADVERT;
    case ReportCategory.noMeal:
      return Enum$ReportReason.NO_MEAL;
    case ReportCategory.violatesRights:
      return Enum$ReportReason.VIOLATES_RIGHTS;
    case ReportCategory.wrongMeal:
      return Enum$ReportReason.WRONG_MEAL;
    case ReportCategory.other:
      return Enum$ReportReason.OTHER;
  }
}
