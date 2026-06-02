import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/enums.dart';

/// Demo control: the customer [Mood] that drives the scripted scenario
/// (calm vs frustrated). Mirrors the prototype's "Customer mood" tweak.
class DemoCubit extends Cubit<Mood> {
  DemoCubit() : super(Mood.frustrated);

  bool get isFrustrated => state == Mood.frustrated;

  void setMood(Mood mood) => emit(mood);

  void toggle() => emit(isFrustrated ? Mood.calm : Mood.frustrated);
}
