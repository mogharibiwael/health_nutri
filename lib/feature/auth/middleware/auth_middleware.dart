import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_route.dart';
import '../../../core/service/serviecs.dart';
import '../../../core/permissions/permissions.dart';


class AuthMiddleware extends GetMiddleware {
  AuthMiddleware({this.priority = 1});

  @override
  final int priority;

  final MyServices myServices = Get.find();

  @override
  RouteSettings? redirect(String? route) {
    // لو ما في جلسة -> روح login
    if (!myServices.isLoggedIn) {
      return  RouteSettings(name: AppRoute.login);
    }
    return null; // مسموح
  }
}

class GuestMiddleware extends GetMiddleware {
  GuestMiddleware({this.priority = 1});

  @override
  final int priority;

  final MyServices myServices = Get.find();

  @override
  RouteSettings? redirect(String? route) {
    // لو في جلسة -> روح حسب type
    if (myServices.isLoggedIn) {
      final t = (myServices.type ?? "user").toString();
      return RouteSettings(
        name: t == "doctor" ? AppRoute.doctorHome : AppRoute.home,
      );
    }
    return null;
  }
}

class RoleMiddleware extends GetMiddleware {
  RoleMiddleware(this.allowedRoles, {this.priority = 2});

  @override
  final int priority;

  /// Allowed roles: ["patient", "doctor", "admin"] or ["patient"] etc.
  final List<String> allowedRoles;
  final MyServices myServices = Get.find();

  @override
  RouteSettings? redirect(String? route) {
    if (!myServices.isLoggedIn) {
      return RouteSettings(name: AppRoute.login);
    }

    final permissions = Permissions(myServices);
    final currentRole = permissions.currentRole;

    // Normalize role names
    String normalizeRole(String role) {
      final r = role.toLowerCase();
      if (r == "user" || r == "payed") return "patient";
      return r;
    }

    final normalizedCurrent = normalizeRole(currentRole);
    final normalizedAllowed = allowedRoles.map(normalizeRole).toList();

    if (!normalizedAllowed.contains(normalizedCurrent)) {
      // Not allowed: redirect to appropriate home
      if (permissions.isDoctor) {
        return RouteSettings(name: AppRoute.doctorHome);
      }
      return RouteSettings(name: AppRoute.home);
    }

    return null;
  }
}

/// Middleware for patient-only routes
class PatientOnlyMiddleware extends GetMiddleware {
  PatientOnlyMiddleware({this.priority = 2});

  @override
  final int priority;
  final MyServices myServices = Get.find();

  @override
  RouteSettings? redirect(String? route) {
    final permissions = Permissions(myServices);
    if (!permissions.isPatient) {
      return RouteSettings(
        name: permissions.isDoctor ? AppRoute.doctorHome : AppRoute.home,
      );
    }
    return null;
  }
}

/// Middleware for doctor-only routes
class DoctorOnlyMiddleware extends GetMiddleware {
  DoctorOnlyMiddleware({this.priority = 2});

  @override
  final int priority;
  final MyServices myServices = Get.find();

  @override
  RouteSettings? redirect(String? route) {
    final permissions = Permissions(myServices);
    if (!permissions.isDoctor && !permissions.isAdmin) {
      return RouteSettings(name: AppRoute.home);
    }
    return null;
  }
}

/// Middleware for admin-only routes
class AdminOnlyMiddleware extends GetMiddleware {
  AdminOnlyMiddleware({this.priority = 2});

  @override
  final int priority;
  final MyServices myServices = Get.find();

  @override
  RouteSettings? redirect(String? route) {
    final permissions = Permissions(myServices);
    if (!permissions.isAdmin) {
      return RouteSettings(
        name: permissions.isDoctor ? AppRoute.doctorHome : AppRoute.home,
      );
    }
    return null;
  }
}
