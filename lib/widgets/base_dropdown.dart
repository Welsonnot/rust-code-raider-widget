// Copyright (c) 2026 Wilhelm San Pedro (https://minristudio.com).
// Licensed under the PolyForm Noncommercial License 1.0.0.
// See LICENSE in the project root for full license terms.

import 'package:flutter/material.dart';
import '../models/base_session.dart';
import '../models/session_manager.dart';
import '../theme/app_theme.dart';
import 'settings_dialog.dart';

class BaseDropdown extends StatelessWidget {
  final SessionManager sessionManager;
  final bool isDark;

  const BaseDropdown({
    super.key,
    required this.sessionManager,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final active = sessionManager.activeSession;
    final textPrimary = AppTheme.textPrimary(isDark);
    final textMuted = AppTheme.textMuted(isDark);

    return GestureDetector(
      onSecondaryTapDown: (details) =>
          _showQuickContextMenu(context, details.globalPosition),
      child: InkWell(
        onTap: () => _showSessionSheet(context),
        onLongPress: () => _showRenameDialog(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  active.name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: AppTheme.sans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.25,
                    color: textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 14,
                color: textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showQuickContextMenu(
    BuildContext context,
    Offset globalPosition,
  ) async {
    final bg = AppTheme.surface(isDark);
    final textPrimary = AppTheme.textPrimary(isDark);
    final border = AppTheme.border(isDark);

    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(globalPosition, globalPosition),
      Offset.zero & (overlay?.size ?? const Size(320, 220)),
    );

    final selected = await showMenu<String>(
      context: context,
      position: position,
      color: bg,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: border, width: 1),
      ),
      items: [
        PopupMenuItem<String>(
          value: 'modify',
          height: 30,
          child: Text(
            'Modify Base Name',
            style: AppTheme.sans(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: textPrimary,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'new',
          height: 30,
          child: Text(
            'New Base Session',
            style: AppTheme.sans(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: textPrimary,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'all',
          height: 30,
          child: Text(
            'All Base Sessions',
            style: AppTheme.sans(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: textPrimary,
            ),
          ),
        ),
      ],
    );

    if (selected == 'modify') {
      if (context.mounted) _showRenameDialog(context);
    } else if (selected == 'new') {
      if (context.mounted) _showNewBaseDialog(context, null);
    } else if (selected == 'all') {
      if (context.mounted) _showSessionSheet(context);
    }
  }

  void _showRenameDialog(
    BuildContext context, {
    BaseSession? session,
    BuildContext? parentModalContext,
  }) {
    final targetSession = session ?? sessionManager.activeSession;
    final controller = TextEditingController(text: targetSession.name);
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.text.length,
    );
    final bg = AppTheme.bg(isDark);
    final textPrimary = AppTheme.textPrimary(isDark);
    final textMuted = AppTheme.textMuted(isDark);
    final border = AppTheme.border(isDark);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: bg,
          insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          titlePadding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 6,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: border, width: 1),
          ),
          title: Text(
            'Modify Base Name',
            style: AppTheme.sans(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: textPrimary,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: AppTheme.sans(fontSize: 12, color: textPrimary),
            decoration: InputDecoration(
              hintText: 'Enter base name...',
              hintStyle: AppTheme.sans(fontSize: 11.5, color: textMuted),
              filled: true,
              fillColor: AppTheme.controlBg(isDark),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 9,
              ),
            ),
            onSubmitted: (val) {
              final trimmed = val.trim();
              if (trimmed.isNotEmpty) {
                sessionManager.renameSession(targetSession.id, trimmed);
              }
              Navigator.pop(ctx);
            },
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: AppTheme.sans(fontSize: 11.5, color: textMuted),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.activePillBg(isDark),
                foregroundColor: AppTheme.activePillText(isDark),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              onPressed: () {
                final trimmed = controller.text.trim();
                if (trimmed.isNotEmpty) {
                  sessionManager.renameSession(targetSession.id, trimmed);
                }
                Navigator.pop(ctx);
              },
              child: Text(
                'Save',
                style: AppTheme.sans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSessionSheet(BuildContext context) {
    final bg = AppTheme.bg(isDark);
    final textPrimary = AppTheme.textPrimary(isDark);
    final textMuted = AppTheme.textMuted(isDark);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final sessions = sessionManager.sessions;
            final activeId = sessionManager.activeSession.id;

            return Dialog(
              backgroundColor: bg,
              insetPadding: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              child: Container(
                width: 320,
                height: 220,
                padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Base Sessions',
                          style: AppTheme.sans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: textPrimary,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                Icons.tune_rounded,
                                size: 15,
                                color: textMuted,
                              ),
                              onPressed: () {
                                Navigator.pop(ctx);
                                SettingsDialog.show(
                                  context,
                                  sessionManager: sessionManager,
                                  isDark: isDark,
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: textMuted,
                              ),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Session List (Soft rounded cards, no full-bleed Dividers)
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: sessions.length,
                        itemBuilder: (context, index) {
                          final session = sessions[index];
                          final isActive = session.id == activeId;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: InkWell(
                              onTap: () {
                                sessionManager.switchSession(session.id);
                                Navigator.pop(ctx);
                              },
                              onLongPress: () => _showRenameDialog(
                                context,
                                session: session,
                                parentModalContext: ctx,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppTheme.controlBg(isDark)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: session.isSolved
                                              ? AppTheme.statusActive
                                              : (isActive
                                                    ? textPrimary
                                                    : textMuted.withValues(
                                                        alpha: 0.4,
                                                      )),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            session.name,
                                            style: AppTheme.sans(
                                              fontSize: 12,
                                              fontWeight: isActive
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                              color: isActive
                                                  ? textPrimary
                                                  : textMuted,
                                            ),
                                          ),
                                          Text(
                                            session.isSolved
                                                ? 'Solved • ${session.solvedCode}'
                                                : 'Code #${session.currentIndex + 1} of ${sessionManager.totalCodes}',
                                            style: AppTheme.sans(
                                              fontSize: 10,
                                              fontWeight: session.isSolved
                                                  ? FontWeight.w500
                                                  : FontWeight.w400,
                                              color: session.isSolved
                                                  ? AppTheme.statusActive
                                                  : textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        size: 14,
                                      ),
                                      color: textMuted,
                                      tooltip: 'Modify name',
                                      onPressed: () {
                                        _showRenameDialog(
                                          context,
                                          session: session,
                                          parentModalContext: ctx,
                                        );
                                      },
                                    ),
                                    if (sessions.length > 1) ...[
                                      const SizedBox(width: 8),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          size: 15,
                                        ),
                                        color: AppTheme.statusDanger.withValues(
                                          alpha: 0.85,
                                        ),
                                        tooltip: 'Delete base',
                                        onPressed: () {
                                          sessionManager.deleteSession(
                                            session.id,
                                          );
                                          setModalState(() {});
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Solid Monochrome Capsule Footer Button
                    SizedBox(
                      width: double.infinity,
                      child: InkWell(
                        onTap: () => _showNewBaseDialog(context, ctx),
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6.5),
                          decoration: BoxDecoration(
                            color: AppTheme.activePillBg(isDark),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Center(
                            child: Text(
                              'New Base Session',
                              style: AppTheme.sans(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.activePillText(isDark),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showNewBaseDialog(
    BuildContext context,
    BuildContext? parentModalContext,
  ) {
    final controller = TextEditingController();
    final bg = AppTheme.bg(isDark);
    final textPrimary = AppTheme.textPrimary(isDark);
    final textMuted = AppTheme.textMuted(isDark);
    final border = AppTheme.border(isDark);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: bg,
          insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          titlePadding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 6,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: border, width: 1),
          ),
          title: Text(
            'Name This Base',
            style: AppTheme.sans(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: textPrimary,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: AppTheme.sans(fontSize: 12, color: textPrimary),
            decoration: InputDecoration(
              hintText: 'e.g. Sulfur Quarry, 2x2 Bunker',
              hintStyle: AppTheme.sans(fontSize: 11.5, color: textMuted),
              filled: true,
              fillColor: AppTheme.controlBg(isDark),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 9,
              ),
            ),
            onSubmitted: (val) {
              sessionManager.createSession(val);
              Navigator.pop(ctx);
              if (parentModalContext != null && parentModalContext.mounted) {
                Navigator.pop(parentModalContext);
              }
            },
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: AppTheme.sans(fontSize: 11.5, color: textMuted),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.activePillBg(isDark),
                foregroundColor: AppTheme.activePillText(isDark),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              onPressed: () {
                sessionManager.createSession(controller.text);
                Navigator.pop(ctx);
                if (parentModalContext != null && parentModalContext.mounted) {
                  Navigator.pop(parentModalContext);
                }
              },
              child: Text(
                'Create',
                style: AppTheme.sans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
