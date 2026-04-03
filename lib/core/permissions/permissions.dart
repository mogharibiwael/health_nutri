import '../service/serviecs.dart';

/// Role-based permissions helper
/// Based on permissions.md: Guest, Patient, Doctor, Admin
class Permissions {
  final MyServices myServices;

  Permissions(this.myServices);

  // ─────────────────────────────────────────────────────
  // Role checks
  // ─────────────────────────────────────────────────────

  /// Check if user is guest (not logged in)
  bool get isGuest => !myServices.isLoggedIn;

  /// Check if user is patient (type: "patient" or "payed")
  bool get isPatient {
    if (!myServices.isLoggedIn) return false;
    final type = (myServices.type ?? "").toLowerCase();
    return type == "patient" || type == "payed" || type == "user";
  }

  /// Check if user is doctor (type: "doctor")
  bool get isDoctor {
    if (!myServices.isLoggedIn) return false;
    return (myServices.type ?? "").toLowerCase() == "doctor";
  }

  /// Check if user is admin (type: "admin")
  bool get isAdmin {
    if (!myServices.isLoggedIn) return false;
    return (myServices.type ?? "").toLowerCase() == "admin";
  }

  /// Get current user role
  String get currentRole {
    if (!myServices.isLoggedIn) return "guest";
    return (myServices.type ?? "user").toLowerCase();
  }

  // ─────────────────────────────────────────────────────
  // Feature permissions (based on permissions.md)
  // ─────────────────────────────────────────────────────

  /// Can view profile
  bool get canViewProfile => isPatient || isDoctor || isAdmin;

  /// Can edit profile
  bool get canEditProfile => isPatient || isDoctor || isAdmin;

  /// Can view my diet (patients only)
  bool get canViewMyDiet => isPatient;

  /// Can view diet meals (patients only)
  bool get canViewDietMeals => isPatient;

  /// Can create diet plan for patient (doctors only)
  bool get canCreateDietPlan => isDoctor || isAdmin;

  /// Can edit/delete diet plan (doctors only)
  bool get canManageDiets => isDoctor || isAdmin;

  /// Can view consultations
  bool get canViewConsultations => isPatient || isDoctor || isAdmin;

  /// Can request consultation (patients only)
  bool get canRequestConsultation => isPatient;

  /// Can manage consultations (doctors only)
  bool get canManageConsultations => isDoctor || isAdmin;

  /// Can view BMI/BMR calculator
  bool get canUseCalculator => isPatient || isDoctor || isAdmin;

  /// Can view measurements (patients only)
  bool get canViewMeasurements => isPatient;

  /// Can add measurements (patients only)
  bool get canAddMeasurements => isPatient;

  /// Can view subscriptions (patients only)
  bool get canViewSubscriptions => isPatient;

  /// Can create subscription (patients only)
  bool get canCreateSubscription => isPatient;

  /// Can view patients list (doctors only)
  bool get canViewPatients => isDoctor || isAdmin;

  /// Can view patient details (doctors only)
  bool get canViewPatientDetails => isDoctor || isAdmin;

  /// Can chat with doctor (patients only)
  bool get canChatWithDoctor => isPatient;

  /// Can chat with patient (doctors only)
  bool get canChatWithPatient => isDoctor || isAdmin;

  /// Can view forums (all authenticated users + guests can view)
  bool get canViewForums => true; // Public

  /// Can join forum (patients and doctors)
  bool get canJoinForum => isPatient || isDoctor || isAdmin;

  /// Can create forum (doctors only)
  bool get canCreateForum => isDoctor || isAdmin;

  /// Can post in forum (patients and doctors)
  bool get canPostInForum => isPatient || isDoctor || isAdmin;

  /// Can like posts (patients and doctors)
  bool get canLikePosts => isPatient || isDoctor || isAdmin;

  /// Can view tips (public)
  bool get canViewTips => true;

  /// Can manage tips (admin only)
  bool get canManageTips => isAdmin;

  /// Can view doctors list (public)
  bool get canViewDoctors => true;

  /// Can rate doctor (patients only)
  bool get canRateDoctor => isPatient;

  /// Can manage users (admin only)
  bool get canManageUsers => isAdmin;

  /// Can approve doctors (admin only)
  bool get canApproveDoctors => isAdmin;

  /// Can view dashboard (admin only)
  bool get canViewDashboard => isAdmin;

  /// Can view reports (admin only)
  bool get canViewReports => isAdmin;

  /// Can manage content (admin only)
  bool get canManageContent => isAdmin;

  /// Can view system settings (admin only)
  bool get canViewSettings => isAdmin;

  /// Can view system logs (admin only)
  bool get canViewLogs => isAdmin;
}
