import 'package:extended_image/extended_image.dart';
import 'package:material_ui/material_ui.dart';

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
    BorderRadius? borderRadius,
    BoxShape shape = BoxShape.rectangle,
  }) {
    return Center(
      child: ExtendedImage.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        cache: true,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle ? borderRadius : null,
        loadStateChanged: (state) {
          switch (state.extendedImageLoadState) {
            case LoadState.loading:
              return _buildFallback(
                custom: placeholder,
                asset: placeholderAsset,
                width: width,
                height: height,
                fit: fit,
              );
            case LoadState.failed:
              return _buildFallback(
                custom: error,
                asset: errorAsset,
                width: width,
                height: height,
                fit: fit,
              );
            case LoadState.completed:
              // 返回 null 表示使用默认的 state.completedWidget
              return null;
          }
        },
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
      fit: fit,
      placeholderAsset: placeholderAsset,
      errorAsset: errorAsset,
      shape: BoxShape.circle,
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
      fit: fit,
      placeholderAsset: placeholderAsset,
      errorAsset: errorAsset,
      borderRadius: borderRadius,
    );
  }

  /// loading / failed 状态统一构建占位或错误视图
  static Widget _buildFallback({
    Widget? custom,
    String? asset,
    double? width,
    double? height,
    BoxFit? fit,
  }) {
    if (custom != null) return custom;
    if (asset != null) {
      return Image.asset(asset, fit: fit, width: width, height: height);
    }
    return const SizedBox.shrink();
  }
}
