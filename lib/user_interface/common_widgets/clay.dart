import 'dart:math';

import 'package:druid_app/user_interface/common_widgets/engraved_icon.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Stile "plastilina" (claymorphism): forme morbide con un riflesso in alto a sinistra, un'ombra diffusa sotto e
/// angoli molto arrotondati. Con una livrea piatta (`DruidTokens.clay == false`) gli stessi widget restano piatti.

Color _lighten(Color c, double amount) => Color.lerp(c, Colors.white, amount)!;

Color _darken(Color c, double amount) => Color.lerp(c, Colors.black, amount)!;

/// Decorazione in plastilina per un rettangolo arrotondato. [concave]: nelle livree neumorfiche la faccia ha una
/// leggera conca (più scura in alto a sinistra, più chiara in basso a destra), come un tasto che accoglie il
/// polpastrello: per i pulsanti colorati, che pieni sembrerebbero piatti.
BoxDecoration clayDecoration(
  BuildContext context, {
  required Color color,
  double? radius,
  bool pressed = false,
  bool concave = false,
}) {
  final tokens = context.druid;
  final r = BorderRadius.circular(radius ?? tokens.cardRadius);
  if (!tokens.clay) {
    return BoxDecoration(
      color: color,
      borderRadius: r,
      border: Border.all(color: context.colors.outlineVariant),
    );
  }
  if (tokens.neu) {
    return _neuDecoration(
      tokens,
      color: color,
      radius: r,
      pressed: pressed,
      concave: concave,
      concaveStrength: _concaveStrength(context),
    );
  }
  return BoxDecoration(
    borderRadius: r,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [_lighten(color, 0.10), color, _darken(color, 0.06)],
      stops: const [0, 0.55, 1],
    ),
    boxShadow: pressed
        ? [BoxShadow(color: tokens.clayShadow, blurRadius: 6, offset: const Offset(0, 2))]
        : [
            BoxShadow(color: tokens.clayShadow, blurRadius: 22, offset: const Offset(0, 10)),
            BoxShadow(
              color: tokens.clayShadow.withValues(alpha: tokens.clayShadow.a * 0.6),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
  );
}

/// Intensità della conca dei pulsanti colorati: di sera più marcata, perché sui colori chiari (pesca) la stessa
/// variazione si vedrebbe appena.
double _concaveStrength(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? 1.8 : 1;

/// Neumorfismo: colore pieno, una luce in alto a sinistra e un'ombra in basso a destra. Premuto, il rilievo quasi
/// sparisce (la superficie torna a filo della pagina).
BoxDecoration _neuDecoration(
  DruidTokens tokens, {
  required Color color,
  BorderRadius? radius,
  bool pressed = false,
  BoxShape shape = BoxShape.rectangle,
  double distance = 7,
  bool concave = false,
  double concaveStrength = 1,
}) {
  final d = pressed ? distance * 0.3 : distance;
  return BoxDecoration(
    color: concave ? null : color,
    gradient: concave
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // Sui colori chiari (pesca) la stessa conca si vedrebbe appena: più chiaro il colore, più scuro l'angolo.
            colors: [
              _darken(color, (0.03 + 0.22 * color.computeLuminance()) * concaveStrength),
              color,
              _lighten(color, 0.08 * concaveStrength),
            ],
          )
        : null,
    shape: shape,
    borderRadius: shape == BoxShape.circle ? null : radius,
    boxShadow: [
      BoxShadow(color: tokens.neuLight, blurRadius: d * 2.2, offset: Offset(-d, -d)),
      BoxShadow(color: tokens.clayShadow, blurRadius: d * 2.2, offset: Offset(d, d)),
    ],
  );
}

/// Riflesso sul bordo superiore: dà l'effetto "gonfio" della plastilina. Sta sotto il contenuto della scheda.
class _ClayHighlight extends StatelessWidget {
  final BorderRadius radius;

  const _ClayHighlight({required this.radius});

  /// Altezza massima del riflesso: sulle schede lunghe (i vassoi dell'erbario) "fino a metà" schiarirebbe tutto ciò
  /// che si vede, slavando il colore.
  static const maxHeight = 64.0;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: LayoutBuilder(
      builder: (context, constraints) => Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          height: min(constraints.maxHeight / 2, maxHeight),
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: radius.topLeft, topRight: radius.topRight),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white.withValues(alpha: 0.28), Colors.white.withValues(alpha: 0)],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Scheda in plastilina.
class ClayCard extends StatelessWidget {
  final Color? color;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? radius;
  final VoidCallback? onTap;

  const ClayCard({
    super.key,
    this.color,
    required this.child,
    this.padding = const EdgeInsets.all(Gaps.l),
    this.radius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius ?? context.druid.cardRadius);
    final content = Stack(
      children: [
        // Il riflesso sta sotto il contenuto: illumina la plastilina, non le foto e i colori appoggiati sopra.
        if (context.druid.clay && !context.druid.neu) Positioned.fill(child: _ClayHighlight(radius: r)),
        Padding(padding: padding, child: child),
      ],
    );
    return DecoratedBox(
      decoration: clayDecoration(context, color: color ?? context.colors.surfaceContainerLow, radius: radius),
      child: ClipRRect(
        borderRadius: r,
        child: onTap == null
            ? content
            : Material(
                type: MaterialType.transparency,
                child: InkWell(onTap: onTap, child: content),
              ),
      ),
    );
  }
}

/// Sfera in plastilina con un'icona (o un'emoji) al centro: per icone di sezione, tratti, livelli.
class ClayCircle extends StatelessWidget {
  final Color color;
  final double size;
  final IconData? icon;
  final String? emoji;
  final Color? iconColor;
  final Widget? child;

  /// Faccia con una leggera conca (vedi [clayDecoration]), per le sfere che fanno da pulsante.
  final bool concave;

  /// Nelle livree neumorfiche una sfera con un'icona perde il suo colore: diventa un cerchio in rilievo del colore
  /// della scheda con l'icona incisa (lo stile dei tratti). `true` tiene il colore, quando il colore è
  /// un'informazione (livello di studio, voce scelta nella barra di navigazione).
  final bool keepColor;

  /// La sfera si preme (pulsante tondo, voce della barra): nelle livree neumorfiche resta in rilievo. Altrimenti è
  /// un'icona da guardare e, per la regola del rilievo ("in rilievo = si può toccare"), è incisa come le pillole dei
  /// tratti: un solco sottile tutt'intorno e dentro l'icona incisa.
  final bool pressable;

  const ClayCircle({
    super.key,
    required this.color,
    this.size = 44,
    this.icon,
    this.emoji,
    this.iconColor,
    this.child,
    this.concave = false,
    this.keepColor = false,
    this.pressable = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.druid;
    if (tokens.neu && icon != null && child == null && emoji == null && !keepColor && !pressable) {
      return GroovedCircle(
        size: size,
        child: EngravedIcon(icon!, size: size * 0.45),
      );
    }
    if (tokens.neu && icon != null && child == null && emoji == null && !keepColor) {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: _neuDecoration(
          tokens,
          color: context.colors.surfaceContainerLow,
          shape: BoxShape.circle,
          distance: (size * 0.09).clamp(2, 6),
          concave: concave,
          concaveStrength: _concaveStrength(context),
        ),
        child: EngravedIcon(icon!, size: size * 0.5),
      );
    }
    final foreground =
        iconColor ??
        (ThemeData.estimateBrightnessForColor(color) == Brightness.dark ? Colors.white : const Color(0xFF2B2118));
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: tokens.neu
          ? _neuDecoration(
              tokens,
              color: color,
              shape: BoxShape.circle,
              distance: (size * 0.09).clamp(2, 6),
              concave: concave,
              concaveStrength: _concaveStrength(context),
            )
          : BoxDecoration(
              shape: BoxShape.circle,
              color: tokens.clay ? null : color,
              gradient: tokens.clay
                  ? RadialGradient(
                      center: const Alignment(-0.35, -0.45),
                      radius: 0.95,
                      colors: [_lighten(color, 0.45), color, _darken(color, 0.18)],
                      stops: const [0, 0.55, 1],
                    )
                  : null,
              boxShadow: tokens.clay
                  ? [BoxShadow(color: tokens.clayShadow, blurRadius: size * 0.35, offset: Offset(0, size * 0.14))]
                  : null,
            ),
      child:
          child ??
          (emoji != null
              ? Text(emoji!, style: TextStyle(fontSize: size * 0.48, height: 1))
              : icon != null
              ? Icon(icon, size: size * 0.5, color: foreground)
              : null),
    );
  }
}

