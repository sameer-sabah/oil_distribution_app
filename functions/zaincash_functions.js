const { onCall, onRequest, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const admin = require("firebase-admin");
const jwt = require("jsonwebtoken");
const crypto = require("crypto");

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.database();

const ZAINCASH_CLIENT_ID = defineSecret("ZAINCASH_CLIENT_ID");
const ZAINCASH_CLIENT_SECRET = defineSecret("ZAINCASH_CLIENT_SECRET");
const ZAINCASH_API_KEY = defineSecret("ZAINCASH_API_KEY");

const REGION = "us-central1";
const TEST_BASE_URL = "https://pg-api-uat.zaincash.iq";

// زين كاش يزوّدك بعنوان Production أثناء onboarding.
// لا نخمّن العنوان ولا نضع عنوان UAT في Production.
const PRODUCTION_BASE_URL = "";

function normalizeLanguage(value) {
  if (value === "En" || value === "Ku" || value === "Ar") {
    return value;
  }
  return "Ar";
}

function deepFind(obj, keys) {
  if (obj == null) return null;

  if (typeof obj !== "object") {
    return null;
  }

  for (const key of keys) {
    if (Object.prototype.hasOwnProperty.call(obj, key)) {
      const value = obj[key];
      if (value !== null && value !== undefined && value !== "") {
        return value;
      }
    }
  }

  for (const value of Object.values(obj)) {
    const found = deepFind(value, keys);
    if (found !== null && found !== undefined && found !== "") {
      return found;
    }
  }

  return null;
}

function baseUrlFromSettings(settings) {
  const environment =
    settings?.environment === "production"
      ? "production"
      : "test";

  if (environment === "production") {
    if (!PRODUCTION_BASE_URL) {
      throw new HttpsError(
        "failed-precondition",
        "Production base URL لم يتم ضبطه بعد. استخدم Test إلى أن تستلم بيانات Production من ZainCash."
      );
    }
    return PRODUCTION_BASE_URL;
  }

  return TEST_BASE_URL;
}

async function getSettings() {
  const snap = await db
    .ref("systemSettings/commercialAds")
    .get();

  return snap.exists() && snap.val()
    ? snap.val()
    : {};
}

async function getAccessToken(baseUrl) {
  const body = new URLSearchParams({
    grant_type: "client_credentials",
    client_id: ZAINCASH_CLIENT_ID.value(),
    client_secret: ZAINCASH_CLIENT_SECRET.value(),
    scope: "payment:read payment:write",
  });

  const response = await fetch(
    `${baseUrl}/oauth2/token`,
    {
      method: "POST",
      headers: {
        "Content-Type":
          "application/x-www-form-urlencoded",
      },
      body,
    }
  );

  const raw = await response.text();
  let data;

  try {
    data = JSON.parse(raw);
  } catch (_) {
    data = { raw };
  }

  if (!response.ok) {
    console.error(
      "ZainCash OAuth error",
      response.status,
      data
    );

    throw new HttpsError(
      "unavailable",
      `ZainCash OAuth failed (${response.status})`
    );
  }

  const token = deepFind(
    data,
    ["access_token", "accessToken", "token"]
  );

  if (!token) {
    console.error(
      "ZainCash OAuth response missing token",
      data
    );

    throw new HttpsError(
      "data-loss",
      "ZainCash access token missing"
    );
  }

  return token.toString();
}

async function createGatewayPayment({
  baseUrl,
  accessToken,
  language,
  externalReferenceId,
  orderId,
  serviceType,
  amount,
  successUrl,
  failureUrl,
}) {
  const payload = {
    language,
    externalReferenceId,
    orderId,
    serviceType,
    amount: {
      value: amount,
      currency: "IQD",
    },
    redirectUrls: {
      successUrl,
      failureUrl,
    },
  };

  const response = await fetch(
    `${baseUrl}/api/v2/payment-gateway/transaction/init`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(payload),
    }
  );

  const raw = await response.text();
  let data;

  try {
    data = JSON.parse(raw);
  } catch (_) {
    data = { raw };
  }

  if (!response.ok) {
    console.error(
      "ZainCash create payment error",
      response.status,
      data
    );

    throw new HttpsError(
      "unavailable",
      `ZainCash create payment failed (${response.status})`
    );
  }

  return data;
}

async function gatewayInquiry({
  baseUrl,
  accessToken,
  transactionId,
}) {
  const response = await fetch(
    `${baseUrl}/api/v2/payment-gateway/transaction/inquiry/${encodeURIComponent(
      transactionId
    )}`,
    {
      method: "GET",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        Accept: "application/json",
      },
    }
  );

  const raw = await response.text();
  let data;

  try {
    data = JSON.parse(raw);
  } catch (_) {
    data = { raw };
  }

  if (!response.ok) {
    console.error(
      "ZainCash inquiry error",
      response.status,
      data
    );

    throw new HttpsError(
      "unavailable",
      `ZainCash inquiry failed (${response.status})`
    );
  }

  return data;
}

