import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:offline_task_app/modules/tasks/network_bloc/network_event.dart';
import 'package:offline_task_app/modules/tasks/network_bloc/network_state.dart';

class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  NetworkBloc() : super(NetworkInitial()) {
    final Connectivity connectivity = Connectivity();

  _subscription =  connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> connectivityResult) {
      final isOnline = (connectivityResult.contains(ConnectivityResult.mobile) || (connectivityResult.contains(ConnectivityResult.wifi)));
      add(NetworkStatusChanged(isOnline));
    });
     

    on<NetworkStatusChanged>((event, emit) {
      if (event.isOnline) {
        emit(NetworkOnline());
      } else {
        emit(NetworkOffline());
      }
    });
  }



  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
