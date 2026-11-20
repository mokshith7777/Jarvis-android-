import 'package:flutter_test/flutter_test.dart';
import 'package:jarvis_android/services/connector_hub_service.dart';
void main(){test('connector catalog has ten entries',(){expect(ConnectorHubService.services,hasLength(10));expect(ConnectorHubService.services,contains('Telegram'));expect(ConnectorHubService.services,contains('Gmail'));});}