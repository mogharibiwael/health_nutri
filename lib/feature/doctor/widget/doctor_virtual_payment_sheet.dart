import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/colors.dart';
import '../controller/doctor_details_controller.dart';

class DoctorVirtualPaymentSheet extends GetView<DoctorDetailsController> {
  const DoctorVirtualPaymentSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DoctorDetailsController>(
      builder: (c) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Get.theme.dividerColor,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),

              Text(
                "virtual_payment".tr,
                style: const TextStyle(color: AppColor.textColor, fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),

              // ✅ methods: card / wallet / transfer (no cash)
              Row(
                children: [
                  Expanded(
                    child: _PayMethodTile(
                      title: "payment_card".tr,
                      selected: c.paymentMethod == "card",
                      onTap: () => c.setPaymentMethod("card"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _PayMethodTile(
                      title: "payment_wallet".tr,
                      selected: c.paymentMethod == "wallet",
                      onTap: () => c.setPaymentMethod("wallet"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _PayMethodTile(
                      title: "payment_transfer".tr, // <-- new key
                      selected: c.paymentMethod == "transfer",
                      onTap: () => c.setPaymentMethod("transfer"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ✅ dynamic payment info
              if (c.paymentMethod == "card") ...[
                _SectionTitle(title: "card_info".tr),
                const SizedBox(height: 8),
                _Input(
                  controller: c.cardHolderController,
                  label: "card_holder".tr,
                  hint: "card_holder_hint".tr,
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 10),
                _Input(
                  controller: c.cardNumberController,
                  label: "card_number".tr,
                  hint: "card_number_hint".tr,
                  icon: Icons.credit_card,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _Input(
                        controller: c.cardExpController,
                        label: "card_exp".tr,
                        hint: "card_exp_hint".tr, // MM/YY
                        icon: Icons.date_range_outlined,
                        keyboardType: TextInputType.datetime,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Input(
                        controller: c.cardCvvController,
                        label: "card_cvv".tr,
                        hint: "card_cvv_hint".tr,
                        icon: Icons.lock_outline,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                      ),
                    ),
                  ],
                ),
              ],

              if (c.paymentMethod == "wallet") ...[
                _SectionTitle(title: "wallet_info".tr),
                const SizedBox(height: 8),
                _Input(
                  controller: c.walletNameController,
                  label: "wallet_name".tr,
                  hint: "wallet_name_hint".tr,
                  icon: Icons.account_balance_wallet_outlined,
                ),
                const SizedBox(height: 10),
                _Input(
                  controller: c.walletNumberController,
                  label: "wallet_number".tr,
                  hint: "wallet_number_hint".tr,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                _Input(
                  controller: c.walletRefController,
                  label: "wallet_ref".tr,
                  hint: "wallet_ref_hint".tr,
                  icon: Icons.receipt_long_outlined,
                ),
              ],

              if (c.paymentMethod == "transfer") ...[
                _SectionTitle(title: "transfer_info".tr),
                const SizedBox(height: 8),
                _Input(
                  controller: c.transferSenderController,
                  label: "transfer_sender".tr,
                  hint: "transfer_sender_hint".tr,
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 10),
                _Input(
                  controller: c.transferReceiverController,
                  label: "transfer_receiver".tr,
                  hint: "transfer_receiver_hint".tr,
                  icon: Icons.person_pin_outlined,
                ),
                const SizedBox(height: 10),
                _Input(
                  controller: c.transferRefController,
                  label: "transfer_ref".tr,
                  hint: "transfer_ref_hint".tr,
                  icon: Icons.confirmation_number_outlined,
                ),
                const SizedBox(height: 10),
                _Input(
                  controller: c.transferAmountController,
                  label: "transfer_amount".tr,
                  hint: "transfer_amount_hint".tr,
                  icon: Icons.payments_outlined,
                  keyboardType: TextInputType.number,
                ),
              ],

              const SizedBox(height: 14),

              _SummaryRow(label: "summary_plan".tr, value: c.planType),
              _SummaryRow(
                label: "summary_duration".tr,
                value: "${c.durationMonths} ${"months".tr}",
              ),
              _SummaryRow(label: "summary_price".tr, value: "${c.price}"),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: c.statusRequest == StatusRequest.loading
                      ? null
                      : c.confirmPaymentAndSubscribe,
                  child: c.statusRequest == StatusRequest.loading
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : Text("pay_and_subscribe".tr),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PayMethodTile extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _PayMethodTile({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Get.theme.colorScheme.primary : Get.theme.dividerColor,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: selected ? Get.theme.colorScheme.primary : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;

  const _Input({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(color: Colors.grey.shade700))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
