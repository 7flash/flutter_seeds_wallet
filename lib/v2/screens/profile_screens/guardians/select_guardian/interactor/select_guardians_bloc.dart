import 'package:bloc/bloc.dart';
import 'package:seeds/v2/datasource/remote/model/member_model.dart';
import 'package:seeds/v2/screens/profile_screens/guardians/select_guardian/interactor/viewmodels/select_guardians_events.dart';
import 'package:seeds/v2/screens/profile_screens/guardians/select_guardian/interactor/viewmodels/select_guardians_state.dart';

/// --- BLOC:thi
class SelectGuardiansBloc extends Bloc<SelectGuardiansEvent, SelectGuardiansState> {
  SelectGuardiansBloc() : super(SelectGuardiansState.initial());

  @override
  Stream<SelectGuardiansState> mapEventToState(SelectGuardiansEvent event) async* {
    if (event is OnUserSelected) {
      var mutableSet = <MemberModel>{};
      mutableSet.addAll(state.selectedGuardians);
      mutableSet.add(event.user);

      yield state.copyWith(selectedGuardians: mutableSet);
    } else if (event is OnUserRemoved) {
      var mutableSet = <MemberModel>{};
      mutableSet.addAll(state.selectedGuardians);
      mutableSet.remove(event.user);

      yield state.copyWith(selectedGuardians: mutableSet);
    }
  }
}
