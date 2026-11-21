import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'calendar_reminder_service.dart';
import 'settings_service.dart';
import 'telegram_service.dart';

enum AppointmentStatus { pending, confirmed, completed, cancelled }

@immutable
class AppointmentItem {
  final String id,title,callerName,phoneNumber,notes;
  final DateTime scheduledAt;
  final AppointmentStatus status;
  final bool telegramNotified;
  const AppointmentItem({required this.id,required this.title,required this.callerName,required this.phoneNumber,required this.scheduledAt,required this.notes,required this.status,this.telegramNotified=false});
  AppointmentItem copyWith({String? title,String? callerName,String? phoneNumber,DateTime? scheduledAt,String? notes,AppointmentStatus? status,bool? telegramNotified})=>AppointmentItem(id:id,title:title??this.title,callerName:callerName??this.callerName,phoneNumber:phoneNumber??this.phoneNumber,scheduledAt:scheduledAt??this.scheduledAt,notes:notes??this.notes,status:status??this.status,telegramNotified:telegramNotified??this.telegramNotified);
  Map<String,dynamic> toJson()=>{'id':id,'title':title,'callerName':callerName,'phoneNumber':phoneNumber,'scheduledAt':scheduledAt.toIso8601String(),'notes':notes,'status':status.name,'telegramNotified':telegramNotified};
  factory AppointmentItem.fromJson(Map<String,dynamic> j)=>AppointmentItem(id:(j['id']??'').toString(),title:(j['title']??'').toString(),callerName:(j['callerName']??'').toString(),phoneNumber:(j['phoneNumber']??'').toString(),scheduledAt:DateTime.tryParse((j['scheduledAt']??'').toString())??DateTime.now(),notes:(j['notes']??'').toString(),status:AppointmentStatus.values.firstWhere((s)=>s.name==(j['status']??'pending'),orElse:()=>AppointmentStatus.pending),telegramNotified:j['telegramNotified'] as bool???false);
}
class AppointmentService extends ChangeNotifier {
  AppointmentService._({SharedPreferences? preferences}):_prefs=preferences;
  static final AppointmentService instance=AppointmentService._();
  @visibleForTesting
  factory AppointmentService.forTesting({SharedPreferences? preferences})=>AppointmentService._(preferences:preferences);
  static const storageKey='jarvis_appointments_v1';
  SharedPreferences? _prefs;
  bool _loaded=false;
  final List<AppointmentItem> _items=[];
  List<AppointmentItem> get appointments=>List.unmodifiable(_items);
  Future<void> init()async{if(_loaded)return;_prefs??=await SharedPreferences.getInstance();final raw=_prefs!.getString(storageKey);if(raw!=null){try{final list=jsonDecode(raw) as List;_items.addAll(list.whereType<Map>().map((e)=>AppointmentItem.fromJson(Map<String,dynamic>.from(e))));}catch(_){}}_loaded=true;_sort();}
  void _sort()=>_items.sort((a,b)=>a.scheduledAt.compareTo(b.scheduledAt));
  Future<void> _save()async{await _prefs!.setString(storageKey,jsonEncode(_items.map((x)=>x.toJson()).toList()));notifyListeners();}
  Future<AppointmentItem> add({required String title,String callerName='',String phoneNumber='',required DateTime scheduledAt,String notes=''})async{await init();final id=DateTime.now().microsecondsSinceEpoch.toString();final item=AppointmentItem(id:id,title:title.trim(),callerName:callerName.trim(),phoneNumber:phoneNumber.trim(),scheduledAt:scheduledAt,notes:notes.trim(),status:AppointmentStatus.pending);_items.add(item);_sort();await _save();return item;}
  Future<bool> update(AppointmentItem item)async{await init();final i=_items.indexWhere((x)=>x.id==item.id);if(i<0)return false;_items[i]=item;_sort();await _save();return true;}
  Future<bool> setStatus(String id,AppointmentStatus status)async{await init();final i=_items.indexWhere((x)=>x.id==id);if(i<0)return false;_items[i]=_items[i].copyWith(status:status);await _save();return true;}
  Future<bool> delete(String id)async{await init();final before=_items.length;_items.removeWhere((x)=>x.id==id);if(before==_items.length)return false;await _save();return true;}
  String formatTelegramSummary(AppointmentItem item)=>'JARVIS PRO • Appointment\nTitle: '+item.title+'\nCaller: '+(item.callerName.isEmpty?'Unknown':item.callerName)+'\nPhone: '+(item.phoneNumber.isEmpty?'Not provided':item.phoneNumber)+'\nTime: '+item.scheduledAt.toLocal().toString()+'\nStatus: '+item.status.name+'\nNotes: '+(item.notes.isEmpty?'None':item.notes);
  Future<String> sendTelegramSummary(String id)async{await init();final item=_items.firstWhere((x)=>x.id==id);final settings=SettingsService.instance;if(settings.telegramToken.isEmpty)return 'Telegram bot token is not configured in Settings.';if(settings.telegramOwnerChatId.isEmpty)return 'Telegram owner chat ID is not configured in Settings.';final ok=await TelegramService.instance.sendMessage(settings.telegramOwnerChatId,formatTelegramSummary(item));if(!ok)return 'Telegram message failed. Check the bot token, network, and owner chat ID.';await update(item.copyWith(telegramNotified:true));return 'Appointment summary sent to your configured Telegram owner chat.';}
  Future<bool> exportToCalendar(String id)async{await init();final item=_items.firstWhere((x)=>x.id==id);await CalendarReminderService.instance.addItem(title:item.title,description:'Caller: '+item.callerName+'\nPhone: '+item.phoneNumber+'\n'+item.notes,dateTime:item.scheduledAt,isReminder:true);return true;}
}
