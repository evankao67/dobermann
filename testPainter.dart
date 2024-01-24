@override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    var center = Offset(size.width / 2, size.height / 2);
    var radius = (size.width / 2) * (diameter / 10); // Calculate radius based on diameter
    Path path;

    switch (selectedRoute) {
      case 1:
        path = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
        canvas.drawPath(path, paint);
        break;
      case 2:
        path = Path()
          ..moveTo(center.dx, center.dy - radius)
          ..arcToPoint(
            Offset(center.dx, center.dy + radius),
            radius: Radius.circular(radius),
          );
        canvas.drawPath(path, paint);
        break;
      case 3:
        path = Path()
          ..moveTo(center.dx, center.dy - radius)
          ..lineTo(center.dx + radius, center.dy + radius)
          ..lineTo(center.dx - radius, center.dy + radius)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case 4:
        path = Path()
          ..addRect(Rect.fromCenter(center: center, width: 2 * radius, height: 2 * radius));
        canvas.drawPath(path, paint);
        break;
      case 5:
        path = Path()
          ..moveTo(center.dx, center.dy - radius)
          ..lineTo(center.dx + radius, center.dy)
          ..lineTo(center.dx, center.dy + radius)
          ..lineTo(center.dx - radius, center.dy)
          ..close();
        canvas.drawPath(path, paint);
        break;
      default:
        throw 'Route $selectedRoute not recognized';
    }

    // Drawing the landmark along the path
    if (path != null) {
      ui.PathMetric pathMetric = path.computeMetrics().first;
      ui.Tangent? tangent = pathMetric.getTangentForOffset(pathMetric.length * progress);

      if (tangent != null) {
        // Draw the landmark image at the position on the path
        canvas.drawImage(
          landmarkImage,
          tangent.position - Offset(landmarkImage.width / 2, landmarkImage.height / 2),
          Paint(),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant RouteDesignPainter oldDelegate) {
    //return oldDelegate.progress != progress || oldDelegate.selectedRoute != selectedRoute;
    return true;
  }
}
