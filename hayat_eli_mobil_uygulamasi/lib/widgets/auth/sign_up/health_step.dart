import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/validators.dart';
import '../shared/auth_input_decoration.dart';

class HealthStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String? bloodType;
  final ValueChanged<String?> onBloodTypeChanged;
  final TextEditingController chronicController;
  final TextEditingController allergiesController;
  final TextEditingController medicationsController;

  const HealthStep({
    super.key,
    required this.formKey,
    required this.bloodType,
    required this.onBloodTypeChanged,
    required this.chronicController,
    required this.allergiesController,
    required this.medicationsController,
  });

  static const List<String> _bloodTypes = ['0 Rh+', '0 Rh-', 'A Rh+', 'A Rh-', 'B Rh+', 'B Rh-', 'AB Rh+', 'AB Rh-'];

  InputDecoration _deco(String label, IconData icon) => authInputDecoration(label, icon);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20)],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.blue.shade200)),
              child: Row(children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text('Kan grubu zorunludur. Diğer sağlık bilgileri isteğe bağlıdır.',
                  style: GoogleFonts.outfit(color: Colors.blue.shade800, fontSize: 12))),
              ]),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: bloodType,
              decoration: _deco('Kan Grubu *', Icons.water_drop_outlined),
              items: _bloodTypes.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: onBloodTypeChanged,
              validator: (v) => (v == null || v.isEmpty) ? 'Kan grubu seçimi zorunludur.' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(controller: chronicController, maxLines: 3,
              decoration: _deco('Kronik Hastalıklar (İsteğe Bağlı)', Icons.medical_information_outlined),
              validator: (v) => Validators.validateFreeText(v, fieldName: 'Kronik hastalıklar')),
            const SizedBox(height: 12),
            TextFormField(controller: allergiesController, maxLines: 3,
              decoration: _deco('Alerjiler - özellikle ilaç (İsteğe Bağlı)', Icons.warning_amber_outlined),
              validator: (v) => Validators.validateFreeText(v, fieldName: 'Alerji bilgisi')),
            const SizedBox(height: 12),
            TextFormField(controller: medicationsController, maxLines: 3,
              decoration: _deco('Sürekli Kullanılan İlaçlar (İsteğe Bağlı)', Icons.medication_outlined),
              validator: (v) => Validators.validateFreeText(v, fieldName: 'Kullanılan ilaçlar')),
          ]),
        ),
      ),
    );
  }
}
