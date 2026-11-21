import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jarvis_android/services/appointment_service.dart';
import 'package:jarvis_android/services/settings_service.dart';
import 'test_support/secure_storage_mock.dart';

void main(){
 TestWidgetsFlutterBinding.ensureInitialized();
 group('Appointment manager',(){
  test('CRUD persists and status changes',()async{
   SharedPreferences.setMockInitialValues({});
   final prefs=await SharedPreferences.getInstance();
   final service=AppointmentService.forTesting(preferences:prefs);
   await service.init();
   final created=await service.add(title:'Follow up',callerName:'Alex',phoneNumber:'123',scheduledAt:DateTime(2030,1,1),notes:'Call back');
   expect(service.appointments,hasLength(1));
   await service.setStatus(created.id,AppointmentStatus.confirmed);
   expect(service.appointments.first.status,AppointmentStatus.confirmed);
   await service.update(service.appointments.first.copyWith(title:'Updated'));
   expect(service.appointments.first.title,'Updated');
   final reload=AppointmentService.forTesting(preferences:prefs);
   await reload.init();
   expect(reload.appointments.first.status,AppointmentStatus.confirmed);
   expect(reload.appointments.first.title,'Updated');
   expect(await reload.delete(created.id),true);
   expect(reload.appointments,isEmpty);
  });
  test('Telegram payload includes appointment details and gracefully handles missing configuration',()async{
   SharedPreferences.setMockInitialValues({});
   installSecureStorageMock();
   await SettingsService.instance.init();
   final service=AppointmentService.forTesting(preferences:await SharedPreferences.getInstance());
   await service.init();
   final item=await service.add(title:'Consultation',callerName:'Jordan',phoneNumber:'555-0100',scheduledAt:DateTime(2030,2,3,10),notes:'Bring documents');
   final payload=service.formatTelegramSummary(item);
   expect(payload,contains('Consultation'));expect(payload,contains('Jordan'));expect(payload,contains('555-0100'));expect(payload,contains('Bring documents'));
   expect(await service.sendTelegramSummary(item.id),contains('not configured'));
  });
 });
}
