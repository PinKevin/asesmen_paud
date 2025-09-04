import 'package:asesmen_paud/api/payload/student_payload.dart';
import 'package:flutter/material.dart';

class ClassChipSelection extends StatelessWidget {
  final List<Classroom> classes;
  final Classroom? selectedClass;
  final bool isLoading;
  final void Function(Classroom?) onClassSelected;

  const ClassChipSelection({
    super.key,
    required this.classes,
    this.selectedClass,
    required this.isLoading,
    required this.onClassSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const CircularProgressIndicator();
    }

    Widget buildChoiceChip({
      required String label,
      required bool isSelected,
      required VoidCallback onSelected,
    }) {
      return ChoiceChip(
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onSelected(),
        backgroundColor: Colors.white,
        selectedColor: Colors.deepPurple[200],
        labelStyle: TextStyle(
          color: selectedClass == null ? Colors.white : Colors.black,
        ),
      );
    }

    return SizedBox(
      height: 40,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            buildChoiceChip(
              label: 'Semua',
              isSelected: selectedClass == null,
              onSelected: () => onClassSelected(null),
            ),
            const SizedBox(
              width: 10,
            ),
            ...classes.map((cls) {
              final isSelected = selectedClass?.id == cls.id;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: buildChoiceChip(
                  label: cls.name,
                  isSelected: isSelected,
                  onSelected: () => onClassSelected(cls),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
