import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

class CacheImage {
  CacheImage._();

  static Widget custom(
    String imageUrl, {
    double? width,
    double? height,
    BoxFit? fit,
    Widget? placeholder,
    String? placeholderAsset,
    Widget? error,
    String? errorAsset,
    Widget Function(BuildContext c, ImageProvider i)? imageBuilder,
  }) {
    return Center(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (c, s) {
          if (placeholder != null) return placeholder;
          if (placeholderAsset != null) {
            return Image.asset(
              placeholderAsset,
              fit: fit,
              width: width,
              height: height,
            );
          }
          return SizedBox();
        },
        errorWidget: (c, s, o) {
          if (error != null) return error;
          if (errorAsset != null) {
            return Image.asset(
              errorAsset,
              fit: fit,
              width: width,
              height: height,
            );
          }
          return SizedBox();
        },
        imageBuilder: imageBuilder,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
      ),
    );
  }

  static Widget maxFinite(
    String imageUrl, {
    BoxFit fit = BoxFit.fill,
    String? placeholderAsset,
    String? errorAsset,
  }) {
    return custom(
      imageUrl,
      width: double.maxFinite,
      height: double.maxFinite,
      fit: fit,
      placeholderAsset: placeholderAsset,
      errorAsset: errorAsset,
    );
  }

  static Widget square(
    String imageUrl, {
    required double size,
    BoxFit fit = BoxFit.cover,
    String? placeholderAsset,
    String? errorAsset,
  }) {
    return custom(
      imageUrl,
      width: size,
      height: size,
      fit: fit,
      placeholderAsset: placeholderAsset,
      errorAsset: errorAsset,
      imageBuilder: (c, i) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            image: DecorationImage(image: i, fit: fit),
          ),
        );
      },
    );
  }

  static Widget circle(
    String imageUrl, {
    required double size,
    BoxFit fit = BoxFit.cover,
    String? placeholderAsset,
    String? errorAsset,
  }) {
    return custom(
      imageUrl,
      width: size,
      height: size,
      placeholderAsset: placeholderAsset,
      errorAsset: errorAsset,
      imageBuilder: (c, i) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size / 2),
            image: DecorationImage(image: i, fit: fit),
          ),
        );
      },
    );
  }

  static Widget borderRadius(
    String imageUrl, {
    double? width,
    double? height,
    BorderRadius borderRadius = BorderRadius.zero,
    BoxFit fit = BoxFit.cover,
    String? placeholderAsset,
    String? errorAsset,
  }) {
    return custom(
      imageUrl,
      width: width,
      height: height,
      placeholderAsset: placeholderAsset,
      errorAsset: errorAsset,
      imageBuilder: (c, i) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            image: DecorationImage(image: i, fit: fit),
          ),
        );
      },
    );
  }
}
