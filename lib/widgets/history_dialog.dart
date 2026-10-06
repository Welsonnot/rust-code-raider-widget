// Copyright (c) 2026 Wilhelm San Pedro (https://minristudio.com).
// Licensed under the PolyForm Noncommercial License 1.0.0.
// See LICENSE in the project root for full license terms.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/session_manager.dart';

class HistoryDialog extends StatelessWidget {
  final SessionManager sessionManager;
  final bool isDark;

  const HistoryDialog({
    super.key,
    required this.sessionManager,
    required this.isDark,
  });

  static Future<void> show(
    BuildContext context, {
    required SessionManager sessionManager,
    required bool isDark,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => HistoryDialog(
        sessionManager: sessionManager,
        isDark: isDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF141418) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF111111);
    final textMuted = isDark ? const Color(0xFF7A7A80) : const Color(0xFF8E8E93);
    final border = isDark ? const Color(0xFF26262C) : const Color(0xFFE5E5EA);

    final history = sessionManager.activeSession.history;

    return StatefulBuilder(
      builder: (dialogCtx, setModalState) {
        return Dialog(
          backgroundColor: bg,
          insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: border, width: 1),
          ),
          child: Container(
            width: 300,
            constraints: const BoxConstraints(maxHeight: 196),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Title, Count & Close)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.history_rounded,
                            size: 16,
                            color: Color(0xFF007AFF),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Attempt History',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                                color: textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(Icons.close_rounded, size: 18, color: textMuted),
                      onPressed: () => Navigator.pop(dialogCtx),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${sessionManager.activeSession.name} • ${history.length} attempts',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: textMuted,
                  ),
                ),
                const SizedBox(height: 6),

                // History List
                if (history.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                      child: Text(
                        'No attempts recorded yet.\nPress F8 to log codes.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: textMuted,
                        ),
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: history.length,
                      separatorBuilder: (_, __) => Divider(height: 1, color: border),
                      itemBuilder: (ctx, index) {
                        final record = history[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '#${index + 1}',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 10.5,
                                        color: textMuted,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      record.code,
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: record.isSolved
                                            ? const Color(0xFF34C759)
                                            : textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (record.isSolved) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                      margin: const EdgeInsets.only(right: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0x3334C759),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: const Color(0xFF34C759), width: 0.6),
                                      ),
                                      child: Text(
                                        'SOLVED',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF34C759),
                                        ),
                                      ),
                                    ),
                                  ],
                                  Text(
                                    record.formattedTime,
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 10.5,
                                      color: textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
