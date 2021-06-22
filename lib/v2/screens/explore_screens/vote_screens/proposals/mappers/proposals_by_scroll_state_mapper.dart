import 'package:seeds/v2/datasource/remote/model/proposals_model.dart';
import 'package:seeds/v2/domain-shared/page_state.dart';
import 'package:seeds/v2/domain-shared/result_to_state_mapper.dart';
import 'package:seeds/v2/i18n/explore_screens/invite/invite.i18n.dart';
import 'package:seeds/v2/screens/explore_screens/vote_screens/proposals/viewmodels/proposals_list_state.dart';
import 'package:seeds/v2/screens/explore_screens/vote_screens/vote/interactor/viewmodels/proposal_type_model.dart';

class ProposalsByScrollStateMapper extends StateMapper {
  ProposalsListState mapResultToState(ProposalsListState currentState, Result result) {
    if (result.isError) {
      return currentState.copyWith(pageState: PageState.failure, errorMessage: "Error loading proposals".i18n);
    } else {
      List<ProposalModel> proposals = result.asValue!.value;
      ProposalType currentType = currentState.currentType;
      List<ProposalModel> filtered = [];
      // Filter proposals by proposal section type
      if (currentType.status.length == 1) {
        filtered =
            proposals.where((i) => i.stage == currentType.stage && i.status == currentType.status.first).toList();
      } else {
        // History covers 2 status, proposals with (passed, rejected) status are part of history list.
        filtered = proposals
            .where((i) =>
                i.stage == currentType.stage &&
                (i.status == currentType.status.first || i.status == currentType.status.last))
            .toList();
      }
      // Check if the list needs sort
      List<ProposalModel> reversed = currentType.isReverse ? List<ProposalModel>.from(filtered.reversed) : filtered;
      // Add the new proposals to current proposals
      List<ProposalModel> newProposals = currentState.proposals + reversed;
      // If reversed is a empty list then there are no more items to fetch
      return currentState.copyWith(proposals: newProposals, hasReachedMax: reversed.isEmpty);
    }
  }
}