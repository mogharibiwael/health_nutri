import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/shared/widgets/app_bar.dart';
import '../controller/portion_categories_controller.dart';
import '../model/portion_categories_model.dart';

class PortionCategoriesPage extends GetView<PortionCategoriesController> {
  const PortionCategoriesPage({super.key});

  static String _categoryLabel(String key) {
    switch (key) {
      case 'milkSkim':
        return "milkSkim".tr;
      case 'milkLowFat':
        return "milkLowFat".tr;
      case 'milkWhole':
        return "milkWhole".tr;
      case 'vegetables':
        return "vegetables".tr;
      case 'fruit':
        return "fruit".tr;
      case 'starch':
        return "starch".tr;
      case 'otherCarbs':
        return "otherCarbs".tr;
      case 'meatVeryLean':
        return "meatVeryLean".tr;
      case 'meatLean':
        return "meatLean".tr;
      case 'meatMediumFat':
        return "meatMediumFat".tr;
      case 'meatHighFat':
        return "meatHighFat".tr;
      case 'fat':
        return "fat".tr;
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PortionCategoriesController>(
      builder: (c) => SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey.shade100, // Light background
          appBar: CustomAppBar(
            title: "dietPortionCategories".tr,
            subtitle: c.patientName.isNotEmpty ? c.patientName : null,
            showBackButton: true,
            showLogo: true,
          ),
          body: Column(
            children: [
              if (!c.showSummary) _buildStepIndicator(c.currentStep),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: c.showSummary ? _buildFinalSummary(c) : _buildWizardStep(context, c),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
      decoration: BoxDecoration(
        color: AppColor.primary.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "mainCategories".tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColor.primary),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "numberOfPortions".tr,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "carbohydrates".tr,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "protein".tr,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "fatsG".tr,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "calories".tr,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildRow(PortionCategoriesController c, String key) {
    final portion = c.getPortion(key);
    final def = PortionCategoriesPlan.definition(key);
    final fatCount = def?.fatG ?? 0;
    final carbsCount = def?.carbsG ?? 0;
    final proteinCount = def?.proteinG ?? 0;
    final calCount = def?.calories ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              _categoryLabel(key),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
            ),
          ),
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: c.showSummary ? null : () => _showQuantityDialog(c, key),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  portion.toStringAsFixed(1),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColor.primary),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "$carbsCount",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "$proteinCount",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "$fatCount",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "$calCount",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _showQuantityDialog(PortionCategoriesController c, String key) {
    double val = c.portionPlan.toGroupMap()[key] ?? 0;
    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(_categoryLabel(key), style: TextStyle(color: Colors.grey.shade900)),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.redAccent, size: 36),
                onPressed: () {
                  if (val >= 0.5) {
                    setState(() => val -= 0.5);
                    c.setPortion(key, val);
                  }
                },
              ),
              Text(val.toStringAsFixed(1), style: TextStyle(fontSize: 32, color: Colors.grey.shade900, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle, color: AppColor.primary, size: 36),
                onPressed: () {
                  setState(() => val += 0.5);
                  c.setPortion(key, val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text("ok".tr, style: const TextStyle(color: AppColor.primary)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _stepDot(1, step >= 1),
          _stepLine(step >= 2),
          _stepDot(2, step >= 2),
          _stepLine(step >= 3),
          _stepDot(3, step >= 3),
        ],
      ),
    );
  }

  Widget _stepDot(int num, bool active) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: active ? AppColor.primary : Colors.grey.shade200,
        shape: BoxShape.circle,
        border: active ? null : Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Text(
          "$num",
          style: TextStyle(
            color: active ? Colors.white : Colors.grey.shade500,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _stepLine(bool active) {
    return Container(
      width: 40,
      height: 2,
      color: active ? AppColor.primary : Colors.grey.shade200,
    );
  }

  Widget _buildWizardStep(BuildContext context, PortionCategoriesController c) {
    List<String> keys = [];
    if (c.isInitialView) {
      keys = ['milkSkim', 'milkLowFat', 'milkWhole', 'vegetables', 'fruit'];
    } else {
      keys = PortionCategoriesPlan.categoryKeys;
    }

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColor.shadowColor.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHeader(),
              ...keys.map((k) => _buildRow(c, k)),
            ],
          ),
        ),
        const SizedBox(height: 32),
        if (c.isInitialView)
          ElevatedButton(
            onPressed: () => _showCalculationFlow(context, c),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 4,
            ),
            child: Text(
              "calculateAndShowRemaining".tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          )
        else
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: c.previousStep,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text("back".tr),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: c.nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text("next".tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        const SizedBox(height: 24),
      ],
    );
  }


