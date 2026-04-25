// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'local_db.dart';
import 'log_entry.dart';

// ─────────────────────────────────────────────────────────────────
//  HistoryScreen  –  "Apothecary Logbook  /  Log Register"
//
//  Same palette & typography as HomeScreen:
//    Linen      #EEE8DC   bg
//    Walnut     #1C1510   primary ink
//    Dust       #8C7B68   muted
//    Rule       #C9BFA8   dividers
//    Terracotta #B85C38   synced accent
//
//  Layout:
//    • Top bar: ← BACK  /  title  /  italic total count
//    • Entries grouped by MONTH  (Playfair Display italic header)
//    • Each row: left gutter = large italic day number + day name
//                body       = time  +  SYNCED / LOCAL badge
//    • Staggered fade-up on first paint
// ─────────────────────────────────────────────────────────────────

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {

  // ── Palette ────────────────────────────────────────────────────
  static const Color _linen      = Color(0xFFEEE8DC);
  static const Color _walnut     = Color(0xFF1C1510);
  static const Color _dust       = Color(0xFF8C7B68);
  static const Color _rule       = Color(0xFFC9BFA8);
  static const Color _terracotta = Color(0xFFB85C38);

  // ── Data ───────────────────────────────────────────────────────
  late List<LogEntry> _logs;

  // ── Animation ─────────────────────────────────────────────────
  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();

    _logs = LocalDB.getAll()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── Group by calendar month ────────────────────────────────────
  List<_MonthGroup> _grouped() {
    final Map<String, List<LogEntry>> map = {};
    final List<String> order = [];

    for (final e in _logs) {
      final key = '${e.timestamp.year}-${e.timestamp.month.toString().padLeft(2, '0')}';
      if (!map.containsKey(key)) {
        map[key] = [];
        order.add(key);
      }
      map[key]!.add(e);
    }

    return order.map((k) => _MonthGroup(
      key: k,
      entries: map[k]!,
      sample: map[k]!.first.timestamp,
    )).toList();
  }

  // ── Format helpers ─────────────────────────────────────────────
  String _pad(int v) => v.toString().padLeft(2, '0');

  String _monthName(DateTime dt) {
    const names = ['January','February','March','April','May','June',
                   'July','August','September','October','November','December'];
    return '${names[dt.month - 1]} ${dt.year}';
  }

  String _dayAbbr(DateTime dt) {
    const d = ['MON','TUE','WED','THU','FRI','SAT','SUN'];
    return d[dt.weekday - 1];
  }

  String _time12(DateTime dt) {
    final h  = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m  = _pad(dt.minute);
    return '$h:$m';
  }

  String _ampm(DateTime dt) => dt.hour < 12 ? 'AM' : 'PM';

  // ── Build ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFEEE8DC),
    ));

    final groups = _grouped();

    return Scaffold(
      backgroundColor: _linen,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: _logs.isEmpty
                    ? _buildEmpty()
                    : _buildList(groups),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Top bar ──────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 14),
      decoration: BoxDecoration(
        color: _linen,
        border: Border(bottom: BorderSide(color: _rule, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ← Back + title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back tap
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back_ios, size: 11, color: _dust),
                      const SizedBox(width: 4),
                      Text(
                        'BACK',
                        style: GoogleFonts.ibmPlexMono(
                          color: _dust, fontSize: 8, letterSpacing: 1.6),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'LOG REGISTER',
                  style: GoogleFonts.ibmPlexMono(
                    color: _walnut,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ALL ENTRIES',
                  style: GoogleFonts.ibmPlexMono(
                    color: _dust, fontSize: 8, letterSpacing: 2.0),
                ),
              ],
            ),
          ),

          // Total count
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_logs.length}',
                style: GoogleFonts.playfairDisplay(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w700,
                  fontSize: 34,
                  color: _walnut,
                  height: 1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'TOTAL RECORDS',
                style: GoogleFonts.ibmPlexMono(
                  color: _dust, fontSize: 7.5, letterSpacing: 1.6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Empty state ──────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Empty.',
            style: GoogleFonts.playfairDisplay(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w700,
              fontSize: 56,
              color: _walnut.withOpacity(0.08),
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'NO ENTRIES YET',
            style: GoogleFonts.ibmPlexMono(
              color: _dust, fontSize: 9, letterSpacing: 2.4),
          ),
        ],
      ),
    );
  }

  // ── Scrollable list ──────────────────────────────────────────────
  Widget _buildList(List<_MonthGroup> groups) {
    // Build a flat list of widgets with staggered animation delays
    final widgets = <Widget>[];
    int delay = 0;

    for (final group in groups) {
      widgets.add(_buildMonthHeader(group, delay));
      delay += 60;
      for (final entry in group.entries) {
        widgets.add(_buildEntryRow(entry, delay));
        delay += 35;
      }
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: widgets,
    );
  }

  // ── Month header ─────────────────────────────────────────────────
  Widget _buildMonthHeader(_MonthGroup group, int delayMs) {
    final count = group.entries.length;
    return _DelayedFadeUp(
      delay: Duration(milliseconds: delayMs),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: _rule, width: 1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              _monthName(group.sample),
              style: GoogleFonts.playfairDisplay(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: _walnut,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '$count ENTR${count == 1 ? 'Y' : 'IES'}',
              style: GoogleFonts.ibmPlexMono(
                color: _dust, fontSize: 8, letterSpacing: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  // ── Entry row ────────────────────────────────────────────────────
  Widget _buildEntryRow(LogEntry entry, int delayMs) {
    final isSynced = entry.isSynced;

    return _DelayedFadeUp(
      delay: Duration(milliseconds: delayMs),
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: _rule, width: 1)),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Left gutter: day number + abbr ────────────────
              Container(
                width: 52,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: _rule, width: 1)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${entry.timestamp.day}',
                      style: GoogleFonts.playfairDisplay(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w700,
                        fontSize: 26,
                        color: _walnut,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _dayAbbr(entry.timestamp),
                      style: GoogleFonts.ibmPlexMono(
                        color: _dust, fontSize: 7, letterSpacing: 1.8),
                    ),
                  ],
                ),
              ),

              // ── Body: time + sync badge ────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Time block
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _time12(entry.timestamp),
                            style: GoogleFonts.ibmPlexMono(
                              color: _walnut,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _ampm(entry.timestamp),
                            style: GoogleFonts.ibmPlexMono(
                              color: _dust, fontSize: 8.5, letterSpacing: 1.4),
                          ),
                        ],
                      ),

                      // Sync badge
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSynced ? _terracotta : Colors.transparent,
                              border: isSynced
                                  ? null
                                  : Border.all(color: _dust, width: 1),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isSynced ? 'SYNCED' : 'LOCAL',
                            style: GoogleFonts.ibmPlexMono(
                              color: isSynced ? _terracotta : _dust,
                              fontSize: 7.5,
                              letterSpacing: 1.4,
                              fontWeight: isSynced
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Helper: staggered fade-up for list items
// ─────────────────────────────────────────────────────────────────
class _DelayedFadeUp extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const _DelayedFadeUp({required this.child, required this.delay});

  @override
  State<_DelayedFadeUp> createState() => _DelayedFadeUpState();
}

class _DelayedFadeUpState extends State<_DelayedFadeUp>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _fade,
        child: SlideTransition(position: _slide, child: widget.child),
      );
}

// ─────────────────────────────────────────────────────────────────
//  Data model helper
// ─────────────────────────────────────────────────────────────────
class _MonthGroup {
  final String key;
  final List<LogEntry> entries;
  final DateTime sample;
  const _MonthGroup(
      {required this.key, required this.entries, required this.sample});
}