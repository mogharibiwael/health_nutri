import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/shared/widgets/drawer.dart';

import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/shared/widgets/app_bar.dart';
import '../controller/calculations_history_controller.dart';
import '../model/calculation_model.dart';
import 'calculation_details_page.dart';

class CalculationsHistoryPage extends GetView<CalculationsHistoryController> {
  const CalculationsHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CalculationsHistoryController>(
      builder: (c) => SafeArea(
          child: Scaffold(
            drawer: HomeDrawer(controller: c),
            appBar: CustomAppBar(
              title: "showBodyCalculations".tr,
              showBackButton: true,
              leading: Builder(
                builder: (ctx) => IconButton(
                  icon: Icon(Icons.menu, color: AppColor.primary, size: 26),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
            ),
          body: _buildBody(c),
        ),
      ),
    );
  }

  Widget _buildBody(CalculationsHistoryController c) {
    if (c.statusRequest == StatusRequest.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (c.statusRequest == StatusRequest.offlineFailure) {
      return _Message(
        icon: Icons.wifi_off,
        text: "noInternet".tr,
        onRetry: c.refreshHistory,
      );
    }

    if (c.statusRequest == StatusRequest.serverFailure ||
        c.statusRequest == StatusRequest.failure) {
      return _Message(
        icon: Icons.error_outline,
        text: "serverError".tr,
        onRetry: c.refreshHistory,
      );
    }

    if (c.calculations.isEmpty) {
      return _Message(
        icon: Icons.calculate_outlined,
        text: "noCalculationsYet".tr,
        onRetry: c.refreshHistory,
      );
    }

    return RefreshIndicator(
      onRefresh: c.refreshHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: c.calculations.length,
        itemBuilder: (_, i) => _CalculationCard(calculation: c.calculations[i]),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onRetry;

  const _Message({
    required this.icon,
    required this.text,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text("retry".tr),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalculationCard extends StatelessWidget {
  final CalculationModel calculation;

  const _CalculationCard({required this.calculation});

  @override
  Widget build(BuildContext context) {
    final bmi = calculation.bmi;
    final bmr = calculation.bmr;
    final calories = calculation.calories;
    final date = calculation.createdAt != null
        ? _formatDate(calculation.createdAt!)
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColor.primary.withOpacity(0.2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Get.to(() => CalculationDetailsPage(calculation: calculation)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (date != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    date,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (bmi != null)
                _row("BMI", bmi.toStringAsFixed(2), subtitle: calculation.bmiStatus),
              if (bmr != null) _row("BMR", bmr.toStringAsFixed(1)),
              if (calories != null)
                _row("totalKcal".tr, calories.toStringAsFixed(0), isHighlight: true),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.touch_app_rounded, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text(
                    "tapToViewDetails".tr,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {String? subtitle, bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isHighlight ? 15 : 14,
              fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
              color: isHighlight ? AppColor.primary : const Color(0xDD2A0126),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlight ? 16 : 14,
              fontWeight: FontWeight.w700,
              color: isHighlight ? AppColor.primary : const Color(0xDD2A0126),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.tryParse(iso);
      if (dt != null) {
        return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
      }
    } catch (_) {}
    return iso;
  }
}
