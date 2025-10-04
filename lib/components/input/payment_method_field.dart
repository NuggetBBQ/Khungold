import 'package:flutter/material.dart';

class PaymentMethodField extends StatelessWidget {
  const PaymentMethodField({
    super.key,
    required this.methods,
    required this.value,
    required this.onChanged,
  });
  final List<String> methods;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: const ValueKey('PaymentMethodDropdown'),
      value: value,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'ช่องทางการชำระ',
      ),
      items: methods
          .map((m) => DropdownMenuItem(value: m, child: Text(m)))
          .toList(),
      onChanged: onChanged,
      validator: (v) =>
          v == null || v.isEmpty ? 'กรุณาเลือกช่องทางการชำระ' : null,
    );
  }
}