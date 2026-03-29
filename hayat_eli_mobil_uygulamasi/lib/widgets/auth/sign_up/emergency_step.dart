import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/user_model.dart';
import '../../../utils/validators.dart';
import '../shared/auth_input_decoration.dart';

class EmergencyStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final List<EmergencyContact> emergencyContacts;
  final ValueChanged<int> onRemoveContact;
  final VoidCallback onAddContact;
  final TextEditingController ecNameController;
  final TextEditingController ecPhoneController;
  final String ecDialCode;
  final ValueChanged<String?> onEcDialCodeChanged;
  final String? ecRelationship;
  final ValueChanged<String?> onEcRelationshipChanged;

  const EmergencyStep({
    super.key,
    required this.formKey,
    required this.emergencyContacts,
    required this.onRemoveContact,
    required this.onAddContact,
    required this.ecNameController,
    required this.ecPhoneController,
    required this.ecDialCode,
    required this.onEcDialCodeChanged,
    required this.ecRelationship,
    required this.onEcRelationshipChanged,
  });

  static const _kRed = Color(0xFFE53935);
  static const List<String> _relationships = ['Anne', 'Baba', 'Kardeş', 'Eş', 'Çocuk', 'Akraba', 'Arkadaş', 'Diğer'];

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
            if (emergencyContacts.isNotEmpty)
              ...emergencyContacts.asMap().entries.map((entry) {
                final i = entry.key;
                final c = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.green.shade200)),
                  child: Row(children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${c.name} (${c.relationship})', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14)),
                      Text(c.phone, style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12)),
                    ])),
                    IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: () => onRemoveContact(i)),
                  ]),
                );
              }),

            TextFormField(controller: ecNameController,
              decoration: _deco('Kişi Adı Soyadı *', Icons.person_add_outlined),
              inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[0-9]'))]),
            const SizedBox(height: 10),

            Row(children: [
              Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: ecDialCode,
                    onChanged: onEcDialCodeChanged,
                    items: Validators.dialCodes.map((c) => DropdownMenuItem<String>(value: c['code'], child: Text(c['code']!, style: GoogleFonts.outfit(fontSize: 13)))).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(child: TextFormField(controller: ecPhoneController, keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _deco('Telefon No *', Icons.phone_outlined))),
            ]),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: ecRelationship,
              decoration: _deco('Yakınlık Derecesi', Icons.family_restroom),
              items: _relationships.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: onEcRelationshipChanged,
            ),
            const SizedBox(height: 14),

            SizedBox(width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add, color: _kRed),
                label: Text('Kişi Ekle', style: GoogleFonts.outfit(color: _kRed, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: _kRed), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: onAddContact,
              ),
            ),

            if (emergencyContacts.isEmpty) ...[
              const SizedBox(height: 8),
              Text('⚠️ En az 1 acil durum kişisi eklemeniz gerekmektedir.',
                style: GoogleFonts.outfit(color: Colors.red.shade700, fontSize: 12), textAlign: TextAlign.center),
            ],
          ]),
        ),
      ),
    );
  }
}