/// Cerchio da guardare, non da premere (livree neumorfiche): come le pillole che non si premono, un solco inciso
/// tutt'intorno e, appena dentro, la superficie che risale di poco; al centro [child] (un'icona o un numero incisi).
class GroovedCircle extends StatelessWidget {
  final double size;
  final Widget child;

  const GroovedCircle({super.key, required this.size, required this.child});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size / 2);
    return SizedBox.square(
      dimension: size,
      child: NeuInset(
        radius: radius,
        depth: 0.8,
        strength: 0.45,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: NeuInset(
            radius: radius,
            depth: 0.8,
            strength: 0.35,
            convex: true,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

/// Il livello di studio di una specie in un cerchio: nelle livree neumorfiche il cerchio è inciso (non si preme) e il
/// numero, inciso anche lui, ha il colore del livello; nelle altre una sfera del colore del livello.
class LevelMark extends StatelessWidget {
  final int level;
  final double size;

  const LevelMark({super.key, required this.level, this.size = 42});

  @override
  Widget build(BuildContext context) {
    final tokens = context.druid;
    final style = context.texts.titleMedium?.copyWith(fontWeight: FontWeight.w700);
    if (!tokens.neu) {
      return ClayCircle(
        color: tokens.levelColor(level),
        size: size,
        child: Text('$level', style: style),
      );
    }
    // I colori dei primi livelli sono chiari: sul segno si scuriscono verso il testo, per leggersi sulla scheda.
    final color = level == 0
        ? context.colors.onSurfaceVariant
        : Color.lerp(tokens.levelColor(level), context.colors.onSurface, 0.35)!;
    return GroovedCircle(
      size: size,
      child: Text(
        '$level',
        style: style?.copyWith(
          color: color,
          shadows: [
            Shadow(color: tokens.clayShadow, offset: const Offset(-0.8, -0.8)),
            Shadow(color: tokens.neuLight, offset: const Offset(0.9, 0.9)),
          ],
        ),
      ),
    );
  }
}

/// Pulsante tondo in plastilina (indietro, taccuino, glossario…): sostituisce le icone delle barre classiche.
class ClayIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final Color? color;

  const ClayIconButton({super.key, required this.icon, required this.onPressed, required this.tooltip, this.color});

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: GestureDetector(
      onTap: onPressed,
      child: ClayCircle(
        color: color ?? context.colors.surfaceContainerLow,
        icon: icon,
        iconColor: context.colors.onSurface,
        size: 44,
        pressable: true,
      ),
    ),
  );
}

/// Pulsante a pillola in plastilina che "si schiaccia" quando lo tocchi.
class ClayButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final Color? foreground;

  const ClayButton({super.key, required this.label, required this.onPressed, this.icon, this.color, this.foreground});

  @override
  State<ClayButton> createState() => _ClayButtonState();
}

