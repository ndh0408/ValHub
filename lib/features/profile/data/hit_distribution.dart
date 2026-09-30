/// Hit shares from the verified damage hit counts. No hits means unknown.
({double? head, double? body, double? legs}) hitDistribution(
  int head,
  int body,
  int legs,
) {
  final total = head + body + legs;
  if (total <= 0 || head < 0 || body < 0 || legs < 0) {
    return (head: null, body: null, legs: null);
  }
  return (head: head / total, body: body / total, legs: legs / total);
}
