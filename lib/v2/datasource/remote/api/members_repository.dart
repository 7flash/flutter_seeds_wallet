import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:seeds/v2/datasource/remote/api/network_repository.dart';
import 'package:seeds/v2/datasource/remote/model/member_model.dart';
import 'package:seeds/v2/domain-shared/app_constants.dart';

class MembersRepository extends NetworkRepository {
  Future<Result> getMembers() {
    print('[http] get members');

    final membersURL = Uri.parse('$baseURL/v1/chain/get_table_rows');

    var request = createRequest(code: account_accounts, scope: account_accounts, table: table_users, limit: 1000);

    return http
        .post(membersURL, headers: headers, body: request)
        .then((http.Response response) => mapHttpResponse(response, (dynamic body) {
              List<dynamic> allAccounts = body['rows'].toList();
              return allAccounts.map((item) => MemberModel.fromJson(item)).toList();
            }))
        .catchError((error) => mapHttpError(error));
  }

  /// Filter must be greater than 2 or we return empty list of users.
  Future<Result> getMembersWithFilter(String filter) {
    print('[http] getMembersWithFilter $filter ');
    assert(filter.length > 2);

    var lowerBound = filter;
    var upperBound = filter.padRight(12 - filter.length, 'z');

    final membersURL = Uri.parse('$baseURL/v1/chain/get_table_rows');

    var request = createRequest(
        code: account_accounts,
        scope: account_accounts,
        table: table_users,
        lowerBound: lowerBound,
        upperBound: upperBound,
        limit: 100);

    return http
        .post(membersURL, headers: headers, body: request)
        .then((http.Response response) => mapHttpResponse(response, (dynamic body) {
              List<dynamic> allAccounts = body['rows'].toList();
              return allAccounts.map((item) => MemberModel.fromJson(item)).toList();
            }))
        .catchError((error) => mapHttpError(error));
  }

  /// accountName must be greater than 2 or we return empty list of users.
  /// This will return one account if found or null if not found.
  Future<Result> getMemberByAccountName(String accountName) {
    print('[http] getMemberByAccountName $accountName ');
    assert(accountName.length > 2);

    final membersURL = Uri.parse('$baseURL/v1/chain/get_table_rows');

    var request = createRequest(
        code: account_accounts,
        scope: account_accounts,
        table: table_users,
        lowerBound: accountName,
        upperBound: accountName,
        limit: 1);

    return http
        .post(membersURL, headers: headers, body: request)
        .then((http.Response response) => mapHttpResponse(response, (dynamic body) {
              List<dynamic> allAccounts = body['rows'].toList();
              if (allAccounts.isNotEmpty) {
                return MemberModel.fromJson(allAccounts[0]);
              } else {
                return null;
              }
            }))
        .catchError((error) => mapHttpError(error));
  }
}
