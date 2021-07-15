import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// --- EVENTS
@immutable
abstract class ProposalDetailsEvent extends Equatable {
  const ProposalDetailsEvent();
  @override
  List<Object> get props => [];
}

class OnLoadProposalData extends ProposalDetailsEvent {
  const OnLoadProposalData();
  @override
  String toString() => 'OnLoadProposalData';
}

// class OnFavourButtonTapped extends ProposalDetailsEvent {
//   const OnFavourButtonTapped();
//   @override
//   String toString() => 'OnFavourButtonTapped';
// }

// class OnAbstainButtonTapped extends ProposalDetailsEvent {
//   const OnAbstainButtonTapped();
//   @override
//   String toString() => 'OnAbstainButtonTapped';
// }

// class OnAgainstButtonTapped extends ProposalDetailsEvent {
//   const OnAgainstButtonTapped();
//   @override
//   String toString() => 'OnAgainstButtonTapped';
// }

class OnVoteAmountChanged extends ProposalDetailsEvent {
  final int voteAmount;

  const OnVoteAmountChanged(this.voteAmount);

  @override
  String toString() => 'OnVoteAmountChanged';
}

class OnConfirmButtonPressed extends ProposalDetailsEvent {
  const OnConfirmButtonPressed();
  @override
  String toString() => 'OnConfirmButtonPressed';
}

class OnNextProposalTapped extends ProposalDetailsEvent {
  const OnNextProposalTapped();
  @override
  String toString() => 'OnNextProposalTapped';
}
