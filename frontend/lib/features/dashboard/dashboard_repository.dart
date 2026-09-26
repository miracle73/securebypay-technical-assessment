import '../../core/api_client.dart';
import '../../core/models.dart';

enum GrowthPeriod { year, month, week }

class DashboardRepository {
  const DashboardRepository(this._api);

  final ApiClient _api;

  Future<Overview> overview() async => Overview.fromJson(await _api.get('/dashboard/overview') as Map<String, dynamic>);

  Future<List<Shipment>> recentShipments({int limit = 10}) async {
    final list = await _api.get('/dashboard/shipments?limit=$limit') as List;
    return list.map((e) => Shipment.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<double>> growth(GrowthPeriod period) async {
    final res = await _api.get('/dashboard/growth?period=${period.name}') as Map<String, dynamic>;
    return (res['points'] as List).map((e) => (e as num).toDouble()).toList();
  }
}
