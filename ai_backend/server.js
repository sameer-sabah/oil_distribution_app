import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import fs from "fs";
import path from "path";
import crypto from "crypto";
import { fileURLToPath } from "url";

dotenv.config();

const app = express();

const PORT = Number(process.env.PORT || 8080);
const OPENAI_API_KEY = process.env.OPENAI_API_KEY;

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const publicDir = path.join(__dirname, "public");
const generatedDir = path.join(publicDir, "generated");

fs.mkdirSync(generatedDir, {
  recursive: true,
});

app.use(cors());

app.use(
  express.json({
    limit: "2mb",
  }),
);

app.use(
  "/generated",
  express.static(generatedDir),
);

function clean(value, maxLength = 500) {
  return String(value ?? "")
    .trim()
    .slice(0, maxLength);
}

function mapImageSize(aspectRatio) {
  const value = clean(aspectRatio, 50);

  if (
    value.includes("4:5") ||
    value.includes("طولي")
  ) {
    return "1024x1536";
  }

  if (
    value.includes("16:9") ||
    value.includes("أفقي")
  ) {
    return "1536x1024";
  }

  return "1024x1024";
}

function buildPrompt({
  category,
  businessName,
  description,
  location,
  style,
  aspectRatio,
}) {
  const common = `
أنشئ صورة إعلان تجاري احترافية مخصصة لتطبيق موبايل.

اسم النشاط:
${businessName}

نوع النشاط:
${category}

وصف النشاط:
${description}

الموقع:
${location || "غير محدد"}

أسلوب التصميم:
${style || "احترافي"}

نسبة التصميم:
${aspectRatio || "1:1"}

متطلبات مهمة:
- تصميم تجاري احترافي وعالي الجودة.
- اجعل العنصر الرئيسي واضحاً وجذاباً.
- مناسب للإعلانات داخل تطبيق موبايل.
- لا تخترع رقم هاتف أو عنوان أو سعر.
- لا تضف شعارات شركات غير مطلوبة.
- لا تضف علامات مائية.
- لا تضف معلومات غير موجودة في الطلب.
`;

  switch (category) {
    case "مطاعم وأطعمة":
      return `${common}

متطلبات خاصة بالمطعم:
- أظهر أطعمة شهية وواقعية.
- تصوير طعام احترافي.
- إضاءة جذابة ودافئة.
- تقديم الطعام بشكل فاخر.
- خلفية مناسبة لمطعم حديث.
- اترك مساحة بصرية مناسبة لاسم النشاط.
`;

    case "سيارات ومعارض":
      return `${common}

متطلبات خاصة بالسيارات:
- سيارة حديثة بتصوير إعلاني احترافي.
- معرض أنيق أو خلفية حضرية مناسبة.
- انعكاسات وإضاءة واقعية.
- إحساس فاخر وحديث.
`;

    case "عقارات":
      return `${common}

متطلبات خاصة بالعقارات:
- عقار أو منزل حديث.
- إضاءة معمارية جميلة.
- مظهر واقعي وفاخر.
- تصميم مناسب لإعلان عقاري احترافي.
`;

    case "عيادات ومراكز طبية":
      return `${common}

متطلبات خاصة بالمجال الطبي:
- بيئة طبية نظيفة وحديثة.
- مظهر احترافي وهادئ.
- تجنب الصور المزعجة أو العمليات الطبية.
- مناسب لعيادة أو مركز صحي.
`;

    case "صيدليات":
      return `${common}

متطلبات خاصة بالصيدلية:
- صيدلية حديثة ونظيفة.
- رفوف ومنتجات صيدلانية عامة.
- مظهر موثوق واحترافي.
- لا تعرض أسماء أدوية تجارية غير مطلوبة.
`;

    case "ملابس وأزياء":
      return `${common}

متطلبات خاصة بالأزياء:
- ستايل عصري.
- عرض ملابس بطريقة تجارية أنيقة.
- إضاءة تصوير أزياء احترافية.
- مظهر مناسب لإعلان متجر.
`;

    case "إلكترونيات":
      return `${common}

متطلبات خاصة بالإلكترونيات:
- أجهزة إلكترونية حديثة.
- خلفية تقنية وعصرية.
- إضاءة احترافية.
- لا تستخدم شعارات علامات تجارية غير مطلوبة.
`;

    case "صالونات وتجميل":
      return `${common}

متطلبات خاصة بالتجميل:
- بيئة أنيقة وفاخرة.
- أدوات وعناصر تجميل مناسبة.
- أجواء هادئة وعصرية.
`;

    default:
      return `${common}

صمم المشهد بناءً على وصف النشاط ونوعه بشكل تجاري مناسب.
`;
  }
}

