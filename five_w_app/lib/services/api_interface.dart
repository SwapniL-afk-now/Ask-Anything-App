import '../models/five_w_model.dart';

abstract class ApiInterface {
  Future<AnalyzeResponse> analyzeTopic(String profession, String topic);
}
