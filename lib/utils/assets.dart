import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../data/models/unsplash_image.dart';
import '../main.dart';

class Assets {
  Assets._();

  static final Images images = Images();
  static final Videos videos = Videos();

  static Future<void> initDefaultCoverImage() async {
    final cacheManager = getIt<BaseCacheManager>();

    final coverImage =
        await cacheManager.getFileFromCache(defaultCoverImage.regularUrl!);
    if (coverImage != null) {
      return;
    }

    final byteData = await rootBundle.load(Assets.images.defaultCoverImage);
    final bytes = byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
    await cacheManager.putFile(
      defaultCoverImage.regularUrl!,
      bytes,
      fileExtension: 'jpeg',
    );
  }
}

class Images {
  /// The path to the images folder
  static const _imagesPath = 'assets/images';

  // Images from https://www.manypixels.co/gallery
  String astronaut = '$_imagesPath/astronaut.svg';
  String maintenance = '$_imagesPath/maintenance.svg';
  String newMessage = '$_imagesPath/new_message.svg';
  String startup = '$_imagesPath/startup.svg';
  String teamWork = '$_imagesPath/team_work.svg';

  // Logos
  String ankiLogo = '$_imagesPath/anki_logo.svg';
  String bingLogo = '$_imagesPath/bing_logo.svg';
  String csvLogo = '$_imagesPath/csv_logo.svg';
  String googleSheetsLogo = '$_imagesPath/google_sheets_logo.svg';
  String microsoftExcelLogo = '$_imagesPath/microsoft_excel_logo.svg';

  // TubeCards brand images
  String brandLogo = '$_imagesPath/brand_logo.svg';
  String brandLogoWhite = '$_imagesPath/brand_logo_white.svg';
  String brandText = '$_imagesPath/brand_text.svg';
  String brandTextWhite = '$_imagesPath/brand_text_white.svg';

  // Unsplash Images, https://unsplash.com
  /// Image by Geordanna Cordero, https://unsplash.com/photos/5NE6mX0WVfQ
  String defaultCoverImage = '$_imagesPath/default_cover_image_regular.jpeg';

  /// Image by Greg Rakozy, https://unsplash.com/photos/oMpAz-DN-9I
  String spaceBackground = '$_imagesPath/space_background.jpg';

  // Video placeholder
  String nightSkyPlaceholder = '$_imagesPath/night_sky_placeholder.jpg';
}

class Videos {
  /// The path to the videos folder
  static const _videosPath = 'assets/videos';

  String nightSky = '$_videosPath/night_sky.mp4';
}
