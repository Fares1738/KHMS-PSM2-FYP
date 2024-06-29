import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:country_picker/country_picker.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final String? Function(String?) validator;
  final bool isDate;
  final bool isCountry;
  final bool isPhoneNumber;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    required this.validator,
    this.isDate = false,
    this.isCountry = false,
    this.isPhoneNumber = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: isDate || isCountry,
      keyboardType: isPhoneNumber ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: isCountry ? 'Select Nationality' : null,
        prefixIcon: Icon(prefixIcon),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
      validator: (value) {
        String? error = validator(value);
        if (error != null) {
          return error;
        } else if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
      onTap: isDate
          ? () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
              }
            }
          : isCountry
              ? () {
                  showCountryPicker(
                    context: context,
                    countryListTheme: const CountryListThemeData(
                        flagSize: 25,
                        backgroundColor: Colors.white,
                        textStyle: TextStyle(fontSize: 16),
                        bottomSheetHeight: 500,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0))),
                    onSelect: (Country country) =>
                        controller.text = country.name,
                  );
                }
              : null,
    );
  }
}
