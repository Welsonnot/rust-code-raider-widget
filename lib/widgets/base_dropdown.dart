// Copyright (c) 2026 Wilhelm San Pedro (https://minristudio.com).
// Licensed under the PolyForm Noncommercial License 1.0.0.
// See LICENSE in the project root for full license terms.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/base_session.dart';
import '../models/session_manager.dart';
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
    final textPrimary = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF111111);
    final textMuted = isDark ? const Color(0xFF7A7A80) : const Color(0xFF8E8E93);

    return GestureDetector(
      onSecondaryTapDown: (details) => _showContextMenu(context, details.globalPosition),
      child: InkWell(
        onTap: () => _showSessionSheet(context),
        onSecondaryTap: () => _showRenameDialog(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 95),
                  child: Text(
                    sessionManager.activeSession.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                      color: textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context, Offset globalPosition) async {
    final RenderBox? overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return;

    final bg = isDark ? const Color(0xFF18181D) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF111111);
    final border = isDark ? const Color(0xFF2C2C34) : const Color(0xFFE5E5EA);

    final selected = await showMenu<String>(
      context: context,
      color: bg,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: border, width: 1),
      ),
      position: RelativeRect.fromRect(
        Rect.fromLTWH(globalPosition.dx, globalPosition.dy, 0, 0),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem<String>(
          value: 'modify',
          height: 34,
          child: Row(
            children: [
              Icon(Icons.edit_rounded, size: 14, color: textPrimary),
              const SizedBox(width: 8),
              Text(
                'Modify Base Name',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'new',
          height: 34,
          child: Row(
            children: [
              Icon(Icons.add_rounded, size: 14, color: textPrimary),
              const SizedBox(width: 8),
              Text(
                'New Base Session',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textPrimary,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'all',
          height: 34,
          child: Row(
            children: [
              Icon(Icons.list_rounded, size: 14, color: textPrimary),
              const SizedBox(width: 8),
              Text(
                'All Base Sessions',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textPrimary,
                ),
              ),
            ],
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
    final bg = isDark ? const Color(0xFF141418) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF111111);
    final border = isDark ? const Color(0xFF26262C) : const Color(0xFFE5E5EA);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: bg,
          insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: border),
          ),
          title: Text(
            'Modify Base Name',
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: textPrimary),
            decoration: InputDecoration(
              hintText: 'Enter base name...',
              hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey),
              filled: true,
              fillColor: isDark ? const Color(0xFF22222A) : const Color(0xFFF2F2F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(color: Colors.grey),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: isDark ? Colors.white : Colors.black,
                foregroundColor: isDark ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSessionSheet(BuildContext context) {
    final bg = isDark ? const Color(0xFF141418) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF111111);
    final textMuted = isDark ? const Color(0xFF7A7A80) : const Color(0xFF8E8E93);
    final border = isDark ? const Color(0xFF26262C) : const Color(0xFFE5E5EA);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final sessions = sessionManager.sessions;
            final activeId = sessionManager.activeSession.id;

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
                    // Title + Settings + Close
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Base Sessions',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: textPrimary,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(Icons.tune_rounded, size: 17, color: textMuted),
                              onPressed: () {
                                Navigator.pop(ctx);
                                SettingsDialog.show(context, sessionManager: sessionManager, isDark: isDark);
                              },
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(Icons.close_rounded, size: 18, color: textMuted),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Session List
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: sessions.length,
                        separatorBuilder: (_, __) => Divider(height: 1, color: border),
                        itemBuilder: (context, index) {
                          final session = sessions[index];
                          final isActive = session.id == activeId;

                          return ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                            onTap: () {
                              sessionManager.switchSession(session.id);
                              Navigator.pop(ctx);
                            },
                            onLongPress: () => _showRenameDialog(context, session: session, parentModalContext: ctx),
                            title: Text(
                              session.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                color: isActive
                                    ? (isDark ? Colors.white : Colors.black)
                                    : textMuted,
                              ),
                            ),
                            subtitle: Text(
                              session.isSolved
                                  ? '✓ Solved: ${session.solvedCode}'
                                  : 'Code ${session.currentIndex + 1} / ${sessionManager.totalCodes}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                color: session.isSolved
                                    ? const Color(0xFF34C759)
                                    : textMuted,
                              ),
                            ),
                            leading: Icon(
                              isActive
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              size: 15,
                              color: isActive ? textPrimary : textMuted,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.edit_outlined, size: 15),
                                  color: textMuted,
                                  tooltip: 'Modify name',
                                  onPressed: () {
                                    _showRenameDialog(context, session: session, parentModalContext: ctx);
                                  },
                                ),
                                if (sessions.length > 1) ...[
                                  const SizedBox(width: 8),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                                    color: Colors.redAccent.withValues(alpha: 0.8),
                                    tooltip: 'Delete base',
                                    onPressed: () {
                                      sessionManager.deleteSession(session.id);
                                      setModalState(() {});
                                    },
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Add New Base Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textPrimary,
                          side: BorderSide(color: border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                        ),
                        icon: const Icon(Icons.add_rounded, size: 15),
                        label: Text(
                          'New Base Session',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w600),
                        ),
                        onPressed: () => _showNewBaseDialog(context, ctx),
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

  void _showNewBaseDialog(BuildContext context, BuildContext? parentModalContext) {
    final controller = TextEditingController();
    final bg = isDark ? const Color(0xFF1A1A20) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF111111);
    final border = isDark ? const Color(0xFF2E2E36) : const Color(0xFFE5E5EA);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: bg,
          insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: border),
          ),
          title: Text(
            'Name This Base',
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: textPrimary),
            decoration: InputDecoration(
              hintText: 'e.g. Sulfur Quarry, 2x2 Bunker',
              hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey),
              filled: true,
              fillColor: isDark ? const Color(0xFF25252E) : const Color(0xFFF2F2F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: Colors.grey)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: isDark ? Colors.white : Colors.black,
                foregroundColor: isDark ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                sessionManager.createSession(controller.text);
                Navigator.pop(ctx);
                if (parentModalContext != null && parentModalContext.mounted) {
                  Navigator.pop(parentModalContext);
                }
              },
              child: Text('Create', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }
}
