import '../../models/collage_template.dart';
import 'template_builders.dart';

/// Registry of all collage templates, dynamically filterable by photo count.
final class TemplateRegistry {
  TemplateRegistry._();

  /// All built-in templates, ordered by slot count then by name.
  static final List<CollageTemplate> all = [
    // ---- 1 photo ----
    CollageTemplate(
      id: 't1_full',
      name: 'Penuh',
      slotCount: 1,
      slots: Tpl.single(),
    ),

    // ---- 2 photos ----
    CollageTemplate(
      id: 't2_rows',
      name: 'Tumpuk Horizontal',
      slotCount: 2,
      slots: Tpl.rows(2),
    ),
    CollageTemplate(
      id: 't2_cols',
      name: 'Samping Vertikal',
      slotCount: 2,
      slots: Tpl.columns(2),
    ),
    CollageTemplate(
      id: 't2_big_left',
      name: 'Besar + Kecil',
      slotCount: 2,
      slots: Tpl.bigLeft(smallCount: 1, bigWidth: 0.62),
    ),

    // ---- 3 photos ----
    CollageTemplate(
      id: 't3_rows',
      name: '3 Strip',
      slotCount: 3,
      slots: Tpl.rows(3),
    ),
    CollageTemplate(
      id: 't3_big_top',
      name: 'Besar + 2 Bawah',
      slotCount: 3,
      slots: Tpl.bigTop(smallCount: 2),
    ),
    CollageTemplate(
      id: 't3_big_left',
      name: 'Besar + 2 Kanan',
      slotCount: 3,
      slots: Tpl.bigLeft(smallCount: 2),
    ),

    // ---- 4 photos ----
    CollageTemplate(
      id: 't4_grid2x2',
      name: 'Grid 2×2',
      slotCount: 4,
      slots: Tpl.grid2x2(),
    ),
    CollageTemplate(
      id: 't4_rows',
      name: '4 Strip',
      slotCount: 4,
      slots: Tpl.rows(4),
    ),
    CollageTemplate(
      id: 't4_big_left',
      name: 'Besar + 3 Kanan',
      slotCount: 4,
      slots: Tpl.bigLeft(smallCount: 3),
    ),

    // ---- 5 photos ----
    CollageTemplate(
      id: 't5_grid',
      name: 'Grid 2+3',
      slotCount: 5,
      slots: Tpl.grid(3, 2),
    ),
    CollageTemplate(
      id: 't5_big_top',
      name: 'Besar + 4 Bawah',
      slotCount: 5,
      slots: Tpl.bigTop(smallCount: 4),
    ),

    // ---- 6 photos ----
    CollageTemplate(
      id: 't6_grid',
      name: 'Grid 3×2',
      slotCount: 6,
      slots: Tpl.grid(3, 2),
    ),
    CollageTemplate(
      id: 't6_grid2x3',
      name: 'Grid 2×3',
      slotCount: 6,
      slots: Tpl.grid(2, 3),
    ),

    // ---- 7 photos ----
    CollageTemplate(
      id: 't7_grid',
      name: 'Grid 4+3',
      slotCount: 7,
      slots: Tpl.grid(4, 2),
    ),

    // ---- 8 photos: reference layout ⭐ ----
    CollageTemplate(
      id: 't8_reference',
      name: 'Laporan Atensi (Referensi)',
      slotCount: 8,
      slots: Tpl.reference8(),
    ),
    CollageTemplate(
      id: 't8_grid',
      name: 'Grid 4×2',
      slotCount: 8,
      slots: Tpl.grid(4, 2),
    ),

    // ---- 9 photos ----
    CollageTemplate(
      id: 't9_grid',
      name: 'Grid 3×3',
      slotCount: 9,
      slots: Tpl.grid(3, 3),
    ),
  ];

  /// Templates supporting exactly [slotCount] photos.
  static List<CollageTemplate> bySlotCount(int slotCount) =>
      all.where((t) => t.slotCount == slotCount).toList();

  /// Find a template by id (null if not found).
  static CollageTemplate? byId(String? id) {
    if (id == null) return null;
    for (final t in all) {
      if (t.id == id) return t;
    }
    return null;
  }
}
