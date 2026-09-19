import 'dart:async';

import 'package:flutter/material.dart';

import '../models/commercial_ad.dart';
import '../screens/commercial_ad_details_screen.dart';
import '../services/commercial_service.dart';

class CommercialAdBanner extends StatefulWidget {
  final String placement;

  const CommercialAdBanner({
    super.key,
    this.placement = 'home',
  });

  @override
  State<CommercialAdBanner> createState() =>
      _CommercialAdBannerState();
}

class _CommercialAdBannerState
    extends State<CommercialAdBanner> {
  final PageController _pageController =
  PageController(
    viewportFraction: 0.92,
  );

  Timer? _timer;
  int _currentPage = 0;
  int _adsCount = 0;
  late Stream<List<CommercialAd>> _adsStream;
  List<CommercialAd> _lastAds = const [];

  @override
  void initState() {
    super.initState();

    _adsStream = CommercialService.instance.activeAds(
      placement: widget.placement,
    );

    _timer =
        Timer.periodic(
          const Duration(seconds: 4),
              (_) => _moveToNextAd(),
        );
  }

  @override
  void didUpdateWidget(
      covariant CommercialAdBanner oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.placement != widget.placement) {
      _adsStream = CommercialService.instance.activeAds(
        placement: widget.placement,
      );
      _lastAds = const [];
      _currentPage = 0;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _moveToNextAd() {
    if (!mounted ||
        !_pageController.hasClients ||
        _adsCount <= 1) {
      return;
    }

    final next =
        (_currentPage + 1) % _adsCount;

    _pageController.animateToPage(
      next,
      duration:
      const Duration(
        milliseconds: 650,
      ),
      curve:
      Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(
      BuildContext context
      ) {
    return StreamBuilder<List<CommercialAd>>(
      stream: _adsStream,

      builder:
          (context, snapshot) {
        if (snapshot.hasData) {
          _lastAds = snapshot.data!;
        }

        final ads = snapshot.data ?? _lastAds;

        if (snapshot.hasError) {
          debugPrint(
            'تعذر تحميل إعلانات ${widget.placement}: ${snapshot.error}',
          );
        }

        _adsCount =
            ads.length;

        if (ads.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.campaign_rounded,
                      size: 21,
                    ),
                    SizedBox(width: 7),
                    Text(
                      'إعلانات مميزة',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: 145,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color(0xFF0F766E),
                      Color(0xFF334155),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F766E)
                          .withValues(alpha: .18),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 18,
                      top: 22,
                      child: Icon(
                        Icons.campaign_rounded,
                        size: 105,
                        color: Colors.white
                            .withValues(alpha: .12),
                      ),
                    ),
                    const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.campaign_rounded,
                            color: Colors.white,
                            size: 42,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'مساحة إعلانية',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'إعلانك يظهر هنا',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],
          );
        }

        if (_currentPage >=
            ads.length) {
          _currentPage = 0;
        }

        return Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            const Padding(
              padding:
              EdgeInsets.symmetric(
                horizontal: 4,
              ),
              child:
              Row(
                children: [
                  Icon(
                    Icons.campaign_rounded,
                    size: 21,
                  ),
                  SizedBox(width: 7),
                  Text(
                    'إعلانات مميزة',
                    style:
                    TextStyle(
                      fontSize: 17,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            SizedBox(
              height: 168,
              child:
              PageView.builder(
                controller:
                _pageController,

                itemCount:
                ads.length,

                onPageChanged:
                    (index) {
                  setState(() {
                    _currentPage =
                        index;
                  });
                },

                itemBuilder:
                    (context, index) {
                  final ad =
                  ads[index];

                  return Padding(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 5,
                    ),

                    child:
                    _AdTemplateCard(
                      ad: ad,
                    ),
                  );
                },
              ),
            ),

            if (ads.length > 1) ...[
              const SizedBox(
                height: 9,
              ),

              Center(
                child:
                Wrap(
                  spacing: 6,
                  children:
                  List.generate(
                    ads.length,
                        (index) {
                      final selected =
                          index ==
                              _currentPage;

                      return AnimatedContainer(
                        duration:
                        const Duration(
                          milliseconds:
                          250,
                        ),
                        width:
                        selected
                            ? 22
                            : 7,
                        height: 7,
                        decoration:
                        BoxDecoration(
                          borderRadius:
                          BorderRadius
                              .circular(
                            20,
                          ),
                          color:
                          selected
                              ?
                          Theme.of(
                            context,
                          )
                              .colorScheme
                              .primary
                              :
                          Theme.of(
                            context,
                          )
                              .colorScheme
                              .outlineVariant,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],

            const SizedBox(
              height: 18,
            ),
          ],
        );
      },
    );
  }
}

class _AdTemplateCard
    extends StatelessWidget {
  final CommercialAd ad;

  const _AdTemplateCard({
    required this.ad,
  });

  @override
  Widget build(
      BuildContext context
      ) {
    final style =
    _AdCategoryStyle.from(
      ad.category,
    );

    return Material(
      color:
      Colors.transparent,

      child:
      InkWell(
        borderRadius:
        BorderRadius.circular(
          24,
        ),

        onTap: () {
          CommercialService.instance
              .incrementAdMetric(
            ad.id,
            'clicks',
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  CommercialAdDetailsScreen(
                    ad: ad,
                  ),
            ),
          );
        },

        child:
        Ink(
          decoration:
          BoxDecoration(
            borderRadius:
            BorderRadius.circular(
              24,
            ),
            gradient:
            LinearGradient(
              begin:
              Alignment.topRight,
              end:
              Alignment.bottomLeft,
              colors:
              style.gradient,
            ),
            boxShadow: [
              BoxShadow(
                color:
                style.shadowColor
                    .withValues(
                  alpha: .20,
                ),
                blurRadius: 17,
                offset:
                const Offset(
                  0,
                  7,
                ),
              ),
            ],
          ),

          child:
          ClipRRect(
            borderRadius:
            BorderRadius.circular(
              24,
            ),

            child:
            Stack(
              children: [

                Positioned(
                  left: -25,
                  top: -28,
                  child:
                  Container(
                    width: 125,
                    height: 125,
                    decoration:
                    BoxDecoration(
                      shape:
                      BoxShape.circle,
                      color:
                      Colors.white
                          .withValues(
                        alpha: .10,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: 28,
                  bottom: -52,
                  child:
                  Container(
                    width: 150,
                    height: 150,
                    decoration:
                    BoxDecoration(
                      shape:
                      BoxShape.circle,
                      color:
                      Colors.white
                          .withValues(
                        alpha: .08,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: 20,
                  top: 20,
                  bottom: 20,
                  child:
                  Opacity(
                    opacity: .18,
                    child:
                    Icon(
                      style.icon,
                      size: 88,
                      color:
                      Colors.white,
                    ),
                  ),
                ),

                Padding(
                  padding:
                  const EdgeInsets
                      .fromLTRB(
                    16,
                    8,
                    16,
                    8,
                  ),

                  child:
                  Row(
                    children: [

                      Expanded(
                        flex: 7,
                        child:
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          mainAxisAlignment:
                          MainAxisAlignment
                              .center,

                          children: [

                            Row(
                              children: [

                                Container(
                                  padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withValues(alpha: .18),
                                    borderRadius:
                                    BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.campaign_rounded,
                                        color: Colors.white,
                                        size: 13,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'إعلان ممول',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                if (ad.featured) ...[
                                  const SizedBox(width: 7),
                                  Container(
                                    padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amberAccent
                                          .withValues(alpha: .20),
                                      borderRadius:
                                      BorderRadius.circular(18),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.star_rounded,
                                          color: Colors.amberAccent,
                                          size: 14,
                                        ),
                                        SizedBox(width: 3),
                                        Text(
                                          'مميز',
                                          style: TextStyle(
                                            color: Colors.amberAccent,
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),

                            const SizedBox(
                              height: 9,
                            ),

                            Text(
                              ad.businessName
                                  .trim()
                                  .isEmpty
                                  ?
                              ad.title
                                  :
                              ad.businessName,
                              maxLines: 1,
                              overflow:
                              TextOverflow
                                  .ellipsis,
                              style:
                              const TextStyle(
                                color:
                                Colors.white,
                                fontWeight:
                                FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),

                            const SizedBox(
                              height: 5,
                            ),

                            Text(
                              ad.title,
                              maxLines: 1,
                              overflow:
                              TextOverflow
                                  .ellipsis,
                              style:
                              TextStyle(
                                color:
                                Colors.white
                                    .withValues(
                                  alpha: .94,
                                ),
                                fontWeight:
                                FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            Text(
                              ad.description,
                              maxLines: 2,
                              overflow:
                              TextOverflow
                                  .ellipsis,
                              style:
                              TextStyle(
                                height: 1.35,
                                color:
                                Colors.white
                                    .withValues(
                                  alpha: .86,
                                ),
                                fontSize: 11.5,
                              ),
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            Row(
                              children: [
                                Container(
                                  padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withValues(alpha: .14),
                                    borderRadius:
                                    BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        style.icon,
                                        size: 15,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        style.label,
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: .94),
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'اضغط للتفاصيل والتواصل',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white
                                          .withValues(alpha: .78),
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Container(
                        width: 48,
                        height: 48,
                        decoration:
                        BoxDecoration(
                          color:
                          Colors.white
                              .withValues(
                            alpha: .18,
                          ),
                          shape:
                          BoxShape.circle,
                          border:
                          Border.all(
                            color:
                            Colors.white
                                .withValues(
                              alpha: .28,
                            ),
                          ),
                        ),
                        child:
                        Icon(
                          style.icon,
                          size: 27,
                          color:
                          Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdCategoryStyle {
  final String label;
  final IconData icon;
  final List<Color> gradient;
  final Color shadowColor;

  const _AdCategoryStyle({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.shadowColor,
  });

  factory _AdCategoryStyle.from(
      String rawCategory
      ) {
    final category =
    rawCategory
        .trim()
        .toLowerCase();

    if (category.contains('مطعم') ||
        category.contains('أكل') ||
        category.contains('restaurant') ||
        category.contains('food')) {
      return const _AdCategoryStyle(
        label: 'مطاعم وأطعمة',
        icon:
        Icons.restaurant_rounded,
        gradient: [
          Color(0xFFEA580C),
          Color(0xFFB91C1C),
        ],
        shadowColor:
        Color(0xFFB91C1C),
      );
    }

    if (category.contains('سيار') ||
        category.contains('car') ||
        category.contains('auto')) {
      return const _AdCategoryStyle(
        label: 'سيارات ومعارض',
        icon:
        Icons.directions_car_filled_rounded,
        gradient: [
          Color(0xFF0F172A),
          Color(0xFF2563EB),
        ],
        shadowColor:
        Color(0xFF2563EB),
      );
    }

    if (category.contains('عقار') ||
        category.contains('بيت') ||
        category.contains('real')) {
      return const _AdCategoryStyle(
        label: 'عقارات',
        icon:
        Icons.apartment_rounded,
        gradient: [
          Color(0xFF065F46),
          Color(0xFF0F766E),
        ],
        shadowColor:
        Color(0xFF0F766E),
      );
    }

    if (category.contains('طب') ||
        category.contains('عياد') ||
        category.contains('medical') ||
        category.contains('clinic')) {
      return const _AdCategoryStyle(
        label: 'عيادات ومراكز طبية',
        icon:
        Icons.local_hospital_rounded,
        gradient: [
          Color(0xFF0369A1),
          Color(0xFF06B6D4),
        ],
        shadowColor:
        Color(0xFF0369A1),
      );
    }

    if (category.contains('صيدل') ||
        category.contains('pharmacy')) {
      return const _AdCategoryStyle(
        label: 'صيدليات',
        icon:
        Icons.medication_rounded,
        gradient: [
          Color(0xFF047857),
          Color(0xFF22C55E),
        ],
        shadowColor:
        Color(0xFF047857),
      );
    }

    if (category.contains('ملابس') ||
        category.contains('أزياء') ||
        category.contains('fashion')) {
      return const _AdCategoryStyle(
        label: 'ملابس وأزياء',
        icon:
        Icons.checkroom_rounded,
        gradient: [
          Color(0xFF7E22CE),
          Color(0xFFDB2777),
        ],
        shadowColor:
        Color(0xFF7E22CE),
      );
    }

    if (category.contains('الكتر') ||
        category.contains('إلكتر') ||
        category.contains('هاتف') ||
        category.contains('electronic')) {
      return const _AdCategoryStyle(
        label: 'إلكترونيات',
        icon:
        Icons.devices_rounded,
        gradient: [
          Color(0xFF1D4ED8),
          Color(0xFF7C3AED),
        ],
        shadowColor:
        Color(0xFF1D4ED8),
      );
    }

    if (category.contains('صالون') ||
        category.contains('تجميل') ||
        category.contains('beauty')) {
      return const _AdCategoryStyle(
        label: 'صالونات وتجميل',
        icon:
        Icons.spa_rounded,
        gradient: [
          Color(0xFFBE185D),
          Color(0xFFF472B6),
        ],
        shadowColor:
        Color(0xFFBE185D),
      );
    }

    return const _AdCategoryStyle(
      label: 'خدمات وأعمال',
      icon:
      Icons.storefront_rounded,
      gradient: [
        Color(0xFF334155),
        Color(0xFF0F766E),
      ],
      shadowColor:
      Color(0xFF334155),
    );
  }
}
