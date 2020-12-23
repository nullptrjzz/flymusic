import 'package:isolate/load_balancer.dart';
import 'package:isolate/isolate_runner.dart';

LoadBalancer pool;

Future initLoadBalancer() async {
  pool = await LoadBalancer.create(4, IsolateRunner.spawn);
}
