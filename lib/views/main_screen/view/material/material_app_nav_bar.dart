import 'package:crabpay/views/custom_ui_elements/utilities/ui_utilities.dart';
import 'package:crabpay/core/global_graphic_driver.dart';
import 'package:crabpay/views/main_screen/driver/main_screen_cubit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MaterialAppNavBar extends StatelessWidget {
  final Function(int) onTap;
  const MaterialAppNavBar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final layout = context.select<MainScreenCubit, MainScreenLayout>(
      (cubit) => cubit.state.layout,
    );
    final currentIndex = context.select<MainScreenCubit, int>(
      (cubit) => cubit.state.page,
    );
    final double alignmentByX = -1 + (currentIndex * (2 / 3));
    return Stack(
      children: [
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: layout.navBarScrimHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: .bottomCenter,
                end: .topCenter,
                colors: [
                  context.appColorScheme.surfaceContainerLowest,
                  context.appColorScheme.surfaceContainerLowest.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        Center(
          heightFactor: 1.0,
          child: Container(
            width: layout.navBarWidth,
            height: layout.navBarHeight,
            margin: EdgeInsets.only(bottom: layout.navBarBottomMargin),
            child: Stack(
              children: [
                Builder(
                  builder: (context) {
                    final highGraphics = context.select<GlobalGraphicBloc, bool>(
                      (bloc) => bloc.state.highGraphics,
                    );
                    return Material(
                      borderRadius: .circular(layout.navBarCornerRadius),
                      clipBehavior: .antiAlias,
                      color: Colors.transparent,
                      child: BackdropFilter(
                        enabled: highGraphics,
                        filter: .blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          color: context.appColorScheme.surfaceContainerHighest.withValues(
                            alpha: highGraphics ? 0.4 : .97,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    begin: .topCenter,
                    end: .bottomCenter,
                    colors: [
                      context.appColorScheme.outline.withValues(alpha: .2),
                      context.appColorScheme.outline.withValues(alpha: .1),
                      Colors.transparent,
                      Colors.transparent,
                      context.appColorScheme.outline.withValues(alpha: .1),
                    ],
                  ).createShader(bounds),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: .circular(layout.navBarCornerRadius),
                      border: .all(color: Colors.white),
                    ),
                  ),
                ),
                Stack(
                  children: [
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOutCubic,
                      alignment: Alignment(alignmentByX, 0),
                      child: FractionallySizedBox(
                        widthFactor: .25,
                        heightFactor: 1,
                        child: Container(
                          margin: EdgeInsets.all(layout.navBarIndicatorInset),
                          decoration: BoxDecoration(
                            color: context.appColorScheme.secondaryContainer.withValues(alpha: .8),
                            borderRadius: BorderRadius.circular(layout.navBarIndicatorCornerRadius),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: layout.navBarContentTopPadding),
                      child: Row(
                        mainAxisAlignment: .center,
                        children: [
                          MaterialAppNavBarItem(
                            icon: Icons.home_outlined,
                            isSelected: currentIndex == 0,
                            onTap: () => onTap(0),
                            width: layout.navBarItemWidth,
                            iconSize: layout.navBarItemIconSize,
                          ),
                          MaterialAppNavBarItem(
                            icon: Icons.storefront_outlined,
                            isSelected: currentIndex == 1,
                            onTap: () => onTap(1),
                            width: layout.navBarItemWidth,
                            iconSize: layout.navBarItemIconSize,
                          ),
                          MaterialAppNavBarItem(
                            icon: Icons.support_agent_outlined,
                            isSelected: currentIndex == 2,
                            onTap: () => onTap(2),
                            width: layout.navBarItemWidth,
                            iconSize: layout.navBarItemIconSize,
                          ),
                          Builder(
                            builder: (context) {
                              final itemsCount = context.select<MainScreenCubit, int>(
                                (cubit) => cubit.state.userCartItemAmount,
                              );
                              final pendingOrders = context.select<MainScreenCubit, int>(
                                (cubit) => cubit.state.amountOfPendingOrders,
                              );
                              return Badge(
                                alignment: .center,
                                offset: Offset(-16, 0),
                                backgroundColor: context.appColorScheme.secondary,
                                textColor: context.appColorScheme.onSecondary,
                                label: Text(
                                  pendingOrders > 0 ? pendingOrders.toString() : '',
                                ),
                                isLabelVisible: pendingOrders > 0,
                                child: Badge(
                                  alignment: .center,
                                  offset: Offset(16, -20),
                                  backgroundColor: context.appColorScheme.error,
                                  textColor: context.appColorScheme.onError,
                                  label: Text(
                                    itemsCount > 0 ? itemsCount.toString() : '',
                                  ),
                                  isLabelVisible: itemsCount > 0,
                                  child: MaterialAppNavBarItem(
                                    icon: Icons.shopping_cart_checkout_rounded,
                                    isSelected: currentIndex == 3,
                                    onTap: () => onTap(3),
                                    width: layout.navBarItemWidth,
                                    iconSize: layout.navBarItemIconSize,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MaterialAppNavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData? activeIcon;
  final bool isSelected;
  final VoidCallback onTap;
  final double width;
  final double iconSize;
  const MaterialAppNavBarItem({
    super.key,
    required this.icon,
    this.activeIcon,
    required this.isSelected,
    required this.onTap,
    required this.width,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        height: double.infinity,
        child: Center(
          child: Icon(
            icon,
            color: isSelected ? context.appColorScheme.primary : context.appColorScheme.onSurface,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}
