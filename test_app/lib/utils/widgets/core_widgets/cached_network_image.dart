import 'package:cached_network_image/cached_network_image.dart';
import 'package:test_app/exports.dart';
import 'package:shimmer/shimmer.dart';

class CustomCachedImageWidget extends StatelessWidget {
  const CustomCachedImageWidget({
    required this.imageUrl,
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final trimmedUrl = imageUrl.trim();
    if (trimmedUrl.isEmpty) {
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(0),
        child: Container(
          width: width,
          height: height,
          color: AppColors.shimmerBase,
          child: Icon(
            Icons.image_outlined,
            size: (width != null && height != null)
                ? (width! < height! ? width! * 0.5 : height! * 0.5)
                : 24,
            color: AppColors.textTertiary,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(0),
      child: CachedNetworkImage(
        imageUrl: trimmedUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: AppColors.shimmerBase,
          highlightColor: AppColors.shimmerHighlight,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: AppColors.shimmerBase,
              borderRadius: borderRadius ?? BorderRadius.zero,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          color: AppColors.shimmerBase,
          child: const Icon(
            Icons.broken_image_outlined,
            color: AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}