function extractStatus(data) {
  const status = deepFind(
    data,
    [
      "status",
      "transactionStatus",
      "paymentStatus",
    ]
  );

  return status
    ? status.toString().toUpperCase()
    : "UNKNOWN";
}

function extractTransactionId(data) {
  const id = deepFind(
    data,
    [
      "transactionId",
      "transaction_id",
      "id",
    ]
  );

  return id ? id.toString() : "";
}

function extractRedirectUrl(data) {
  const url = deepFind(
    data,
    [
      "redirectUrl",
      "redirect_url",
      "paymentUrl",
      "payment_url",
    ]
  );

  return url ? url.toString() : "";
}

async function findPaymentByTransactionId(
  transactionId
) {
  const snap = await db
    .ref("commercialPayments")
    .orderByChild("transactionId")
    .equalTo(transactionId)
    .get();

  if (!snap.exists() || !snap.val()) {
    return null;
  }

  const entries =
    Object.entries(snap.val());

  if (!entries.length) {
    return null;
  }

  const [paymentId, payment] = entries[0];

  return {
    paymentId,
    payment,
  };
}

async function applyGatewayStatus({
  paymentId,
  payment,
  status,
  gatewayResponse,
}) {
  const now =
    new Date().toISOString();

  const paymentRef =
    db.ref(
      `commercialPayments/${paymentId}`
    );

  const updates = {
    gatewayStatus: status,
    gatewayCheckedAt: now,
    gatewayResponse: gatewayResponse,
  };

  if (status === "SUCCESS") {
    updates.status = "paid";
    updates.paidAt = now;

    const entityType =
      payment.entityType === "ad"
        ? "ad"
        : "service";

    const entityPath =
      entityType === "ad"
        ? `commercialAds/${payment.entityId}`
        : `commercialServices/${payment.entityId}`;

    await db.ref().update({
      [`commercialPayments/${paymentId}/status`]:
        "paid",
      [`commercialPayments/${paymentId}/gatewayStatus`]:
        status,
      [`commercialPayments/${paymentId}/gatewayCheckedAt`]:
        now,
      [`commercialPayments/${paymentId}/paidAt`]:
        now,
      [`${entityPath}/paymentStatus`]:
        "paid",
      [`${entityPath}/status`]:
        "published",
      [`${entityPath}/publishedAt`]:
        now,
    });

    return;
  }

  if (
    status === "FAILED" ||
    status === "EXPIRED"
  ) {
    updates.status = "failed";
  }

  await paymentRef.update(updates);
}