class _ClayButtonState extends State<ClayButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final color = widget.color ?? context.colors.primary;
    final fg = widget.foreground ?? context.colors.onPrimary;
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 90),
        child: Opacity(
          opacity: enabled ? 1 : 0.5,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: Gaps.xl, vertical: Gaps.m),
            decoration: clayDecoration(context, color: color, radius: 999, pressed: _pressed, concave: true),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[Icon(widget.icon, size: 18, color: fg), const SizedBox(width: Gaps.s)],
                Flexible(
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: context.texts.labelLarge?.copyWith(color: fg, fontWeight: FontWeight.w600),
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

/// Emoji del tratto se l'etichetta ne inizia con una (es. "🌕 Lunare" → "🌕"), altrimenti `null`.
String? leadingEmoji(String label) {
  if (label.isEmpty) return null;
  final first = label.characters.first;
  return first.runes.first > 0x2000 ? first : null;
}

/// Barra in alto "integrata": nessuno sfondo, il titolo in serif e un pulsante tondo in plastilina per tornare
/// indietro (o chiudere). Sostituisce l'AppBar Material sulle pagine aperte sopra la home.
PreferredSizeWidget clayAppBar(
  BuildContext context, {
  String? title,
  List<Widget> actions = const [],
  IconData leadingIcon = Icons.arrow_back_rounded,
  VoidCallback? onLeading,
  String? leadingTooltip,
  bool overImage = false,
}) => AppBar(
  // Sopra una foto la barra di stato va chiara (la foto ha una velatura scura in alto).
  systemOverlayStyle: overImage ? SystemUiOverlayStyle.light : null,
  backgroundColor: Colors.transparent,
  surfaceTintColor: Colors.transparent,
  elevation: 0,
  scrolledUnderElevation: 0,
  // Sopra una foto la barra è più alta: il pulsante sta alla stessa distanza dal bordo sopra e a sinistra. Nelle
  // livree neumorfiche la foto ha un margine anche in alto, quindi il pulsante scende e rientra un po' di più.
  toolbarHeight: overImage ? (context.druid.neu ? 128 : 84) : 68,
  // Sopra una foto con i margini laterali il pulsante sta dentro la foto, non a cavallo del bordo.
  leadingWidth: overImage ? 68 + Gaps.l + (context.druid.neu ? Gaps.l + Gaps.s : 0) : 68,
  automaticallyImplyLeading: false,
  leading: Padding(
    padding: EdgeInsets.only(left: overImage ? Gaps.l + (context.druid.neu ? Gaps.l + Gaps.s : 0) : 0),
    child: Center(
      child: ClayIconButton(
        key: const ValueKey('clay-back'),
        icon: leadingIcon,
        tooltip: leadingTooltip ?? MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: onLeading ?? () => Navigator.of(context).maybePop(),
      ),
    ),
  ),
  title: title == null ? null : Text(title, style: context.texts.headlineSmall),
  actions: [
    for (final a in actions)
      Padding(
        padding: const EdgeInsets.only(right: Gaps.s),
        child: a,
      ),
    const SizedBox(width: Gaps.s),
  ],
);

/// Intestazione di una pagina principale: titolo grande in serif, sottotitolo e (facoltativa) sfera-icona.
class ClayPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final IconData? icon;
  final Color? iconColor;

  const ClayPageHeader({super.key, required this.title, this.subtitle, this.trailing, this.icon, this.iconColor});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: Gaps.s, bottom: Gaps.l),
    child: Row(
      children: [
        if (icon != null) ...[
          ClayCircle(color: iconColor ?? context.colors.primaryContainer, icon: icon, size: 52),
          const SizedBox(width: Gaps.m),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.texts.headlineMedium),
              if (subtitle != null)
                Text(subtitle!, style: context.texts.bodySmall?.copyWith(color: context.druid.hint)),
            ],
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

/// Titolo di sezione con una piccola sfera-icona davanti.
class ClaySectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? color;
  final Widget? trailing;

  /// Colore del titolo, per i titoli su fondi scuri.
  final Color? titleColor;

  const ClaySectionTitle({
    super.key,
    required this.title,
    required this.icon,
    this.color,
    this.trailing,
    this.titleColor,
  });

  // Sotto il titolo c'è abbastanza spazio perché l'ombra della prima scheda non tocchi il titolo (capitolo 07,
  // "Spazio per il rilievo ovunque").
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: Gaps.l),
    child: Row(
      children: [
        ClayCircle(color: color ?? context.colors.secondaryContainer, icon: icon, size: 36),
        const SizedBox(width: Gaps.m),
        Expanded(
          child: Text(title, style: context.texts.titleLarge?.copyWith(color: titleColor)),
        ),
        ?trailing,
      ],
    ),
  );
}

