import 'package:flutter/material.dart';

String truncateTextByChars(String text, int maxChars) {
  if (text.length <= maxChars) {
    return text;
  }
  return '${text.substring(0, maxChars)}...';
}

String truncateText(String text, int maxWords) {
  List<String> words = text.split(' ');
  if (words.length <= maxWords) {
    return text;
  }
  return '${words.take(maxWords).join(' ')}...';
}

String formatRating(dynamic rating) {
  if (rating is int || (rating is double && rating == rating.floorToDouble())) {
    return "$rating.0";
  }
  return rating.toString();
}

String formatDistance(dynamic distance) {
  if (distance == null) return "Tidak tersedia";

  double dist = distance is double
      ? distance
      : double.tryParse(distance.toString()) ?? 0.0;

  if (dist < 1.0) {
    // Jika jarak kurang dari 1 KM, tampilkan dalam meter
    return "${(dist * 1000).toStringAsFixed(0)} meter";
  } else {
    // Jika jarak 1 KM atau lebih, tampilkan dalam kilometer
    return "${dist.toStringAsFixed(1)} KM";
  }
}

Color? checking(double nilai) {
  if (nilai >= 4.5) {
    return Colors.yellow[700];
  } else if (nilai >= 3.0) {
    return Colors.yellow[700];
  } else {
    return Colors.yellow[700];
  }
}

