import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

InputDecoration authInputDecoration(String label, IconData icon, {Color kRed = const Color(0xFFE53935)}) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: Colors.grey, size: 20),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: kRed, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.red.shade400),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    labelStyle: GoogleFonts.outfit(fontSize: 13),
    floatingLabelBehavior: FloatingLabelBehavior.always,
  );
}