/// Spazio in fondo alle pagine della home, per non finire sotto la barra di navigazione fluttuante.
const homeBottomInset = 120.0;

/// Barra di navigazione fluttuante in plastilina: una pillola sollevata dal fondo con le voci come sfere.
class ClayNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<(IconData, String)> items;

  const ClayNavBar({super.key, required this.selectedIndex, required this.onSelected, required this.items});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(Gaps.l, 0, Gaps.l, Gaps.m),
      child: Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: Gaps.s),
        decoration: clayDecoration(context, color: colors.surfaceContainerLow, radius: 38),
        child: Row(
          children: [
            for (final (i, (icon, label)) in items.indexed)
              Expanded(
                child: Semantics(
                  selected: i == selectedIndex,
                  button: true,
                  child: InkResponse(
                    onTap: () => onSelected(i),
                    radius: 36,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedScale(
                          scale: i == selectedIndex ? 1 : 0.82,
                          duration: const Duration(milliseconds: 160),
                          child: i == selectedIndex
                              ? ClayCircle(
                                  color: colors.primary,
                                  icon: icon,
                                  iconColor: colors.onPrimary,
                                  size: 40,
                                  concave: true,
                                  // La voce scelta resta colorata: il colore dice dove sei.
                                  keepColor: true,
                                  pressable: true,
                                )
                              // Nelle livree neumorfiche anche le voci non scelte sono bottoni in rilievo.
                              : context.druid.neu
                              ? ClayCircle(
                                  color: colors.surface,
                                  icon: icon,
                                  iconColor: colors.onSurfaceVariant,
                                  size: 40,
                                  pressable: true,
                                )
                              : SizedBox(width: 40, height: 40, child: Icon(icon, color: colors.onSurfaceVariant)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.texts.labelSmall?.copyWith(
                            color: i == selectedIndex ? colors.onSurface : colors.onSurfaceVariant,
                            fontWeight: i == selectedIndex ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Stile in plastilina per i pulsanti Material (usato dal tema delle livree `clay`): pillola con sfumatura, riflesso
/// e ombra morbida che si abbassa quando lo premi. Disattivato, il pulsante si spegne verso il colore della pagina.
ButtonStyle clayButtonStyle({
  required Color color,
  required Color foreground,
  required Color disabled,
  bool concave = false,
}) => ButtonStyle(
  backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
  foregroundColor: WidgetStateProperty.resolveWith(
    (states) => states.contains(WidgetState.disabled) ? foreground.withValues(alpha: 0.45) : foreground,
  ),
  overlayColor: WidgetStatePropertyAll(foreground.withValues(alpha: 0.08)),
  elevation: const WidgetStatePropertyAll(0),
  side: const WidgetStatePropertyAll(BorderSide.none),
  shape: const WidgetStatePropertyAll(StadiumBorder()),
  padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 22, vertical: 14)),
  backgroundBuilder: (context, states, child) => AnimatedContainer(
    duration: const Duration(milliseconds: 90),
    decoration: clayDecoration(
      context,
      color: states.contains(WidgetState.disabled) ? disabled : color,
      radius: 999,
      pressed: states.contains(WidgetState.pressed) || states.contains(WidgetState.disabled),
      concave: concave && !states.contains(WidgetState.disabled),
    ),
    child: child,
  ),
);

/// Superficie "scavata" (neumorfismo incassato): un'ombra scura lungo il bordo in alto a sinistra e una luce lungo
/// quello in basso a destra, all'interno della forma. Flutter non ha ombre interne: si disegnano qui.
class NeuInset extends StatelessWidget {
  final Widget child;
  final BorderRadius radius;
  final Color? color;
  final double depth;

  /// Intensità di luce e ombra (1 = quelle della livrea).
  final double strength;

  /// Intensità della sola luce, se diversa da [strength] (su fondi chiari e traslucidi una luce piena sembra un
  /// riflesso di vetro).
  final double? lightStrength;

  /// `true`: l'incavo si disegna sopra il figlio (per una foto "sul fondo" dell'incavo), non sotto.
  final bool overChild;

  /// Colori di ombra e luce al posto di quelli della livrea, per incavi su un fondo diverso dalla pagina (l'ombra
  /// della livrea chiara è un beige: su un fondo scuro sembrerebbe una luce).
  final Color? darkColor;
  final Color? lightColor;

  /// `true`: luce e ombra invertite, la superficie sembra bombata verso l'alto (una smussatura in rilievo) invece che
  /// scavata. Non riempie la forma: funziona su qualunque fondo.
  final bool convex;

  /// Larghezza della sfumatura dell'ombra interna per una data profondità: il margine da lasciare libero lungo il
  /// bordo perché l'incavo si veda intero.
  static double spread(double depth) => depth + depth * 1.2 * 2;

  const NeuInset({
    super.key,
    required this.child,
    required this.radius,
    this.color,
    this.depth = 3,
    this.strength = 1,
    this.lightStrength,
    this.overChild = false,
    this.convex = false,
    this.darkColor,
    this.lightColor,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.druid;
    final painter = _InsetPainter(
      radius: radius,
      fill: overChild ? null : color,
      dark: (darkColor ?? tokens.clayShadow).withValues(
        alpha: ((darkColor ?? tokens.clayShadow).a * strength).clamp(0, 1),
      ),
      light: (lightColor ?? tokens.neuLight).withValues(
        alpha: ((lightColor ?? tokens.neuLight).a * (lightStrength ?? strength)).clamp(0, 1),
      ),
      depth: depth,
      convex: convex,
    );
    return overChild
        ? CustomPaint(foregroundPainter: painter, child: child)
        : CustomPaint(painter: painter, child: child);
  }
}

class _InsetPainter extends CustomPainter {
  final BorderRadius radius;
  final Color? fill;
  final Color dark;
  final Color light;
  final double depth;
  final bool convex;

  const _InsetPainter({
    required this.radius,
    required this.fill,
    required this.dark,
    required this.light,
    required this.depth,
    this.convex = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || !size.isFinite) return;
    final rrect = radius.toRRect(Offset.zero & size);
    canvas.save();
    canvas.clipRRect(rrect);
    if (fill != null) canvas.drawRRect(rrect, Paint()..color = fill!);
    // Un anello attorno alla forma, spostato e sfocato: la parte che cade dentro la forma è l'ombra interna.
    final ring = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect((Offset.zero & size).inflate(depth * 6))
      ..addRRect(rrect);
    final blur = MaskFilter.blur(BlurStyle.normal, depth * 1.2);
    // Scavato: ombra lungo il bordo in alto a sinistra, luce in basso a destra. Bombato: il contrario.
    final topLeft = convex ? light : dark;
    final bottomRight = convex ? dark : light;
    canvas.drawPath(
      ring.shift(Offset(depth, depth)),
      Paint()
        ..color = topLeft
        ..maskFilter = blur,
    );
    canvas.drawPath(
      ring.shift(Offset(-depth, -depth)),
      Paint()
        ..color = bottomRight
        ..maskFilter = blur,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_InsetPainter old) =>
      old.radius != radius ||
      old.fill != fill ||
      old.dark != dark ||
      old.light != light ||
      old.depth != depth ||
      old.convex != convex;
}

/// Chip di scelta. Nelle livree neumorfiche: in rilievo se non scelta, scavata (premuta) se scelta, con testo e icona
/// del colore delle azioni. Altrimenti una `ChoiceChip` (o, senza [selected], una `ActionChip`) Material.
class ClayChip extends StatelessWidget {
  final String label;
  final Widget? avatar;

  /// `null`: chip d'azione (si tocca, non resta scelta).
  final bool? selected;
  final VoidCallback? onTap;

  const ClayChip({super.key, required this.label, this.avatar, this.selected, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Un'etichetta che comincia con l'emoji di un tratto ("❄️ Gelo"): nelle livree neumorfiche l'emoji diventa l'icona
    // incisa, come nelle pillole.
    final emoji = leadingEmoji(label);
    final traitIcon = emoji == null ? null : traitIconOf(emoji);
    if (context.druid.neu && traitIcon != null) {
      return ClayChip(
        key: key,
        label: label.substring(emoji!.length).trim(),
        avatar: EngravedIcon(traitIcon, size: 18),
        selected: selected,
        onTap: onTap,
      );
    }
    if (!context.druid.neu) {
      return selected == null
          ? ActionChip(avatar: avatar, label: Text(label), onPressed: onTap)
          : ChoiceChip(
              avatar: avatar,
              label: Text(label),
              selected: selected!,
              onSelected: onTap == null ? null : (_) => onTap!(),
            );
    }
    final colors = context.colors;
    final on = selected ?? false;
    final foreground = on ? colors.primary : colors.onSurface;
    final content = Padding(
      padding: EdgeInsets.fromLTRB(avatar == null ? Gaps.m : Gaps.s, Gaps.s, Gaps.m, Gaps.s),
      child: IconTheme.merge(
        data: IconThemeData(color: foreground, size: 18),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (avatar != null) ...[avatar!, const SizedBox(width: Gaps.s)],
            Text(
              label,
              style: context.texts.labelLarge?.copyWith(color: foreground, fontWeight: on ? FontWeight.w700 : null),
            ),
          ],
        ),
      ),
    );
    const radius = BorderRadius.all(Radius.circular(999));
    return Semantics(
      button: true,
      selected: on,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: on
            ? NeuInset(radius: radius, child: content)
            : DecoratedBox(
                decoration: clayDecoration(context, color: colors.surface, radius: 999),
                child: content,
              ),
      ),
    );
  }
}

/// Icona in un incavo tondo (neumorfismo scavato); fuori dalle livree neumorfiche, una [ClayCircle].
class ClayInsetIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;

  const ClayInsetIcon({super.key, required this.icon, this.size = 40, this.color});

  @override
  Widget build(BuildContext context) {
    if (!context.druid.neu) {
      return ClayCircle(color: color ?? context.colors.secondaryContainer, icon: icon, size: size);
    }
    return SizedBox.square(
      dimension: size,
      child: NeuInset(
        radius: BorderRadius.circular(size / 2),
        child: Icon(icon, size: size * 0.5, color: context.colors.onSurfaceVariant),
      ),
    );
  }
}

/// Interruttore on/off. Nelle livree neumorfiche: un binario a chip scavato con dentro una sfera in rilievo, color
/// pagina da spento e del colore delle azioni (con la leggera conca dei pulsanti) da acceso. Altrimenti uno `Switch`
/// adattivo Material/Cupertino.
class ClaySwitch extends StatelessWidget {
  static const _width = 58.0, _height = 32.0, _knob = 24.0;

  final bool value;
  final ValueChanged<bool>? onChanged;

  const ClaySwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final tokens = context.druid;
    if (!tokens.neu) return Switch.adaptive(value: value, onChanged: onChanged);
    final colors = context.colors;
    const inset = (_height - _knob) / 2;
    return Semantics(
      toggled: value,
      enabled: onChanged != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: SizedBox(
          width: _width,
          height: _height,
          child: NeuInset(
            radius: const BorderRadius.all(Radius.circular(_height / 2)),
            depth: 2,
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(inset),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: _knob,
                  height: _knob,
                  // La sfera ha sempre la conca "per il polpastrello", più marcata che sui pulsanti grandi perché è
                  // piccola. Di sera il colore acceso è smorzato: pieno, sul binario scuro, abbaglierebbe.
                  decoration: _neuDecoration(
                    tokens,
                    color: value
                        ? (Theme.of(context).brightness == Brightness.dark
                              ? Color.lerp(colors.primary, colors.surface, 0.3)!
                              : colors.primary)
                        : colors.surface,
                    shape: BoxShape.circle,
                    distance: 2.5,
                    concave: true,
                    concaveStrength: 1.8,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Barra di avanzamento. Nelle livree neumorfiche: un binario sottile scavato in cui la parte piena è una chip
/// appena bombata, così il vuoto si vede scavato e il pieno in rilievo (a barra completa sembra una chip). Rilievo e
/// incavo sono leggerissimi, la barra resta sottile. Altrove una `LinearProgressIndicator`.
class ClayProgressBar extends StatelessWidget {
  final double value;
  final double height;

  /// Colore della parte piena (`null`: quello delle azioni).
  final Color? color;

  /// Colore del binario fuori dal neumorfismo.
  final Color? trackColor;

  /// Colore del fondo su cui la barra è appoggiata, se non è la pagina (es. la scheda verde del titolo): l'incavo
  /// ricava ombra e luce da qui, invece che dai colori della livrea pensati per la pagina.
  final Color? surface;

  const ClayProgressBar({super.key, required this.value, this.height = 6, this.color, this.trackColor, this.surface});

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    final radius = BorderRadius.circular(height);
    if (!context.druid.neu) {
      return LinearProgressIndicator(
        value: v,
        minHeight: height,
        color: color,
        backgroundColor: trackColor,
        borderRadius: radius,
      );
    }
    final trackHeight = height + 2;
    // Luce e ombra ricavate dai colori reali: del fondo per l'incavo, della parte piena per il suo rilievo.
    final bg = surface;
    final fill = color ?? context.colors.primary;
    return Semantics(
      value: '${(v * 100).round()}%',
      child: SizedBox(
        height: trackHeight,
        child: NeuInset(
          radius: BorderRadius.circular(trackHeight),
          depth: 1,
          strength: 0.6,
          darkColor: bg == null ? null : _darken(bg, 0.45),
          lightColor: bg == null ? null : _lighten(bg, 0.25),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: v,
              heightFactor: 1,
              child: v == 0
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.all(1),
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: fill, borderRadius: radius),
                        child: NeuInset(
                          radius: radius,
                          depth: 0.8,
                          strength: 0.5,
                          darkColor: _darken(fill, 0.35),
                          lightColor: _lighten(fill, 0.6),
                          convex: true,
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
