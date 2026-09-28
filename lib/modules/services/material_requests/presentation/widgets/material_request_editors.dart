import 'package:flutter/material.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/material_requests/domain/service_material_request.dart';

/// Card-based material line editor.
///
/// Uses stacked cards (no horizontal spreadsheet) so it works identically on
/// mobile and desktop. Quantity is entered as text and validated by the domain
/// on save; the total is derived by the domain/read model, never here.
class MaterialRequestLinesEditor extends StatelessWidget {
  const MaterialRequestLinesEditor({
    super.key,
    required this.lines,
    required this.enabled,
    required this.onAdd,
    required this.onRemove,
    required this.onCodeChanged,
    required this.onDescriptionChanged,
    required this.onBatchChanged,
    required this.onQuantityChanged,
    required this.onRemarkChanged,
    this.quantityErrorFor,
  });
  final List<ServiceMaterialRequestLineDraft> lines;
  final bool enabled;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;
  final void Function(String id, String value) onCodeChanged;
  final void Function(String id, String value) onDescriptionChanged;
  final void Function(String id, String value) onBatchChanged;
  final void Function(String id, String value) onQuantityChanged;
  final void Function(String id, String value) onRemarkChanged;
  final String? Function(String id)? quantityErrorFor;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (lines.isEmpty)
          Text(l.servicesMaterialRequestNoMaterials)
        else
          for (var i = 0; i < lines.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.lg),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l.servicesMaterialRequestLineTitle('${i + 1}'),
                          style: AppTypography.of(context).label,
                        ),
                      ),
                      AppIconButton(
                        icon: Icons.delete_outline,
                        tooltip: l.servicesMaterialRequestRemoveMaterial,
                        onPressed: enabled && lines.length > 1
                            ? () => onRemove(lines[i].id)
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppFormGrid(
                    children: [
                      AppTextField(
                        key: ValueKey('mr-code-${lines[i].id}'),
                        label: l.servicesMaterialRequestCode,
                        initialValue: lines[i].code,
                        enabled: enabled,
                        onChanged: (v) => onCodeChanged(lines[i].id, v),
                      ),
                      AppTextField(
                        key: ValueKey('mr-desc-${lines[i].id}'),
                        label: l.servicesMaterialRequestDescription,
                        initialValue: lines[i].description,
                        enabled: enabled,
                        onChanged: (v) => onDescriptionChanged(lines[i].id, v),
                      ),
                      AppTextField(
                        key: ValueKey('mr-batch-${lines[i].id}'),
                        label: l.servicesMaterialRequestBatchNumber,
                        initialValue: lines[i].batchNumber,
                        enabled: enabled,
                        onChanged: (v) => onBatchChanged(lines[i].id, v),
                      ),
                      AppTextField(
                        key: ValueKey('mr-qty-${lines[i].id}'),
                        label: l.servicesMaterialRequestQuantity,
                        initialValue: lines[i].quantity,
                        enabled: enabled,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        errorText: quantityErrorFor?.call(lines[i].id),
                        onChanged: (v) => onQuantityChanged(lines[i].id, v),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    key: ValueKey('mr-remark-${lines[i].id}'),
                    label: l.servicesMaterialRequestRemark,
                    initialValue: lines[i].remark,
                    enabled: enabled,
                    onChanged: (v) => onRemarkChanged(lines[i].id, v),
                  ),
                ],
              ),
            ),
          ],
        const SizedBox(height: AppSpacing.lg),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: AppSecondaryButton(
            label: l.servicesMaterialRequestAddMaterial,
            icon: Icons.add,
            onPressed: enabled ? onAdd : null,
          ),
        ),
      ],
    );
  }
}
