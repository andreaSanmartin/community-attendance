import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../models/youth_model.dart';
import 'youth_form_screen.dart';
import 'youth_profile_screen.dart';

class YouthListScreen extends StatefulWidget { const YouthListScreen({super.key}); @override State<YouthListScreen> createState() => _YouthListScreenState(); }
class _YouthListScreenState extends State<YouthListScreen> {
  final _api = ApiClient(SecureStorageService());
  final _search = TextEditingController();
  List<YouthModel> _items = [];
  bool _loading = true;
  @override void initState(){ super.initState(); _load(); }
  Future<void> _load() async { setState(() => _loading=true); final r=await _api.dio.get('/api/youth', queryParameters: {'search': _search.text.isEmpty ? null : _search.text}); _items=(r.data as List).map((e)=>YouthModel.fromJson(Map<String,dynamic>.from(e))).toList(); if(mounted)setState(()=>_loading=false); }
  @override Widget build(BuildContext context)=>Scaffold(
    appBar: AppBar(title: const Text('Jóvenes')),
    floatingActionButton: FloatingActionButton.extended(backgroundColor: AppColors.red, foregroundColor: Colors.white, onPressed: () async { final changed=await Navigator.push<bool>(context, MaterialPageRoute(builder:(_)=>const YouthFormScreen())); if(changed==true)_load(); }, icon: const Icon(Icons.add), label: const Text('Nuevo joven')),
    body: Column(children:[Padding(padding:const EdgeInsets.all(16),child:TextField(controller:_search,onSubmitted:(_)=>_load(),decoration:InputDecoration(hintText:'Buscar por nombre o celular...',prefixIcon:const Icon(Icons.search),suffixIcon:IconButton(onPressed:_load,icon:const Icon(Icons.arrow_forward))))),Expanded(child:_loading?const Center(child:CircularProgressIndicator()):RefreshIndicator(onRefresh:_load,child:ListView.separated(itemCount:_items.length,separatorBuilder:(_,__)=>const Divider(height:1),itemBuilder:(_,i){final y=_items[i];return ListTile(leading:CircleAvatar(backgroundColor:AppColors.navy,foregroundColor:Colors.white,child:Text(y.fullName.split(' ').take(2).map((x)=>x[0]).join())),title:Text(y.fullName,style:const TextStyle(fontWeight:FontWeight.w700)),subtitle:Text(y.phone),trailing:const Icon(Icons.chevron_right),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>YouthProfileScreen(youth:y))).then((_)=>_load()));})))])
  );
}
