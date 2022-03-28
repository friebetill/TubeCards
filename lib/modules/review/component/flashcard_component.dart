import 'package:flutter/material.dart';

import '../../../widgets/editor/card_side_viewer.dart';
import '../animations/flip_animation.dart';

/// Flashcard is a card bearing information on both sides, which is intended
/// to be used as an aid in memorization.
class FlashcardComponent extends StatefulWidget {
  const FlashcardComponent({
    required this.frontText,
    required this.backText,
    this.onCardTap,
    this.isFrontSide = true,
    this.resetOnToggle = true,
    this.contentPadding = const EdgeInsets.all(24),
    Key? key,
  }) : super(key: key);

  final String frontText;
  final String backText;
  final bool isFrontSide;
  final bool resetOnToggle;
  final EdgeInsets contentPadding;

  // If provided, it overrides the default tap behavior of flipping the card.
  final VoidCallback? onCardTap;

  @override
  State<FlashcardComponent> createState() => _FlashcardComponentState();
}

class _FlashcardComponentState extends State<FlashcardComponent>
    with TickerProviderStateMixin {
  late FlipAnimation _flipAnimation;

  late bool _isFrontSide;

  final _frontScrollController = ScrollController();
  final _backScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _isFrontSide = widget.isFrontSide;
    _flipAnimation = FlipAnimation(AnimationController(vsync: this));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      // Makes the card and the background clickable so that clicks are
      // not swallowed if the user accidentally clicks on the background.
      child: Container(
        // Non-visible color is necessary to keep the area clickable
        color: const Color(0x00FFFFFF),
        child: Stack(
          children: [
            _flipAnimation.buildFlipFrontCardTransition(
              child: _buildCard(frontSide: true),
            ),
            _flipAnimation.buildFlipBackCardTransition(
              child: _buildCard(frontSide: false),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(FlashcardComponent oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isFrontSide != oldWidget.isFrontSide) {
      _isFrontSide = widget.isFrontSide;
      widget.isFrontSide
          ? _flipAnimation.toFrontSide()
          : _flipAnimation.toBackSide();
    }

    if (widget.resetOnToggle != oldWidget.resetOnToggle) {
      _flipAnimation.controller.reset();
      _frontScrollController.jumpTo(0);
      _backScrollController.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _flipAnimation.controller.dispose();
    super.dispose();
  }

  Widget _buildCard({required bool frontSide}) {
    final borderRadii = [
      if (_flipAnimation.controller.isAnimating &&
          _flipAnimation.isFrontSideShown)
        _flipAnimation.frontSideBorderRadius.value,
      if (_flipAnimation.controller.isAnimating &&
          !_flipAnimation.isFrontSideShown)
        _flipAnimation.backSideBorderRadius.value,
    ];

    final borderRadius = BorderRadius.vertical(
      top: const Radius.circular(10),
      bottom: Radius.circular(borderRadii.isNotEmpty ? borderRadii.first : 0.0),
    );

    return Material(
      borderRadius: BorderRadius.circular(10),
      color: Theme.of(context).colorScheme.surface,
      elevation: 4,
      child: SizedBox.expand(
        child: ClipRRect(
          // Make sure the scrollable overflow animation is clipped as well.
          borderRadius: borderRadius,
          child: SingleChildScrollView(
            controller:
                frontSide ? _frontScrollController : _backScrollController,
            child: CardSideViewer(
              text: frontSide ? widget.frontText : widget.backText,
              onTap: _handleTap,
              padding: widget.contentPadding,
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap() {
    if (widget.onCardTap != null) {
      widget.onCardTap!();
    } else {
      _flipCard();
    }
  }

  void _flipCard() {
    _isFrontSide ? _flipAnimation.toBackSide() : _flipAnimation.toFrontSide();
    _isFrontSide = !_isFrontSide;
  }
}
