import 'package:async/async.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:eosdart/eosdart.dart';
import 'package:http/http.dart' as http;
import 'package:seeds/v2/datasource/local/settings_storage.dart';
import 'package:seeds/v2/datasource/remote/api/eos_repository.dart';
import 'package:seeds/v2/datasource/remote/api/network_repository.dart';
import 'package:seeds/v2/datasource/remote/model/account_recovery_model.dart';

export 'package:async/src/result/result.dart';

class GuardiansRepository extends EosRepository with NetworkRepository {
  /// Step 1 in the guardian set up - call this to allow the guard.seeds contract to
  /// change the key.
  ///
  /// Before the guardian contract can act on a recovery request, the users account needs to
  /// allow the guardian contract to change the keys.
  ///
  Future<Result> setGuardianPermission() async {
    print('[eos] setGuardianPermission');

    final Result currentPermissions = await _getAccountPermissions();
    // Error Fetching permissions.
    if (currentPermissions.isError) {
      print('[eos] currentPermissions.isError Error fetching permissions');
      return currentPermissions;
    }

    final Permission ownerPermission =
        (currentPermissions.asValue!.value as List<Permission>).firstWhere((item) => item.permName == 'owner');

    // Check if permissions are already set?
    // ignore: unnecessary_cast
    for (Map<String, dynamic> acct in ownerPermission.requiredAuth.accounts as List<dynamic>) {
      if (acct['permission']['actor'] == 'guard.seeds') {
        print('permission already set, doing nothing');
        return currentPermissions;
      }
    }

    ownerPermission.requiredAuth.accounts.add({
      'weight': ownerPermission.requiredAuth.threshold,
      'permission': {'actor': 'guard.seeds', 'permission': 'eosio.code'}
    });

    return await _updatePermission(ownerPermission);
  }

  /// Step 2 setting up guardians - set the guardians for an account
  ///
  /// guardians - list of Seeds account names that are the guardians - 3, 4, or 5 elements.
  ///
  /// Will fail when it's already set up - in that case, call cancelGuardians first.
  ///
  Future<Result> initGuardians(List<String> guardians) async {
    print('[eos] init guardians: ' + guardians.toString());

    var accountName = settingsStorage.accountName;

    var actions = [
      Action()
        ..account = "guard.seeds"
        ..name = "init"
        ..data = {
          'user_account': accountName,
          'guardian_accounts': guardians,
          'time_delay_sec': const Duration(days: 1).inSeconds,
        }
    ];

    actions.forEach((action) => {
          action.authorization = [
            Authorization()
              ..actor = accountName
              ..permission = 'active'
          ]
        });

    var transaction = buildFreeTransaction(actions, accountName);

    return buildEosClient()
        .pushTransaction(transaction, broadcast: true)
        .then((dynamic response) => mapEosResponse(response, (dynamic map) {
              return response["transaction_id"];
            }))
        .catchError((error) => mapEosError(error));
  }

  /// Cancel guardians.
  ///
  /// This cancels any recovery currently in process, and removes all guardians
  ///
  Future<Result> cancelGuardians() async {
    var accountName = settingsStorage.accountName;
    print('[eos] cancel recovery $accountName');

    var actions = [
      Action()
        ..account = 'guard.seeds'
        ..name = 'cancel'
        ..authorization = [
          Authorization()
            ..actor = accountName
            ..permission = 'owner'
        ]
        ..data = {'user_account': accountName}
    ];

    var transaction = buildFreeTransaction(actions, accountName);

    return buildEosClient()
        .pushTransaction(transaction, broadcast: true)
        .then((dynamic response) => mapEosResponse(response, (dynamic map) {
              return response["transaction_id"];
            }))
        .catchError((error) => mapEosError(error));
  }

  Future<Result<dynamic>> _getAccountPermissions() async {
    print('[http] get account permissions');
    var accountName = settingsStorage.accountName;

    final url = Uri.parse('$baseURL/v1/chain/get_account');
    final body = '{ "account_name": "$accountName" }';

    return http
        .post(url, headers: headers, body: body)
        .then((http.Response response) => mapHttpResponse(response, (dynamic body) {
              List<dynamic> allAccounts = body['permissions'].toList();
              return allAccounts.map((item) => Permission.fromJson(item)).toList();
            }))
        .catchError((error) => mapHttpError(error));
  }

  Future<dynamic> _updatePermission(Permission permission) async {
    print('[eos] update permission ${permission.permName}');

    var permissionsMap = _requiredAuthToJson(permission.requiredAuth!);

    print('converted JSPN: ${permissionsMap.toString()}');
    var accountName = settingsStorage.accountName;

    var actions = [
      Action()
        ..account = "eosio"
        ..name = "updateauth"
        ..data = {
          'account': accountName,
          'permission': permission.permName,
          'parent': permission.parent,
          'auth': permissionsMap
        }
    ];

    actions.forEach((action) => {
          action.authorization = [
            Authorization()
              ..actor = accountName
              ..permission = 'owner'
          ]
        });

    var transaction = buildFreeTransaction(actions, accountName);

    return buildEosClient()
        .pushTransaction(transaction, broadcast: true)
        .then((dynamic response) => mapEosResponse(response, (dynamic map) {
              return response["transaction_id"];
            }))
        .catchError((error) => mapEosError(error));
  }

  Future<Result<dynamic>> getAccountGuardians(String accountName) async {
    print('[http] get account guardians');
    var code = 'guard.seeds';
    var scope = 'guard.seeds';
    var table = 'guards';
    var value = accountName;
    String keyType = "i64";
    int indexPosition = 1;
    int limit = 1;
    bool reverse = false;

    final String requestURL = "$baseURL/v1/chain/get_table_rows";
    String request =
        '{"json": true, "code": "$code", "scope": "$scope", "table": "$table", "lower_bound": "$value", "upper_bound": "$value", "index_position": "$indexPosition", "key_type": "$keyType", "limit": $limit, "reverse": $reverse}';

    return http
        .post(Uri.parse(requestURL), headers: headers, body: request)
        .then((http.Response response) => mapHttpResponse(response, (dynamic body) {
              var rows = body["rows"] as List<dynamic>;
              return AccountRecoveryModel.fromTableRows(rows);
            }))
        .catchError((error) => mapHttpError(error));
  }
}

// method to properly convert RequiredAuth to JSON - the library doesn't work
Map<String, dynamic> _requiredAuthToJson(RequiredAuth instance) => <String, dynamic>{
      'threshold': instance.threshold,
      'keys': List<dynamic>.from(instance.keys!.map((e) => e.toJson())),
      'accounts': instance.accounts,
      'waits': instance.waits
    };
