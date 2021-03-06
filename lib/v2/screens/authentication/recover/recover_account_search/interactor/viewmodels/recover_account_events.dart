import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// --- EVENTS
@immutable
abstract class RecoverAccountEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class OnUsernameChanged extends RecoverAccountEvent {
  final String userName;

  OnUsernameChanged(this.userName);

  @override
  String toString() => 'OnUsernameChanged { userName: $userName}';
}

class OnNextButtonTapped extends RecoverAccountEvent {
  @override
  String toString() => 'OnNextButtonTapped';
}