  void _showCalculationFlow(BuildContext context, PortionCategoriesController c) {
    // 1. Show Carb Popup
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CarbSplitDialog(
        total: c.remainingCarbsTarget,
        totalText: c.remainingCarbsTarget.toStringAsFixed(1),
        onSave: (starch, other) {
          c.setStarchAndOther(starch, other);
          // 2. Show Meat Popup
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => _MeatSplitDialog(
              total: c.remainingProteinTarget,
              totalText: c.remainingProteinTarget.toStringAsFixed(1),
              onSave: (vLean, lean, med, high) {
                c.setMeats(vLean, lean, med, high);
                final fatTotal = c.remainingFatTarget;
                // 3. Show Fat Total Result Popup
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => AlertDialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    title: Text(
                      "fatDistribution".tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColor.primary),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_fire_department_rounded,
                            color: AppColor.primary, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          "${"totalFatPortions".tr} = ${fatTotal.toStringAsFixed(1)}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                    actions: [
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // 4. Auto-set Fat and show full table (Summary view)
                            c.setFat(fatTotal);
                            c.finishInitialPhase();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Text("ok".tr),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }


  Widget _buildFinalSummary(PortionCategoriesController c) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColor.shadowColor.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHeader(),
              ...PortionCategoriesPlan.categoryKeys.map((k) => _buildRow(c, k)),
              _buildSummaryTotal(c),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: c.previousStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text("back".tr),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: c.finishDistribution,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text("finish".tr, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSummaryTotal(PortionCategoriesController c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Column(
        children: [
          _totalRow("totalCarbs".tr, c.currentCarbs, c.targetCarbs),
          _totalRow("totalProtein".tr, c.currentProtein, c.targetProtein),
          _totalRow("totalFat".tr, c.currentFat, c.targetFat),
          _totalRow("totalCalories".tr, c.currentCalories, c.targetCalories),
          const SizedBox(height: 8),
          _errorRateRow("dietErrorRate".tr, c.errorRate),
        ],
      ),
    );
  }

  Widget _errorRateRow(String label, double rate) {
    final percentage = (rate * 100).toStringAsFixed(1);
    final color = rate < 0.05 ? Colors.green : (rate < 0.1 ? Colors.orange : Colors.red);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade700)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            "$percentage%",
            style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _totalRow(String label, double current, double target) {
    final diff = current - target;
    final color = diff.abs() < 5 ? AppColor.primary : (diff > 0 ? Colors.redAccent : Colors.orangeAccent);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade700)),
          Text(
            "${current.toStringAsFixed(1)} / ${target.toStringAsFixed(1)}",
            style: TextStyle(fontWeight: FontWeight.bold, color: diff.abs() < 5 ? AppColor.primary : color, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _CarbSplitDialog extends StatefulWidget {
  final double total;
  final String totalText;
  final Function(double starch, double other) onSave;

  const _CarbSplitDialog({required this.total, required this.totalText, required this.onSave});

  @override
  State<_CarbSplitDialog> createState() => _CarbSplitState();
}

class _CarbSplitState extends State<_CarbSplitDialog> {
  double starch = 0;
  double other = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text("carbDistribution".tr,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColor.primary)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${"totalCarbPortions".tr} = ${widget.totalText} - ${"divideAmongFields".tr}",
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildInput(
                "starchPortions".tr, starch, (v) => setState(() => starch = v)),
            const SizedBox(height: 12),
            _buildInput("otherCarbPortions".tr, other,
                (v) => setState(() => other = v)),
          ],
        ),
      ),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onSave(starch, other);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            child: Text("save".tr),
          ),
        ),
      ],
    );
  }

  Widget _buildInput(String label, double val, Function(double) onSet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700)),
        const SizedBox(height: 8),
        TextField(
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(color: Colors.grey.shade900),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
          ),
          onChanged: (s) => onSet(double.tryParse(s) ?? 0),
        ),
      ],
    );
  }
}

class _MeatSplitDialog extends StatefulWidget {
  final double total;
  final String totalText;
  final Function(double vLean, double lean, double med, double high) onSave;

  const _MeatSplitDialog({required this.total, required this.totalText, required this.onSave});

  @override
  State<_MeatSplitDialog> createState() => _MeatSplitState();
}

class _MeatSplitState extends State<_MeatSplitDialog> {
  double vLean = 0;
  double lean = 0;
  double med = 0;
  double high = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text("proteinDistribution".tr,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColor.primary)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${"totalProteinPortions".tr} = ${widget.totalText} - ${"divideAmongFields".tr}",
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildInput("veryLeanMeatPortions".tr, vLean,
                (v) => setState(() => vLean = v)),
            const SizedBox(height: 12),
            _buildInput(
                "leanMeatPortions".tr, lean, (v) => setState(() => lean = v)),
            const SizedBox(height: 12),
            _buildInput("mediumFatMeatPortions".tr, med,
                (v) => setState(() => med = v)),
            const SizedBox(height: 12),
            _buildInput(
                "highFatMeatPortions".tr, high, (v) => setState(() => high = v)),
          ],
        ),
      ),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onSave(vLean, lean, med, high);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            child: Text("save".tr),
          ),
        ),
      ],
    );
  }

  Widget _buildInput(String label, double val, Function(double) onSet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700)),
        const SizedBox(height: 8),
        TextField(
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(color: Colors.grey.shade900),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
          ),
          onChanged: (s) => onSet(double.tryParse(s) ?? 0),
        ),
      ],
    );
  }
}