app.get("/", (req, res) => {
  res.json({
    success: true,
    service: "Oil Product Window AI Image Backend",
    status: "running",
  });
});

app.get("/health", (req, res) => {
  res.json({
    success: true,
    status: "ok",
  });
});

app.post(
  "/generate-ad-image",
  async (req, res) => {
    try {
      if (!OPENAI_API_KEY) {
        return res.status(500).json({
          success: false,
          imageUrl: "",
          message:
            "OPENAI_API_KEY غير موجود في إعدادات السيرفر.",
        });
      }

      const category = clean(
        req.body.category,
        100,
      );

      const businessName = clean(
        req.body.businessName,
        150,
      );

      const description = clean(
        req.body.description,
        1000,
      );

      const location = clean(
        req.body.location,
        300,
      );

      const style = clean(
        req.body.style,
        100,
      );

      const aspectRatio = clean(
        req.body.aspectRatio,
        50,
      );

      if (!category) {
        return res.status(400).json({
          success: false,
          imageUrl: "",
          message:
            "نوع النشاط مطلوب.",
        });
      }

      if (!businessName) {
        return res.status(400).json({
          success: false,
          imageUrl: "",
          message:
            "اسم النشاط مطلوب.",
        });
      }

      if (!description) {
        return res.status(400).json({
          success: false,
          imageUrl: "",
          message:
            "وصف الإعلان مطلوب.",
        });
      }

      const prompt = buildPrompt({
        category,
        businessName,
        description,
        location,
        style,
        aspectRatio,
      });

      const size =
        mapImageSize(aspectRatio);

      console.log(
        `Generating image for: ${businessName}`,
      );

      const openAiResponse =
        await fetch(
          "https://api.openai.com/v1/images/generations",
          {
            method: "POST",

            headers: {
              Authorization:
                `Bearer ${OPENAI_API_KEY}`,

              "Content-Type":
                "application/json",
            },

            body: JSON.stringify({
              model: "gpt-image-2",
              prompt,
              size,
              quality: "medium",
              n: 1,
            }),
          },
        );

      const responseData =
        await openAiResponse.json();

      if (!openAiResponse.ok) {
        console.error(
          "OpenAI error:",
          responseData,
        );

        const apiMessage =
          responseData?.error?.message ||
          "تعذر توليد الصورة.";

        return res.status(
          openAiResponse.status,
        ).json({
          success: false,
          imageUrl: "",
          message: apiMessage,
        });
      }

      const imageData =
        responseData?.data?.[0];

      if (!imageData) {
        return res.status(502).json({
          success: false,
          imageUrl: "",
          message:
            "خدمة الصور لم ترجع نتيجة.",
        });
      }

      let imageBuffer;

      if (imageData.b64_json) {
        imageBuffer = Buffer.from(
          imageData.b64_json,
          "base64",
        );
      } else if (imageData.url) {
        const imageResponse =
          await fetch(imageData.url);

        if (!imageResponse.ok) {
          throw new Error(
            "تعذر تنزيل الصورة المولدة.",
          );
        }

        const arrayBuffer =
          await imageResponse.arrayBuffer();

        imageBuffer =
          Buffer.from(arrayBuffer);
      } else {
        return res.status(502).json({
          success: false,
          imageUrl: "",
          message:
            "صيغة الصورة المستلمة غير مدعومة.",
        });
      }

      const fileName =
        `ad_${Date.now()}_${crypto
          .randomBytes(5)
          .toString("hex")}.png`;

      const outputPath =
        path.join(
          generatedDir,
          fileName,
        );

      fs.writeFileSync(
        outputPath,
        imageBuffer,
      );

      const protocol =
        req.headers[
          "x-forwarded-proto"
        ] || req.protocol;

      const host =
        req.get("host");

      const imageUrl =
        `${protocol}://${host}/generated/${fileName}`;

      console.log(
        `Image generated: ${imageUrl}`,
      );

      return res.json({
        success: true,
        imageUrl,
        message:
          "تم إنشاء الصورة بنجاح.",
      });
    } catch (error) {
      console.error(
        "Generate image error:",
        error,
      );

      return res.status(500).json({
        success: false,
        imageUrl: "",
        message:
          `تعذر توليد الصورة: ${error.message}`,
      });
    }
  },
);

app.listen(
  PORT,
  "0.0.0.0",
  () => {
    console.log(
      "====================================",
    );

    console.log(
      `AI Backend running on port ${PORT}`,
    );

    console.log(
      `Local URL: http://localhost:${PORT}`,
    );

    console.log(
      "====================================",
    );
  },
);