import 'package:async/async.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:eosdart/eosdart.dart';
import 'package:http/http.dart' as http;
import 'package:seeds/v2/datasource/remote/api/eos_repository.dart';
import 'package:seeds/v2/datasource/remote/api/network_repository.dart';
import 'package:seeds/v2/datasource/remote/firebase/firebase_remote_config.dart';
import 'package:seeds/v2/datasource/remote/model/profile_model.dart';
import 'package:seeds/v2/datasource/remote/model/score_model.dart';
import 'package:seeds/v2/datasource/remote/model/transaction_response.dart';
import 'package:seeds/v2/datasource/remote/model/referred_accounts_model.dart';
import 'package:seeds/v2/domain-shared/app_constants.dart';
import 'package:seeds/v2/domain-shared/ui_constants.dart';

class ProfileRepository extends NetworkRepository with EosRepository {
  Future<Result> getProfile(String accountName) {
    print('[http] get seeds getProfile $accountName');

    var request = createRequest(
      code: account_accounts,
      scope: account_accounts,
      table: table_users,
      lowerBound: accountName,
      upperBound: accountName,
      limit: 1,
    );

    return http
        .post(Uri.parse('${remoteConfigurations.activeEOSServerUrl.url}/v1/chain/get_table_rows'),
            headers: headers, body: request)
        .then((http.Response response) => mapHttpResponse(response, (dynamic body) {
              return ProfileModel.fromJson(body['rows'][0]);
            }))
        .catchError((error) => mapHttpError(error));
  }

  Future<Result> updateProfile({
    required String nickname,
    required String image,
    required String story,
    required String roles,
    required String skills,
    required String interests,
    required String accountName,
  }) async {
    print('[eos] update profile');

    var transaction = buildFreeTransaction([
      Action()
        ..account = account_accounts
        ..name = action_name_update
        ..authorization = [
          Authorization()
            ..actor = accountName
            ..permission = permission_active
        ]
        ..data = {
          'user': accountName,
          'type': 'individual',
          'nickname': nickname,
          'image': image,
          'story': story,
          'roles': roles,
          'skills': skills,
          'interests': interests
        }
    ], accountName);

    return buildEosClient()
        .pushTransaction(transaction, broadcast: true)
        .then((dynamic response) => mapEosResponse(response, (dynamic map) {
              return TransactionResponse.fromJson(map);
            }))
        .catchError((error) => mapEosError(error));
  }

  Future<Result> getScore({
    required String account,
    String contractName = account_harvest,
    String? scope,
    required String tableName,
    String fieldName = "rank",
  }) async {
    print('[http] get score $account $tableName');

    final scoreURL = Uri.parse('${remoteConfigurations.activeEOSServerUrl.url}/v1/chain/get_table_rows');

    var request = createRequest(
      code: contractName,
      scope: scope ?? contractName,
      table: tableName,
      lowerBound: '$account',
      upperBound: '$account',
      limit: 1,
    );

    return http
        .post(scoreURL, headers: headers, body: request)
        .then((http.Response response) => mapHttpResponse(response, (dynamic body) {
              return ScoreModel.fromJson(json: body, fieldName: fieldName);
            }))
        .catchError((error) => mapHttpError(error));
  }

  Future<Result> getReferredAccounts(String accountName) {
    print('[http] get Referred Accounts $accountName');

    var request = createRequest(
      code: account_accounts,
      scope: account_accounts,
      table: table_refs,
      lowerBound: '$accountName',
      upperBound: '$accountName',
      indexPosition: 2,
      limit: 100,
    );

    return http
        .post(Uri.parse('${remoteConfigurations.activeEOSServerUrl.url}/v1/chain/get_table_rows'),
            headers: headers, body: request)
        .then((http.Response response) => mapHttpResponse(response, (dynamic body) {
              return ReferredAccounts.fromJson(body);
            }))
        .catchError((error) => mapHttpError(error));
  }

  Future<Result> plantSeeds({required double amount, required String accountName}) async {
    print('[eos] plant seeds ($amount)');

    var transaction = buildFreeTransaction([
      Action()
        ..account = account_token
        ..name = action_name_transfer
        ..authorization = [
          Authorization()
            ..actor = accountName
            ..permission = permission_active
        ]
        ..data = {
          'from': accountName,
          'to': account_harvest,
          'quantity': '${amount.toStringAsFixed(4)} $currencySeedsCode',
          'memo': '',
        }
    ], accountName);

    return buildEosClient()
        .pushTransaction(transaction, broadcast: true)
        .then((dynamic response) => mapEosResponse(response, (dynamic map) {
              return TransactionResponse.fromJson(map);
            }))
        .catchError((error) => mapEosError(error));
  }

  Future<Result> makeCitizen(String accountName) async {
    return citizenshipAction(accountName: accountName, isMake: true, isCitizen: true);
  }

  Future<Result> makeResident(String accountName) async {
    return citizenshipAction(accountName: accountName, isMake: true, isCitizen: false);
  }

  Future<Result> canCitizen(String accountName) async {
    return citizenshipAction(accountName: accountName, isMake: false, isCitizen: true);
  }

  Future<Result> canResident(String accountName) async {
    return citizenshipAction(accountName: accountName, isMake: false, isCitizen: false);
  }

  Future<Result> citizenshipAction({required String accountName, required bool isMake, required bool isCitizen}) async {
    print('[eos] ' + (isMake ? "make" : "can") + " " + (isCitizen ? "citizen" : "resident"));

    var actionName = isMake
        ? isCitizen
            ? action_name_makecitizen
            : action_name_makeresident
        : isCitizen
            ? action_name_cancitizen
            : action_name_canresident;

    var transaction = buildFreeTransaction([
      Action()
        ..account = account_accounts
        ..name = actionName
        ..authorization = [
          Authorization()
            ..actor = accountName
            ..permission = permission_active
        ]
        ..data = {
          'user': accountName,
        }
    ], accountName);

    return buildEosClient()
        .pushTransaction(transaction, broadcast: true)
        .then((dynamic response) => mapEosResponse(response, (dynamic map) {
              return TransactionResponse.fromJson(map);
            }))
        .catchError((error) => mapEosError(error));
  }

  Future<Result> isDHOMember(String accountName) {
    print('[http] is $accountName DHO member');

    var request = '{"json": true, "code": "trailservice","scope": "$accountName","table": "voters"}';

    return http
        .post(Uri.parse('${remoteConfigurations.activeEOSServerUrl.url}/v1/chain/get_table_rows'),
            headers: headers, body: request)
        .then((http.Response response) => mapHttpResponse(response, (dynamic body) {
              return (body['rows'] as List).isNotEmpty;
            }))
        .catchError((error) => mapHttpError(error));
  }
}
