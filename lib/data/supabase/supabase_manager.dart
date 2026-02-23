import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SupabaseManager {
  static final SupabaseClient supabase = Supabase.instance.client;
}
