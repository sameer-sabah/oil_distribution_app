const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { initializeApp } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");
const { getDatabase } = require("firebase-admin/database");

initializeApp();

exports.deleteUserCompletely = onCall(async (request) => {
  // ==========================================
  // التحقق من تسجيل الدخول
  // ==========================================

  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "يجب تسجيل الدخول أولاً."
    );
  }

  const callerUid = request.auth.uid;

  const db = getDatabase();

  // ==========================================
  // قراءة بيانات الشخص الذي طلب الحذف
  // ==========================================

  const callerSnapshot = await db
      .ref(`users/${callerUid}`)
      .get();

  if (!callerSnapshot.exists()) {
    throw new HttpsError(
      "permission-denied",
      "بيانات المستخدم الحالي غير موجودة."
    );
  }

  const caller = callerSnapshot.val();

  const callerRole =
      String(caller.role || "");

  // ==========================================
  // الصلاحيات
  // ==========================================

  if (
    callerRole !== "admin" &&
    callerRole !== "branchManager"
  ) {
    throw new HttpsError(
      "permission-denied",
      "ليس لديك صلاحية حذف المستخدمين."
    );
  }

  // ==========================================
  // UID المستخدم المطلوب حذفه
  // ==========================================

  const uid = request.data?.uid;

  if (
    !uid ||
    typeof uid !== "string"
  ) {
    throw new HttpsError(
      "invalid-argument",
      "معرف المستخدم UID غير موجود."
    );
  }

  // ==========================================
  // منع حذف الحساب الحالي
  // ==========================================

  if (uid === callerUid) {
    throw new HttpsError(
      "failed-precondition",
      "لا يمكنك حذف حسابك الحالي."
    );
  }

  // ==========================================
  // جلب بيانات المستخدم المطلوب حذفه
  // ==========================================

  const targetSnapshot = await db
      .ref(`users/${uid}`)
      .get();

  if (!targetSnapshot.exists()) {
    throw new HttpsError(
      "not-found",
      "المستخدم المطلوب حذفه غير موجود."
    );
  }

  const target = targetSnapshot.val();

  // ==========================================
  // مدير الفرع:
  // يسمح له بحذف مستخدمي فرعه فقط
  // ==========================================

  if (callerRole === "branchManager") {
    const callerBranchId =
        String(caller.branchId || "");

    const targetBranchId =
        String(target.branchId || "");

  if (
    callerBranchId.length === 0 ||
    callerBranchId !== targetBranchId
  ) {
      throw new HttpsError(
        "permission-denied",
        "لا يمكنك حذف مستخدم من فرع آخر."
      );
    }
  }

  // ==========================================
  // حذف Firebase Authentication
  // ==========================================

  try {
    await getAuth().deleteUser(uid);
  } catch (error) {
    // إذا لم يكن الحساب موجوداً في Authentication
    // نستمر بحذف بيانات قاعدة البيانات.

    if (
      error.code !== "auth/user-not-found"
    ) {
      console.error(
        "Authentication delete error:",
        error
      );

      throw new HttpsError(
        "internal",
        "تعذر حذف حساب Firebase Authentication."
      );
    }
  }

  // ==========================================
  // حذف بيانات المستخدم من Realtime Database
  // ==========================================

  const updates = {};

  updates[`users/${uid}`] = null;

  // حذف جميع أنواع Device Tokens المحتملة
  updates[`deviceTokens/admin/${uid}`] = null;
  updates[`deviceTokens/branch/${uid}`] = null;
  updates[`deviceTokens/station/${uid}`] = null;
  updates[`deviceTokens/employee/${uid}`] = null;
  updates[`deviceTokens/citizen/${uid}`] = null;

  await db.ref().update(updates);

  console.log(
    `تم حذف المستخدم بالكامل: ${uid}`
  );

  return {
    success: true,
    uid: uid,
    message: "تم حذف المستخدم بالكامل.",
  };
});