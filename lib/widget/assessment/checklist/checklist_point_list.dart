import 'package:asesmen_paud/api/dto/checklist_dto.dart';
import 'package:asesmen_paud/widget/assessment/checklist/checklist_point_item.dart';
import 'package:flutter/material.dart';

class ChecklistPointList extends StatelessWidget {
  final List<dynamic> checklistPoints;
  final Function(ChecklistPointDto) onViewMore;
  final Function(ChecklistPointDto) onDelete;

  const ChecklistPointList({
    super.key,
    required this.checklistPoints,
    required this.onViewMore,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: checklistPoints.length,
      itemBuilder: (context, index) {
        final checklistPoint = checklistPoints[index];
        return ChecklistPointItem(
            checklistPoint: checklistPoint,
            onPressed: () => onViewMore(checklistPoint),
            onDelete: () => onDelete(checklistPoint));
      },
    );
  }
}