exports.zainCashCreatePayment = onCall(
  {
    region: REGION,
    secrets: [
      ZAINCASH_CLIENT_ID,
      ZAINCASH_CLIENT_SECRET,
    ],
  },
  async (request) => {
    const uid = request.auth?.uid;

    if (!uid) {
      throw new HttpsError(
        "unauthenticated",
        "يجب تسجيل الدخول قبل الدفع"
      );
    }

    const entityType =
      request.data?.entityType === "ad"
        ? "ad"
        : "service";

    const entityId =
      request.data?.entityId?.toString() ?? "";

    if (!entityId) {
      throw new HttpsError(
        "invalid-argument",
        "entityId is required"
      );
    }

    const entityPath =
      entityType === "ad"
        ? `commercialAds/${entityId}`
        : `commercialServices/${entityId}`;

    const entitySnap =
      await db.ref(entityPath).get();

    if (!entitySnap.exists()) {
      throw new HttpsError(
        "not-found",
        "الإعلان غير موجود"
      );
    }

    const entity = entitySnap.val();

    if (entity.ownerUid !== uid) {
      throw new HttpsError(
        "permission-denied",
        "لا يمكنك دفع إعلان لا يعود لك"
      );
    }

    if (entity.status !== "approved") {
      throw new HttpsError(
        "failed-precondition",
        "الإعلان يجب أن يكون مقبولاً قبل الدفع"
      );
    }

    if (entity.paymentStatus === "paid") {
      throw new HttpsError(
        "already-exists",
        "هذا الإعلان مدفوع مسبقاً"
      );
    }

    const approvedPrice =
      Number(entity.approvedPrice);

    if (
      !Number.isFinite(approvedPrice) ||
      approvedPrice <= 0
    ) {
      throw new HttpsError(
        "failed-precondition",
        "السعر المعتمد غير صالح"
      );
    }

    const settings =
      await getSettings();

    if (settings.zainCashEnabled !== true) {
      throw new HttpsError(
        "failed-precondition",
        "ZainCash غير مفعل من مدير النظام"
      );
    }

    const baseUrl =
      baseUrlFromSettings(settings);

    const serviceType =
      (settings.serviceType || "COMMERCIAL_AD")
        .toString()
        .trim() ||
      "COMMERCIAL_AD";

    const paymentId =
      db.ref("commercialPayments")
        .push()
        .key;

    if (!paymentId) {
      throw new HttpsError(
        "internal",
        "تعذر إنشاء رقم عملية الدفع"
      );
    }

    const externalReferenceId =
      crypto.randomUUID();

    const projectId =
      process.env.GCLOUD_PROJECT ||
      process.env.GCP_PROJECT;

    if (!projectId) {
      throw new HttpsError(
        "internal",
        "Firebase project id unavailable"
      );
    }

    const successUrl =
      `https://${REGION}-${projectId}.cloudfunctions.net/zainCashSuccess`;

    const failureUrl =
      `https://${REGION}-${projectId}.cloudfunctions.net/zainCashFailure`;

    const accessToken =
      await getAccessToken(baseUrl);

    const gatewayData =
      await createGatewayPayment({
        baseUrl,
        accessToken,
        language:
          normalizeLanguage(
            request.data?.language
          ),
        externalReferenceId,
        orderId: paymentId,
        serviceType,
        amount: approvedPrice,
        successUrl,
        failureUrl,
      });

    const transactionId =
      extractTransactionId(gatewayData);

    const redirectUrl =
      extractRedirectUrl(gatewayData);

    const status =
      extractStatus(gatewayData);

    if (!transactionId || !redirectUrl) {
      console.error(
        "Incomplete ZainCash init response",
        gatewayData
      );

      throw new HttpsError(
        "data-loss",
        "ZainCash لم يرجع Transaction ID أو redirectUrl"
      );
    }

    const now =
      new Date().toISOString();

    await db
      .ref(`commercialPayments/${paymentId}`)
      .set({
        id: paymentId,
        ownerUid: uid,
        entityType,
        entityId,
        amount: approvedPrice,
        currency: "IQD",
        method: "zainCash",
        status: "initiated",
        gatewayStatus: status,
        transactionId,
        externalReferenceId,
        environment:
          settings.environment === "production"
            ? "production"
            : "test",
        createdAt: now,
        updatedAt: now,
      });

    await db
      .ref(entityPath)
      .update({
        paymentStatus: "initiated",
        zainCashPaymentId: paymentId,
        zainCashTransactionId:
          transactionId,
      });

    return {
      paymentId,
      transactionId,
      redirectUrl,
      status,
    };
  }
);

exports.zainCashInquiry = onCall(
  {
    region: REGION,
    secrets: [
      ZAINCASH_CLIENT_ID,
      ZAINCASH_CLIENT_SECRET,
    ],
  },
  async (request) => {
    const uid = request.auth?.uid;

    if (!uid) {
      throw new HttpsError(
        "unauthenticated",
        "يجب تسجيل الدخول"
      );
    }

    const paymentId =
      request.data?.paymentId?.toString() ?? "";

    if (!paymentId) {
      throw new HttpsError(
        "invalid-argument",
        "paymentId is required"
      );
    }

    const paymentSnap =
      await db
        .ref(
          `commercialPayments/${paymentId}`
        )
        .get();

    if (!paymentSnap.exists()) {
      throw new HttpsError(
        "not-found",
        "عملية الدفع غير موجودة"
      );
    }

    const payment =
      paymentSnap.val();

    if (payment.ownerUid !== uid) {
      throw new HttpsError(
        "permission-denied",
        "عملية الدفع لا تعود لك"
      );
    }

    const transactionId =
      payment.transactionId?.toString() ?? "";

    if (!transactionId) {
      throw new HttpsError(
        "failed-precondition",
        "Transaction ID غير موجود"
      );
    }

    const settings =
      await getSettings();

    const baseUrl =
      baseUrlFromSettings(settings);

    const accessToken =
      await getAccessToken(baseUrl);

    const gatewayData =
      await gatewayInquiry({
        baseUrl,
        accessToken,
        transactionId,
      });

    const status =
      extractStatus(gatewayData);

    await applyGatewayStatus({
      paymentId,
      payment,
      status,
      gatewayResponse: gatewayData,
    });

    return {
      paymentId,
      transactionId,
      status,
      paid: status === "SUCCESS",
    };
  }
);

