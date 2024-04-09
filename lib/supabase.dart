import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: 'https://zsqdathbkakooepdvsxr.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpzcWRhdGhia2Frb29lcGR2c3hyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTI1NjgwNzIsImV4cCI6MjAyODE0NDA3Mn0.60kpAUmG5zRQHhTLOP4x3EMrBK84lCHQlfJa1xiXQqE',
  );
}

final supabase = Supabase.instance.client;
