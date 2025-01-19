import en from "./en";
import es from "./es";

// Define your translations
const translations: any = { en, es };

class I18nService {
  // State for the current locale
  locale = $state(this.getInitialLocale());

  // Create translation function using $derived
  translate = $derived((key: string, params?: Record<string, any>) => {
    const keys = key.split(".");
    let value = translations[this.locale];
    for (const k of keys) {
      value = value[k];
      if (!value) break;
    }

    if (typeof value === "string" && params) {
      return Object.entries(params).reduce((acc, [k, v]) => {
        return acc.replace(new RegExp(`{${k}}`, "g"), v.toString());
      }, value);
    }

    return value || key;
  });

  constructor() {
    // Effect to update localStorage when locale changes
    $effect(() => {
      if (typeof window !== "undefined") {
        localStorage.setItem("locale", this.locale);
      }
    });
  }

  private getInitialLocale(): string {
    if (typeof window !== "undefined") {
      const storedLocale = localStorage.getItem("locale");
      if (storedLocale && (storedLocale === "en" || storedLocale === "es")) {
        return storedLocale;
      }
    }
    return "en";
  }

  setLocale(newLocale: string) {
    if (newLocale === "en" || newLocale === "es") {
      this.locale = newLocale;
    } else {
      console.error('Invalid locale. Supported locales are "en" and "es".');
    }
  }

  getLocale(): string {
    return this.locale;
  }
}

// Create singleton instance
const i18n = new I18nService();

// Create a store-compatible interface for the translation function
export const t = {
  subscribe: (
    fn: (val: (key: string, params?: Record<string, any>) => string) => void,
  ) => {
    let stop = false;
    fn(i18n.translate);

    $effect(() => {
      if (!stop) {
        fn(i18n.translate);
      }
    });

    return () => {
      stop = true;
    };
  },
};

// Export other functions
export const setLocale = (locale: string) => i18n.setLocale(locale);
export const getLocale = () => i18n.getLocale();
