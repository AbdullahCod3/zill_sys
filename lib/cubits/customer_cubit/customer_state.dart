part of 'customer_cubit.dart';

/// Customer phone lifecycle: idle → ringing → connected → ended. The customer
/// never sees Shadow — this is a plain phone-call screen.
sealed class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object?> get props => [];
}

class CustomerIdle extends CustomerState {
  const CustomerIdle();
}

class CustomerRinging extends CustomerState {
  const CustomerRinging();
}

class CustomerConnected extends CustomerState {
  final int seconds;
  final bool muted;
  final bool speakerOn;

  const CustomerConnected({
    this.seconds = 0,
    this.muted = false,
    this.speakerOn = false,
  });

  CustomerConnected copyWith({int? seconds, bool? muted, bool? speakerOn}) =>
      CustomerConnected(
        seconds: seconds ?? this.seconds,
        muted: muted ?? this.muted,
        speakerOn: speakerOn ?? this.speakerOn,
      );

  @override
  List<Object?> get props => [seconds, muted, speakerOn];
}

class CustomerEnded extends CustomerState {
  final int seconds;

  const CustomerEnded(this.seconds);

  @override
  List<Object?> get props => [seconds];
}
