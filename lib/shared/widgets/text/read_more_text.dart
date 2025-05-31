import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

enum ParseType { url, email }

const defaultParseTypes = [ParseType.url, ParseType.email];

class AppReadMoreText extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle? normalStyle;
  final TextStyle? linkStyle;
  final TextStyle? readMoreStyle;
  final TextStyle? readLessStyle;
  final String? readMoreText;
  final String? readLessText;
  final Duration animationDuration;
  final bool showReadMore;
  final bool showReadLess;
  final List<ParseType> parseTypes;
  final void Function(String text, ParseType type)? onTap;

  const AppReadMoreText({
    super.key,
    required this.text,
    this.maxLines = 3,
    this.normalStyle,
    this.linkStyle,
    this.animationDuration = const Duration(milliseconds: 300),
    this.readMoreStyle,
    this.readLessStyle,
    this.readMoreText,
    this.readLessText,
    this.showReadMore = true,
    this.showReadLess = true,
    this.parseTypes = defaultParseTypes,
    this.onTap,
  });

  @override
  State<AppReadMoreText> createState() => _AppReadMoreTextState();
}

class _AppReadMoreTextState extends State<AppReadMoreText>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  List<TextSpan>? _cachedTextSpans;
  String? _cachedText;

  static final _emailPattern = RegExp(
    r'[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+',
    caseSensitive: false,
  );

  static final _combinedPattern = RegExp(
    r'((https?:\/\/)?' // optional http(s)
    r'((localhost)|' // match localhost
    r'(\d{1,3}(\.\d{1,3}){3})|' // match IP address
    r'(([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}))' // match domain
    r'(:\d+)?(\/\S*)?)' // optional port and path
    r'|([a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+)', // email
    caseSensitive: false,
  );

  void _toggleExpand() => setState(() => _expanded = !_expanded);

  @override
  void didUpdateWidget(covariant AppReadMoreText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.parseTypes != widget.parseTypes) {
      _cachedTextSpans = null;
      _cachedText = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = DefaultTextStyle.of(context).style.merge(widget.normalStyle);
    final linkStyle = widget.linkStyle ??
        theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.primary,
          decoration: TextDecoration.underline,
        ) ??
        const TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        );

    final readMoreText = widget.readMoreText ?? ' Read more';
    final readLessText = widget.readLessText ?? ' Read less';

    return LayoutBuilder(
      builder: (context, constraints) {
        if (_expanded) {
          return _buildExpandedText(defaultStyle, linkStyle, readLessText);
        }

        return _buildCollapsedText(
            context,
            constraints,
            defaultStyle,
            linkStyle,
            readMoreText
        );
      },
    );
  }

  Widget _buildExpandedText(
      TextStyle defaultStyle,
      TextStyle linkStyle,
      String readLessText
      ) {
    return AnimatedSize(
      duration: widget.animationDuration,
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: RichText(
        text: TextSpan(
          style: defaultStyle,
          children: [
            ..._getTextSpans(widget.text, defaultStyle, linkStyle),
            if (widget.showReadLess)
              _buildReadLessSpan(readLessText, linkStyle),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsedText(
      BuildContext context,
      BoxConstraints constraints,
      TextStyle defaultStyle,
      TextStyle linkStyle,
      String readMoreText,
      ) {
    final cutoff = _findOptimalCutoff(
        constraints.maxWidth,
        defaultStyle,
        linkStyle,
        readMoreText
    );

    final truncatedText = widget.text.substring(0, cutoff);
    final spans = <TextSpan>[
      ..._getTextSpans(truncatedText, defaultStyle, linkStyle),
      TextSpan(text: '…', style: defaultStyle),
      if (widget.showReadMore)
        _buildReadMoreSpan(readMoreText, linkStyle),
    ];

    return AnimatedSize(
      duration: widget.animationDuration,
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: RichText(
        text: TextSpan(children: spans, style: defaultStyle),
        maxLines: widget.maxLines,
        overflow: TextOverflow.clip,
      ),
    );
  }

  TextSpan _buildReadMoreSpan(String readMoreText, TextStyle linkStyle) {
    return TextSpan(
      text: readMoreText,
      style: widget.readMoreStyle ??
          linkStyle.copyWith(fontWeight: FontWeight.bold),
      recognizer: TapGestureRecognizer()..onTap = _toggleExpand,
    );
  }

  TextSpan _buildReadLessSpan(String readLessText, TextStyle linkStyle) {
    return TextSpan(
      text: readLessText,
      style: widget.readLessStyle ??
          linkStyle.copyWith(fontWeight: FontWeight.bold),
      recognizer: TapGestureRecognizer()..onTap = _toggleExpand,
    );
  }

  // Optimized binary search with caching
  int _findOptimalCutoff(
      double maxWidth,
      TextStyle defaultStyle,
      TextStyle linkStyle,
      String readMoreText
      ) {
    int min = 0;
    int max = widget.text.length;
    int cutoff = max;
    const ellipsis = '…';

    while (min <= max) {
      final mid = min + ((max - min) >> 1);
      final testText = widget.text.substring(0, mid) + ellipsis + readMoreText;

      if (_textFitsInMaxLines(testText, maxWidth, defaultStyle, linkStyle)) {
        cutoff = mid;
        min = mid + 1;
      } else {
        max = mid - 1;
      }
    }

    return cutoff;
  }

  // Declare once and reuse across frames/searches
  final TextPainter _textPainter = TextPainter(
    textDirection: TextDirection.ltr,
    ellipsis: '…',
  );

  bool _textFitsInMaxLines(
      String text,
      double maxWidth,
      TextStyle defaultStyle,
      TextStyle linkStyle,
      ) {
    // Use cached spans if available
    final testSpans = _getTextSpans(text, defaultStyle, linkStyle);

    // Reuse the same TextPainter to avoid reallocation
    _textPainter
      ..text = TextSpan(children: testSpans)
      ..maxLines = widget.maxLines;

    _textPainter.layout(maxWidth: maxWidth);

    return !_textPainter.didExceedMaxLines;
  }


  // Cached text spans generation
  List<TextSpan> _getTextSpans(
      String text,
      TextStyle normalStyle,
      TextStyle linkStyle,
      ) {
    // Use cache for full text to avoid regeneration
    if (text == widget.text && _cachedTextSpans != null && _cachedText == text) {
      return _cachedTextSpans!;
    }

    final spans = _buildTextSpans(text, normalStyle, linkStyle);

    // Cache only for full text
    if (text == widget.text) {
      _cachedTextSpans = spans;
      _cachedText = text;
    }

    return spans;
  }

  List<TextSpan> _buildTextSpans(
      String text,
      TextStyle normalStyle,
      TextStyle linkStyle,
      ) {
    final spans = <TextSpan>[];
    int currentIndex = 0;

    final matches = _combinedPattern.allMatches(text);

    for (final match in matches) {
      // Add normal text before match
      if (match.start > currentIndex) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, match.start),
          style: normalStyle,
        ));
      }

      final matchedText = match.group(0)!;
      final type = _classifyParseType(matchedText);

      if (widget.parseTypes.contains(type)) {
        spans.add(TextSpan(
          text: matchedText,
          style: linkStyle,
          recognizer: TapGestureRecognizer()
            ..onTap = () => _handleTap(matchedText, type),
        ));
      } else {
        spans.add(TextSpan(text: matchedText, style: normalStyle));
      }

      currentIndex = match.end;
    }

    // Add remaining text
    if (currentIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex),
        style: normalStyle,
      ));
    }

    return spans;
  }

  ParseType _classifyParseType(String text) {
    if (_emailPattern.hasMatch(text)) return ParseType.email;
    return ParseType.url;
  }

  void _handleTap(String text, ParseType type) {
    widget.onTap?.call(text, type);
  }
}

// Extension for better URL handling
extension UrlHelper on String {
  String get normalizedUrl {
    if (startsWith(RegExp(r'https?://'))) return this;
    return 'http://$this';
  }
}
