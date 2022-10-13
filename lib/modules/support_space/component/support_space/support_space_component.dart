import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/assets.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/image_placeholder.dart';
import '../../../../widgets/markdown.dart';
import '../../../../widgets/scalable_widgets/horizontal_scalable_box.dart';
import '../../../../widgets/simple_skeleton.dart';
import '../button_group.dart';
import '../purchase_button/purchase_button_component.dart';
import '../subscription_buttons/subscription_buttons_component.dart';
import 'support_space_bloc.dart';
import 'support_space_view_model.dart';

/// The smallest donation that costs about 1 euro + VAT
const _smallDonationId = 'donation_1';

/// The mid-size donation that costs about 3 euro + VAT
const _mediumDonationId = 'donation_3';

/// The big donation that costs about 10 euro + VAT
const _largeDonationId = 'donation_10';

const Size purchaseButtonSize = Size(84, 48);

class SupportSpaceComponent extends StatelessWidget {
  const SupportSpaceComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Component<SupportSpaceBloc>(
      createViewModel: (bloc) => bloc.createViewModel(),
      builder: (context, bloc) {
        return StreamBuilder<SupportSpaceViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return SimpleSkeleton(appBarTitle: S.of(context).supportUs);
            }

            return _SupportUsView(snapshot.data!);
          },
        );
      },
    );
  }
}

class _SupportUsView extends StatefulWidget {
  const _SupportUsView(this.viewModel, {Key? key}) : super(key: key);

  final SupportSpaceViewModel viewModel;

  @override
  _SupportUsViewState createState() => _SupportUsViewState();
}

class _SupportUsViewState extends State<_SupportUsView> {
  static const _montlyTab = 0;
  static const _oneTimeTab = 1;

  late int currentFrequencyTab;

  @override
  void initState() {
    super.initState();
    currentFrequencyTab =
        widget.viewModel.hasSubscriptions ? _montlyTab : _oneTimeTab;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).supportUs), elevation: 0),
      body: Center(
        child: ListView(
          children: [
            HorizontalScalableBox(
              child: _imageBuilder(Assets.images.spaceBackground),
            ),
            const SizedBox(height: 24),
            Align(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 32, 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: _buildTextContent(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextContent(BuildContext context) {
    return Column(
      children: [
        // The text is split into several parts, to adjust
        // the space between a paragraph and a heading.
        _buildAboutUsSection(),
        const SizedBox(height: 32),
        _buildPaymentOptions(),
        const SizedBox(height: 32),
        _buildFinancesOfSpace(),
        const SizedBox(height: 32),
        _buildThanksForReading(),
      ],
    );
  }

  Widget _buildAboutUsSection() {
    return MarkdownBody(
      shrinkWrap: false,
      data: S.of(context).aboutUsText,
      styleSheet: buildStyleSheet(context),
    );
  }

  Widget _buildFinancesOfSpace() {
    return MarkdownBody(
      shrinkWrap: false,
      data: S.of(context).financesOfSpace(
            r'$50',
            r'$30',
            r'$10',
            r'$8',
            r'$1',
            r'$1',
            r'$30',
            r'$19',
            r'$1',
            r'$10',
          ),
      styleSheet: buildStyleSheet(context),
    );
  }

  Widget _buildThanksForReading() {
    return MarkdownBody(
      shrinkWrap: false,
      data: S.of(context).thanksForReadingText,
      styleSheet: buildStyleSheet(context),
    );
  }

  Widget _imageBuilder(String? url) {
    if (url == null) {
      return const ImagePlaceholder(
        duration: Duration(seconds: 2),
      );
    }

    return Image.asset(
      url,
      fit: BoxFit.cover,
      alignment: Alignment.bottomCenter,
    );
  }

  Widget _buildPaymentOptions() {
    final hasSubscriptions = widget.viewModel.hasSubscriptions;

    if (Platform.isWindows || Platform.isLinux) {
      return ElevatedButton.icon(
        label: Text(S.of(context).donate.toUpperCase()),
        icon: const FaIcon(FontAwesomeIcons.paypal),
        style: ElevatedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.primary,
          disabledForegroundColor:
              Theme.of(context).colorScheme.onPrimary.withOpacity(0.38),
          disabledBackgroundColor:
              Theme.of(context).colorScheme.onPrimary.withOpacity(0.12),
          fixedSize: const Size(350, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        onPressed: widget.viewModel.onPayPalButtonTap,
      );
    }

    return Column(
      children: [
        _buildDonationFrequencyTabs(),
        const SizedBox(height: 16),
        if (currentFrequencyTab == _oneTimeTab) _buildOneTimeDonationButtons(),
        if (currentFrequencyTab == _montlyTab && hasSubscriptions)
          const SubscriptionButtonsComponent(),
      ],
    );
  }

  Widget _buildDonationFrequencyTabs() {
    return ButtonGroup(
      current: currentFrequencyTab,
      titles: [
        if (Platform.isAndroid) S.of(context).monthly else null,
        S.of(context).oneTime,
      ],
      onTap: (i) => setState(() => currentFrequencyTab = i),
      activeColor: Theme.of(context).colorScheme.primary,
      inactiveColor: Theme.of(context).colorScheme.onPrimary,
    );
  }

  Widget _buildOneTimeDonationButtons() {
    return SizedBox(
      height: purchaseButtonSize.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: purchaseButtonSize.width,
            child: PurchaseButtonComponent(
              productId: _smallDonationId,
              textCallback: (price) => '★\n$price',
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: purchaseButtonSize.width,
            child: PurchaseButtonComponent(
              productId: _mediumDonationId,
              textCallback: (price) => '★★\n$price',
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: purchaseButtonSize.width,
            child: PurchaseButtonComponent(
              productId: _largeDonationId,
              textCallback: (price) => '★★★\n$price',
            ),
          ),
        ],
      ),
    );
  }
}
