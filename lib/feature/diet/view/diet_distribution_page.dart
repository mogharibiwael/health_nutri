import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/shared/widgets/app_bar.dart';
import '../controller/diet_distribution_controller.dart';
class DietDistributionPage extends GetView<DietDistributionController> {
  const DietDistributionPage({super.key});

  static const List<String> _groups = [
    'starch',
    'fruit',
    'vegetables',
    'milk',
    'meat',
    'fat',
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DietDistributionController>(
      builder: (c) => SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: CustomAppBar(
            subtitle: c.patientName.isNotEmpty ? c.patientName : null,
            title: "portionDistributionByPeriods".tr,
            showBackButton: true,
            showLogo: true,
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: c.exchangePlan == null
                        ? const Center(child: CircularProgressIndicator())
                        : _buildTable(c),
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: c.goToCreateDiet,
                    icon: const Icon(Icons.check, size: 22),
                    label: Text("proceedToLastStep".tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTable(DietDistributionController c) {
    final mealKeys = c.distribution.keys.toList();
    if (mealKeys.isEmpty) return const SizedBox();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColor.shadowColor.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(AppColor.primary.withOpacity(0.15)),
        columns: [
          DataColumn(
            label: Text(
              "group".tr,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          DataColumn(
            label: Text(
              "totalDaily".tr,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ...mealKeys.map((k) => DataColumn(
                label: SizedBox(
                  width: 80,
                  child: Text(
                    c.mealKeyToLabel(k),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )),
        ],
        rows: _groups.map((group) {
          final total = _getGroupTotal(c, group);
          return DataRow(
            cells: [
              DataCell(Text(_groupLabel(group))),
              DataCell(Text(total.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w600))),
              ...mealKeys.map((mealKey) {
                final val = c.distribution[mealKey]?[group] ?? 0.0;
                return DataCell(
                  Center(
                    child: Text(
                      val.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                );
              }),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _groupLabel(String key) {
    switch (key) {
      case 'starch':
        return "starch".tr;
      case 'fruit':
        return "fruit".tr;
      case 'vegetables':
        return "vegetables".tr;
      case 'milk':
        return "milk".tr;
      case 'meat':
        return "meat".tr;
      case 'fat':
        return "fat".tr;
      default:
        return key;
    }
  }

  double _getGroupTotal(DietDistributionController c, String group) {
    double sum = 0;
    for (final meal in c.distribution.values) {
      sum += meal[group] ?? 0.0;
    }
    return sum;
  }
}
