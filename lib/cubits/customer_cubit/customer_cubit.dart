import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_constants.dart';

part 'customer_state.dart';

/// Drives the customer-side phone screen. No Shadow/AI here by design.
class CustomerCubit extends Cubit<CustomerState> {
  CustomerCubit() : super(const CustomerIdle());

  Timer? _ringTimer;
  Timer? _tickTimer;

  /// Customer taps "Call" → ringing, then the agent answers after a delay.
  void startCall() {
    _ringTimer?.cancel();
    emit(const CustomerRinging());
    _ringTimer = Timer(AppConfig.customerRingDuration, () {
      if (state is CustomerRinging) {
        emit(const CustomerConnected());
        _startTicking();
      }
    });
  }

  void toggleMute() {
    final s = state;
    if (s is CustomerConnected) emit(s.copyWith(muted: !s.muted));
  }

  void toggleSpeaker() {
    final s = state;
    if (s is CustomerConnected) emit(s.copyWith(speakerOn: !s.speakerOn));
  }

  void endCall() {
    _ringTimer?.cancel();
    _tickTimer?.cancel();
    final s = state;
    final seconds = s is CustomerConnected ? s.seconds : 0;
    emit(CustomerEnded(seconds));
  }

  void reset() {
    _ringTimer?.cancel();
    _tickTimer?.cancel();
    emit(const CustomerIdle());
  }

  void _startTicking() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final s = state;
      if (s is CustomerConnected) emit(s.copyWith(seconds: s.seconds + 1));
    });
  }

  @override
  Future<void> close() {
    _ringTimer?.cancel();
    _tickTimer?.cancel();
    return super.close();
  }
}
