import 'package:flutter/material.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/theme_context.dart';

/// Единые управляющие элементы приложения (§3.4).
///
/// До этого каждый экран собирал поле поиска, выпадающий список и переключатель
/// режимов вручную — высоты, радиусы и цвета расходились. Здесь единственная
/// реализация каждого элемента; экраны только передают данные.

/// Поле поиска с иконкой и кнопкой очистки.
class AppSearchField extends StatefulWidget {
  const AppSearchField({
    super.key,
    required this.hint,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.height = AppDimens.searchFieldHeight,
  });

  final String hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final double height;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  TextEditingController? _own;
  TextEditingController get _controller =>
      widget.controller ?? (_own ??= TextEditingController());

  FocusNode? _ownFocus;
  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_redraw);
    // Рамка и значок подсвечиваются, пока в поле стоит курсор, — значит, на
    // изменение фокуса тоже надо перерисовываться.
    _focus.addListener(_redraw);
  }

  @override
  void dispose() {
    _controller.removeListener(_redraw);
    _focus.removeListener(_redraw);
    _own?.dispose();
    _ownFocus?.dispose();
    super.dispose();
  }

  void _redraw() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasText = _controller.text.isNotEmpty;
    final focused = _focus.hasFocus;

    // Поле — сплошной прямоугольник с заметной заливкой, а не тонкая рамка:
    // в тёмной теме «таблетка» с одним контуром сливалась с фоном и читалась
    // как незаконченный элемент. Тон заливки строим от текста — он одинаково
    // виден на светлой и тёмной теме.
    final fill = c.textMuted.withValues(alpha: focused ? 0.16 : 0.10);
    final borderColor = focused
        ? c.accentPrimary
        : c.textMuted.withValues(alpha: 0.30);

    return SizedBox(
      height: widget.height,
      child: TextField(
        controller: _controller,
        focusNode: _focus,
        autofocus: widget.autofocus,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        textInputAction: TextInputAction.search,
        style: context.text.bodyMedium,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: context.text.bodyMedium?.copyWith(color: c.textMuted),
          isCollapsed: true,
          filled: true,
          fillColor: fill,
          // Значок вплотную к тексту: большой отступ слева делал поле «дырявым».
          prefixIcon: Padding(
            padding: const EdgeInsets.only(
              left: AppDimens.space16,
              right: AppDimens.space8,
            ),
            child: Icon(
              Icons.search_rounded,
              size: 22,
              color: focused ? c.accentPrimary : c.textSecondary,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          suffixIcon: hasText
              ? IconButton(
                  iconSize: 20,
                  tooltip: AppLocalizations.of(context).searchClear,
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged?.call('');
                  },
                  icon: Icon(Icons.close_rounded, color: c.textSecondary),
                )
              : null,
          // Центрируем текст по высоте поля.
          contentPadding: const EdgeInsets.symmetric(
            vertical: AppDimens.space16,
          ),
          border: _outline(borderColor, width: focused ? 1.6 : 1),
          enabledBorder: _outline(borderColor, width: 1),
          focusedBorder: _outline(c.accentPrimary, width: 1.6),
        ),
      ),
    );
  }

  OutlineInputBorder _outline(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: AppDimens.brMd,
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

/// Выпадающий список в оболочке-таблетке. Метка показывается перед значением,
/// чтобы список читался без раскрытия.
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.icon,
    this.showLabel = true,
    this.active = false,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final IconData? icon;
  final bool showLabel;

  /// Значение отличается от «все» — фильтр включён.
  ///
  /// Включённый фильтр подсвечивается: иначе четыре одинаковые серые таблетки
  /// не дают понять, что список сужен.
  final bool active;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tint = active ? c.accentPrimary : c.textMuted;
    return Container(
      height: AppDimens.controlHeightSm,
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.space12),
      decoration: BoxDecoration(
        color: active ? c.accentSoft : c.surfaceMuted,
        borderRadius: AppDimens.brPill,
        border: Border.all(color: active ? c.accentPrimary : c.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: tint),
            const SizedBox(width: AppDimens.space8),
          ],
          if (showLabel) ...[
            Text(label, style: context.text.labelSmall?.copyWith(color: tint)),
            const SizedBox(width: AppDimens.space8),
          ],
          DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              isDense: true,
              borderRadius: AppDimens.brMd,
              style: context.text.labelMedium?.copyWith(
                color: c.textPrimary,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
              dropdownColor: c.surface,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: active ? c.accentPrimary : c.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Один сегмент переключателя.
class SegmentData<T> {
  const SegmentData({
    required this.value,
    required this.icon,
    required this.tooltip,
    this.label,
  });

  final T value;
  final IconData icon;
  final String tooltip;
  final String? label;
}

/// Сегментированный переключатель: режимы каталога, выбор темы и т. п.
class SegmentedToggle<T> extends StatelessWidget {
  const SegmentedToggle({
    super.key,
    required this.value,
    required this.segments,
    required this.onChanged,
    this.expand = false,
  });

  final T value;
  final List<SegmentData<T>> segments;
  final ValueChanged<T> onChanged;

  /// Растягивать сегменты на всю доступную ширину (боковая панель).
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    // Expanded должен оставаться прямым потомком Row, поэтому Tooltip
    // навешивается внутри, а не снаружи сегмента.
    Widget segment(SegmentData<T> s) {
      final active = s.value == value;
      final child = Material(
        color: active ? c.surface : Colors.transparent,
        borderRadius: AppDimens.brSm,
        child: InkWell(
          borderRadius: AppDimens.brSm,
          onTap: () => onChanged(s.value),
          child: SizedBox(
            height: AppDimens.controlHeightSm - 6,
            width: expand ? null : (s.label == null ? 40 : null),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: s.label == null ? 0 : AppDimens.space12,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    s.icon,
                    size: 18,
                    color: active ? c.navActiveFg : c.textMuted,
                  ),
                  if (s.label != null) ...[
                    const SizedBox(width: AppDimens.space8),
                    Text(
                      s.label!,
                      style: context.text.labelMedium?.copyWith(
                        color: active ? c.textPrimary : c.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
      final tipped = Tooltip(message: s.tooltip, child: child);
      return expand ? Expanded(child: tipped) : tipped;
    }

    return Container(
      height: AppDimens.controlHeightSm,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: c.surfaceMuted,
        borderRadius: AppDimens.brMd,
        border: Border.all(color: c.border),
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: [for (final s in segments) segment(s)],
      ),
    );
  }
}

/// Круглая кнопка-действие в шапке. В отличие от прежней декоративной версии
/// всегда кликабельна и может показывать счётчик.
class IconActionButton extends StatelessWidget {
  const IconActionButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.badgeCount = 0,
    this.size = AppDimens.controlHeight,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final int badgeCount;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: c.surface,
        shape: CircleBorder(side: BorderSide(color: c.border)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, size: 20, color: c.textSecondary),
                if (badgeCount > 0)
                  Positioned(
                    top: 8,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      constraints: const BoxConstraints(minWidth: 16),
                      height: 16,
                      decoration: BoxDecoration(
                        color: c.accentPrimary,
                        borderRadius: AppDimens.brPill,
                        border: Border.all(color: c.surface, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          badgeCount > 99 ? '99+' : '$badgeCount',
                          style: context.text.labelSmall?.copyWith(
                            color: c.accentPrimaryOn,
                            fontSize: 9,
                            height: 1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
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

/// Небольшая кнопка-иконка внутри карточек и строк списка. Единый размер,
/// вместо разнокалиберных [IconButton] с ручными constraints.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.danger = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        borderRadius: AppDimens.brSm,
        child: InkWell(
          borderRadius: AppDimens.brSm,
          onTap: onPressed,
          child: SizedBox(
            width: 34,
            height: 34,
            child: Icon(
              icon,
              size: 18,
              color: danger ? c.coral : c.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
