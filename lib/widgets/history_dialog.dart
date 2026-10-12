// Copyright (c) 2026 Wilhelm San Pedro (https://minristudio.com).
// Licensed under the PolyForm Noncommercial License 1.0.0.
// See LICENSE in the project root for full license terms.

import 'package:flutter/material.dart';
import '../models/session_manager.dart';
import '../theme/app_theme.dart';

class HistoryDialog extends StatelessWidget {
  final SessionManager sessionManager;
  final bool isDark;

  const HistoryDialog({
    super.key,
    required this.sessionManager,
    required this.isDark,
  });

  static void show(
    BuildContext context, {
    required SessionManager sessionManager,
    required bool isDark,
  }) {
    showDialog(
      context: context,
      builder: (_) =>
          HistoryDialog(sessionManager: sessionManager, isDark: isDark),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppTheme.bg(isDark);
    final textPrimary = AppTheme.textPrimary(isDark);
    final textMuted = AppTheme.textMuted(isDark);

    return StatefulBuilder(
      builder: (context, setModalState) {
        final active = sessionManager.activeSession;
        final history = active.history;

        return Dialog(
          backgroundColor: bg,
          insetPadding: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: Container(
            width: 320,
            height: 220,
            padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Editorial Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Attempt History',
                            style: AppTheme.sans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: textPrimary,
                            ),
                          ),
                          Text(
                            '${active.name} • ${history.length} attempts',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: AppTheme.sans(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (history.isNotEmpty)
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            onPressed: () {
                              active.history.clear();
                              sessionManager.saveSessions();
                              setModalState(() {});
                            },
                            child: Text(
                              'Clear',
                              style: AppTheme.sans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: textMuted,
                              ),
                            ),
                          ),
                        const SizedBox(width: 6),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: textMuted,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Attempt List
                if (history.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 28.0,
                      horizontal: 12.0,
                    ),
                    child: Center(
                      child: Text(
                        'No codes attempted for this base yet.',
                        textAlign: TextAlign.center,
                        style: AppTheme.sans(fontSize: 11, color: textMuted),
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: history.length,
                      itemBuilder: (ctx, index) {
                        final record = history[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(
                            vertical: 6.0,
                            horizontal: 10.0,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.controlBg(isDark),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 34,
                                      child: Text(
                                        '#${index + 1}',
                                        style: AppTheme.mono(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w400,
                                          color: textMuted,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      record.code,
                                      style: AppTheme.mono(
                                        fontSize: 13.5,
                                        fontWeight: record.isSolved
                                            ? FontWeight.w500
                                            : FontWeight.w400,
                                        color: record.isSolved
                                            ? AppTheme.statusActive
                                            : textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (record.isSolved)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2,
                                      ),
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.activePillBg(isDark),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        'Solved',
                                        style: AppTheme.sans(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.activePillText(
                                            isDark,
                                          ),
                                        ),
                                      ),
                                    ),
                                  Text(
                                    record.formattedTime,
                                    style: AppTheme.mono(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w400,
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
