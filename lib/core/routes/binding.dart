import 'package:get/get.dart';
import 'package:nutri_guide/core/class/crud.dart';
import 'package:nutri_guide/doctorApp/feature/home/controller/doctor_patients_controller.dart';
import 'package:nutri_guide/feature/auth/controller/forget_password_controller.dart';
import 'package:nutri_guide/feature/auth/controller/verify_email_controller.dart';
import 'package:nutri_guide/feature/auth/controller/login_controller.dart';
import 'package:nutri_guide/feature/auth/controller/signup_controller.dart';
import 'package:nutri_guide/feature/chat/controller/patient_profile_controller.dart';
import 'package:nutri_guide/feature/splash/controller/controller.dart';

import '../../doctorApp/feature/home/controller/home_doctor_controller.dart';
import '../../doctorApp/feature/home/controller/patient_details_controller.dart';
import '../../feature/bmi/controller/bmi_controller.dart';
import '../../feature/calculations/data/calculations_data.dart';
import '../../feature/calculations/controller/calculations_history_controller.dart';
import '../../feature/calculations/controller/doctor_patient_calculations_controller.dart';
import '../../feature/chat/controller/chat_controller.dart';
import '../../feature/doctor/controller/doctor_details_controller.dart';
import '../../feature/doctor/controller/doctors_controller.dart';
import '../../feature/doctor/payment_invoice_controller.dart';
import '../../feature/doctor/subscription/subscription_info_controller.dart';
import '../../feature/home/controller/home_controller.dart';
import '../../feature/forum/controller/forum_posts_controller.dart';
import '../../feature/forum/controller/forums_controller.dart';
import '../../feature/tips/controller/tips_controller.dart';
import '../../feature/tips/controller/tips_main_controller.dart';
import '../../feature/athkar/controller/spiritual_nutrition_controller.dart';
import '../../feature/athkar/controller/athkar_list_controller.dart';
import '../../feature/settings/controller/settings_controller.dart';
import '../../feature/settings/controller/edit_profile_controller.dart';
import '../../feature/settings/controller/reminders_controller.dart';
import '../../feature/consultations/controller/consultations_controller.dart';
import '../../feature/diet/controller/diet_controller.dart';
import '../../feature/diet/controller/diet_periods_controller.dart';
import '../../feature/diet/controller/diet_targets_controller.dart';
import '../../feature/diet/controller/portion_categories_controller.dart';
import '../../feature/diet/controller/portion_categories_controller.dart';
import '../../feature/diet/controller/diet_distribution_controller.dart';
import '../../feature/diet/controller/determine_meals_controller.dart';
import '../../feature/step_counter/controller/step_counter_controller.dart';
import '../../feature/medical_files/controller/medical_files_controller.dart';
import '../../feature/medical_tests/controller/medical_tests_controller.dart';

class InitBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(Crud());
    Get.put( SplashController());
  }
}

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController());
  }
}

class SignupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SignupController());
  }
}
class ForgotBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ForgotPasswordController());
  }
}
class VerifyEmailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => VerifyEmailController());
  }
}
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut( () => HomeController(), fenix: true);
  }
}
class HomeDoctorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut( () => DoctorHomeController(), fenix: true);
    Get.lazyPut( () => DoctorPatientsController(), fenix: true);
  }
}

class TipsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TipsController(), fenix: true);
  }
}

class TipsMainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TipsMainController(), fenix: true);
  }
}

class SpiritualNutritionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SpiritualNutritionController());
  }
}

class AthkarListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AthkarListController(), fenix: true);
  }
}

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingsController());
  }
}

class EditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EditProfileController());
  }
}

class RemindersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RemindersController());
  }
}

class DoctorsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DoctorsController(), fenix: true);
  }
}


class BmiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CalculationsData(Get.find()));
    Get.lazyPut(() => BmiController());
  }
}

class CalculationsHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CalculationsData(Get.find()));
    Get.lazyPut(() => CalculationsHistoryController());
  }
}

class DoctorPatientCalculationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CalculationsData(Get.find()));
    Get.lazyPut(() => DoctorPatientCalculationsController());
  }
}




class DoctorDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DoctorDetailsController(), fenix: true);
  }
}

class SubscriptionInfoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SubscriptionInfoController());
  }
}

class PaymentInvoiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PaymentInvoiceController());
  }
}

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChatController(), fenix: true);
  }
}


class PatientDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PatientDetailsController());
  }
}
class PatientProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PatientProfileController());
  }
}

class ForumsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ForumsController(), fenix: true);
  }
}

class ForumPostsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ForumPostsController(), fenix: true);
  }
}

class ConsultationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ConsultationsController(), fenix: true);
  }
}

class DietBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DietController(), fenix: true);
  }
}

class DietPeriodsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DietPeriodsController());
  }
}

class DietTargetsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DietTargetsController());
  }
}


class PortionCategoriesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PortionCategoriesController());
  }
}


class DietDistributionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DietDistributionController());
  }
}

class DetermineMealsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DetermineMealsController());
  }
}

class StepCounterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StepCounterController());
  }
}

class MedicalFilesBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MedicalFilesController(), permanent: false);
  }
}

class MedicalTestsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MedicalTestsController(), permanent: false);
  }
}

