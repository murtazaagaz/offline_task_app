abstract class NetworkEvent {}
class NetworkStatusChanged extends NetworkEvent {
  final bool isOnline;
  NetworkStatusChanged(this.isOnline);
}