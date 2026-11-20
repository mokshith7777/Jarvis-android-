import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class ConnectorHubService {
 ConnectorHubService._();static final instance=ConnectorHubService._();
 static const services=['WhatsApp','Gmail','Google Calendar','Google Drive','YouTube','Web Search','Outlook','Slack','Telegram','Notion'];
 Future<String?> getBridgeUrl(String s)async=>(await SharedPreferences.getInstance()).getString('jarvis.connector.$s');
 Future<void> setBridgeUrl(String s,String value)async{final p=await SharedPreferences.getInstance();final v=value.trim();if(v.isEmpty){await p.remove('jarvis.connector.$s');return;}final u=Uri.tryParse(v);if(u==null||!u.hasScheme||!['http','https'].contains(u.scheme)||u.host.isEmpty)throw FormatException('Invalid bridge URL');await p.setString('jarvis.connector.$s',v);}
 Future<bool> checkHealth(String s)async{final b=await getBridgeUrl(s);if(b==null||b.isEmpty)return false;try{final r=await http.get(Uri.parse('${b.replaceAll(RegExp(r'/+$'), '')}/health')).timeout(const Duration(seconds:6));return r.statusCode>=200&&r.statusCode<300;}catch(_){return false;}}
}