import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/LanguageBloc/language_event.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/LanguageBloc/language_state.dart';
 

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  LanguageBloc() : super(LanguageState(Locale('en'))) {
    on<ChangeLanguage>((event, emit) => emit(LanguageState(event.locale)));
  }
}
