import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../core/shared/widgets/app_bar.dart';
import '../model/calculation_model.dart';

class CalculationDetailsPage extends StatelessWidget {
  final CalculationModel calculation;

  const CalculationDetailsPage({super.key, required this.calculation});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: "showBodyCalculations".tr,
          showBackButton: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Header(
              date: calculation.createdAt,
              id: calculation.id,
            ),
            const SizedBox(height: 12),
            _Card(
              children: [
                _RowItem(label: "BMI", value: _fmt(calculation.bmi, digits: 2)),
                _RowItem(label: "BMR", value: _fmt(calculation.bmr, digits: 1)),
                _RowItem(label: "totalKcal".tr, value: _fmt(calculation.calories, digits: 0)),
              ],
            ),
            const SizedBox(height: 12),
            _Card(
              title: "nutritionMacros".tr,
              children: [
                _RowItem(label: "carbohydrates".tr, value: _fmt(calculation.carbs, digits: 1)),
                _RowItem(label: "protein".tr, value: _fmt(calculation.protein, digits: 1)),
                _RowItem(label: "fat".tr, value: _fmt(calculation.fat, digits: 1)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double? v, {int digits = 1}) {
    if (v == null) return "-";
    return v.toStringAsFixed(digits);
  }
}

class _Header extends StatelessWidget {
  final String? date;
  final int id;

  const _Header({required this.date, required this.id});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${"calculation".tr} #$id",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            date ?? "-",
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const _Card({this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(title!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
            ],
            ...children,
          ],
        ),
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  final String label;
  final String value;

  const _RowItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

