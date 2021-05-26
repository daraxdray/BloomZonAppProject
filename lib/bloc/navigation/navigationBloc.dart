//import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:BloomZon/bloc/navigation/navigationEvent.dart';
//import 'package:BloomZon/bloc/navigation/navigationState.dart';
//import 'package:BloomZon/repository/NavigationRepository.dart';
//
//class NavBloc extends Bloc<NavEvent, NavState> {
//  NavigationRepository _navRepo;
//
//  NavBloc() : super(null) {
//    _navRepo = NavigationRepository();
//  }
//
//  @override
//  NavState get initialState => HomeState();
//
//  @override
//  Stream<NavState> mapEventToState(event) async* {
//    // TODO: implement mapEventToState
//    if (event is NavTo) {
//      switch (event.index) {
//        case 0:
//          yield HomeState();
//          break;
//        case 1:
//          print(event.index);
//          yield TipState(event.index);
//          break;
//        case 3:
//          yield ContactState(event.index);
//          break;
//      }
//    }
//  }
//}