async function processSignedCallback(
  req,
  res,
  fallbackStatus
) {
  try {
    const token =
      req.query?.token?.toString() ?? "";

    if (!token) {
      res
        .status(400)
        .send("ZainCash callback token missing");
      return;
    }

    const payload =
      jwt.verify(
        token,
        ZAINCASH_API_KEY.value(),
        {
          algorithms: ["HS256"],
        }
      );

    const transactionId =
      extractTransactionId(payload);

    if (!transactionId) {
      res
        .status(400)
        .send("Transaction ID missing");
      return;
    }

    const found =
      await findPaymentByTransactionId(
        transactionId
      );

    if (!found) {
      res
        .status(404)
        .send("Payment not found");
      return;
    }

    const settings =
      await getSettings();

    const baseUrl =
      baseUrlFromSettings(settings);

    const accessToken =
      await getAccessToken(baseUrl);

    const gatewayData =
      await gatewayInquiry({
        baseUrl,
        accessToken,
        transactionId,
      });

    const status =
      extractStatus(gatewayData) ||
      fallbackStatus;

    await applyGatewayStatus({
      paymentId: found.paymentId,
      payment: found.payment,
      status,
      gatewayResponse: gatewayData,
    });

    const success =
      status === "SUCCESS";

    res
      .status(200)
      .set(
        "Content-Type",
        "text/html; charset=utf-8"
      )
      .send(`
        <!doctype html>
        <html dir="rtl" lang="ar">
          <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width,initial-scale=1">
            <title>ZainCash</title>
          </head>
          <body style="font-family:sans-serif;text-align:center;padding:40px">
            <h2>${success ? "تم تأكيد الدفع" : "لم يكتمل الدفع"}</h2>
            <p>الحالة: ${status}</p>
            <p>يمكنك إغلاق هذه الصفحة والرجوع إلى التطبيق.</p>
          </body>
        </html>
      `);
  } catch (error) {
    console.error(
      "ZainCash callback error",
      error
    );

    res
      .status(400)
      .send("Invalid ZainCash callback");
  }
}

exports.zainCashSuccess = onRequest(
  {
    region: REGION,
    secrets: [
      ZAINCASH_CLIENT_ID,
      ZAINCASH_CLIENT_SECRET,
      ZAINCASH_API_KEY,
    ],
  },
  async (req, res) => {
    await processSignedCallback(
      req,
      res,
      "SUCCESS"
    );
  }
);

exports.zainCashFailure = onRequest(
  {
    region: REGION,
    secrets: [
      ZAINCASH_CLIENT_ID,
      ZAINCASH_CLIENT_SECRET,
      ZAINCASH_API_KEY,
    ],
  },
  async (req, res) => {
    await processSignedCallback(
      req,
      res,
      "FAILED"
    );
  }
);

exports.zainCashWebhook = onRequest(
  {
    region: REGION,
    secrets: [
      ZAINCASH_CLIENT_ID,
      ZAINCASH_CLIENT_SECRET,
      ZAINCASH_API_KEY,
    ],
  },
  async (req, res) => {
    try {
      const webhookToken =
        req.body?.webhook_token?.toString() ?? "";

      if (!webhookToken) {
        res.status(400).send("missing token");
        return;
      }

      const payload =
        jwt.verify(
          webhookToken,
          ZAINCASH_API_KEY.value(),
          {
            algorithms: ["HS256"],
          }
        );

      const eventId =
        deepFind(
          payload,
          ["eventId", "event_id"]
        )?.toString() ?? "";

      if (eventId) {
        const eventRef =
          db.ref(
            `zainCashWebhookEvents/${eventId}`
          );

        const eventSnap =
          await eventRef.get();

        if (eventSnap.exists()) {
          res.status(200).send("duplicate");
          return;
        }

        await eventRef.set({
          receivedAt:
            new Date().toISOString(),
        });
      }

      const transactionId =
        extractTransactionId(payload);

      if (!transactionId) {
        res
          .status(400)
          .send("missing transaction id");
        return;
      }

      const found =
        await findPaymentByTransactionId(
          transactionId
        );

      if (!found) {
        res.status(200).send("payment not found");
        return;
      }

      const settings =
        await getSettings();

      const baseUrl =
        baseUrlFromSettings(settings);

      const accessToken =
        await getAccessToken(baseUrl);

      const gatewayData =
        await gatewayInquiry({
          baseUrl,
          accessToken,
          transactionId,
        });

      const status =
        extractStatus(gatewayData);

      await applyGatewayStatus({
        paymentId: found.paymentId,
        payment: found.payment,
        status,
        gatewayResponse: gatewayData,
      });

      res.status(200).send("ok");
    } catch (error) {
      console.error(
        "ZainCash webhook error",
        error
      );

      res.status(400).send("invalid webhook");
    }
  }
);
