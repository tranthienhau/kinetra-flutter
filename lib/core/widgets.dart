import 'package:flutter/material.dart';

import 'theme.dart';

/// Neon pill with an ink label (or ink pill with a white label when [dark]).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onTap, this.icon, this.dark = false});

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final fg = dark ? Colors.white : K.ink;
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: Material(
        color: onTap == null ? (dark ? K.ink : K.neon).withValues(alpha: .4) : (dark ? K.ink : K.neon),
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: K.body.copyWith(fontWeight: FontWeight.w600, color: fg)),
              if (icon != null) ...[const SizedBox(width: 8), Icon(icon, size: 20, color: fg)],
            ],
          ),
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, required this.onTap, this.icon});

  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 52,
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            backgroundColor: K.surface,
            foregroundColor: K.ink,
            side: const BorderSide(color: K.borderStrong, width: 1.5),
            shape: const StadiumBorder(),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: K.label.copyWith(fontWeight: FontWeight.w600)),
              if (icon != null) ...[const SizedBox(width: 6), Icon(icon, size: 18)],
            ],
          ),
        ),
      );
}

class KCard extends StatelessWidget {
  const KCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.color = K.surface, this.onTap, this.border = true});

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final VoidCallback? onTap;
  final bool border;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(K.rCard),
          border: border && color == K.surface ? Border.all(color: K.border) : null,
          boxShadow: K.shadow,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(K.rCard),
            onTap: onTap,
            child: Padding(padding: padding, child: child),
          ),
        ),
      );
}

/// Ink hero card: the one bold focal element on most screens.
class InkCard extends StatelessWidget {
  const InkCard({super.key, required this.child, this.padding = const EdgeInsets.all(20)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => KCard(color: K.ink, padding: padding, child: child);
}

class KChip extends StatelessWidget {
  const KChip({super.key, required this.label, this.selected = false, this.onTap, this.icon});

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? K.neon : K.accentFill;
    return Material(
      color: selected ? K.ink : K.accentTint,
      shape: StadiumBorder(side: BorderSide(color: selected ? K.ink : K.border)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[Icon(icon, size: 16, color: fg), const SizedBox(width: 6)],
            Text(label, style: K.caption.copyWith(color: fg, fontWeight: selected ? FontWeight.w600 : FontWeight.w500)),
          ]),
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, this.icon, this.fg = K.success, this.bg = K.successTint});

  final String label;
  final IconData? icon;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 14, color: fg), const SizedBox(width: 4)],
          Text(label, style: K.caption.copyWith(color: fg, fontWeight: FontWeight.w600)),
        ]),
      );
}

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.value, this.onInk = false, this.height = 8});

  final double value;
  final bool onInk;
  final double height;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          height: height,
          child: Stack(children: [
            Positioned.fill(child: ColoredBox(color: onInk ? Colors.white.withValues(alpha: .15) : K.surfaceAlt)),
            FractionallySizedBox(
              widthFactor: value.clamp(0, 1),
              child: ColoredBox(color: onInk ? K.neon : K.accentFill),
            ),
          ]),
        ),
      );
}

class Thumb extends StatelessWidget {
  const Thumb(this.asset, {super.key, this.size = 52, this.radius = 12});

  final String asset;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.asset(asset, width: size, height: size, fit: BoxFit.cover),
      );
}

class Avatar extends StatelessWidget {
  const Avatar({super.key, this.size = 44});

  final double size;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(shape: BoxShape.circle, color: K.neon),
        child: ClipOval(child: Image.asset('assets/images/avatar-alex.jpg', width: size, height: size, fit: BoxFit.cover)),
      );
}

class IconCircle extends StatelessWidget {
  const IconCircle(this.icon, {super.key, this.size = 40, this.bg = K.accentTint, this.fg = K.accentFill});

  final IconData icon;
  final double size;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, size: size * .5, color: fg),
      );
}

/// Round 44pt icon button used in headers.
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({super.key, required this.icon, required this.onTap, this.bg = K.surface, this.fg = K.ink, this.tooltip});

  final IconData icon;
  final VoidCallback onTap;
  final Color bg;
  final Color fg;
  final String? tooltip;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: tooltip,
        child: Material(
          color: bg,
          shape: CircleBorder(side: bg == K.surface ? const BorderSide(color: K.border) : BorderSide.none),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(width: 44, height: 44, child: Icon(icon, size: 22, color: fg)),
          ),
        ),
      );
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction, this.actionKey});

  final String title;
  final String? action;
  final VoidCallback? onAction;
  final Key? actionKey;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 12),
        child: Row(children: [
          Expanded(child: Text(title, style: K.title)),
          if (action != null)
            TextButton(
              key: actionKey,
              onPressed: onAction,
              style: TextButton.styleFrom(foregroundColor: K.accentFill, minimumSize: const Size(44, 44)),
              child: Text(action!, style: K.label.copyWith(color: K.accentFill, fontWeight: FontWeight.w600)),
            ),
        ]),
      );
}

/// Header for detail screens: back button, optional title and trailing action.
class DetailHeader extends StatelessWidget {
  const DetailHeader({super.key, this.title, this.trailing, this.close = false});

  final String? title;
  final Widget? trailing;
  final bool close;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Row(children: [
          RoundIconButton(
            key: const Key('back'),
            icon: close ? Icons.close_rounded : Icons.arrow_back_rounded,
            tooltip: close ? 'Close' : 'Back',
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 12),
          Expanded(child: title == null ? const SizedBox() : Text(title!, style: K.title, overflow: TextOverflow.ellipsis)),
          ?trailing,
        ]),
      );
}

void simulated(BuildContext context, String what) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text('$what is simulated in this demo'), duration: const Duration(seconds: 2)));
