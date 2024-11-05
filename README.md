# Svelte 5 Template

An opinionated development template designed to create large-scale business apps quickly and deploy them as a static website, iOS App, Android App, Windows Desktop App, MacOS Desktop App, and Linux Desktop App.

### Design Philosophy

- client-side code only
  - reduces complexity
  - eliminates middle tier code for faster development
  - increases scalability (no middle tier bottleneck)
- svelte 5
  - easy development enviroment
  - fast, small, compiled application
  - easy and free to deploy as a static site
- shadcn-svelte
  - great-looking UI
  - flexible
  - large community
- modular, organized code base
  - designed for large-scale, complex business projects
  - authentication
  - data access layer
  - simple, reusable components
- automated deployment
  - static web site
  - mobile apps: ios, android
  - desktop apps: windows, macos, linux

## Tecnologies

- [Svelte 5](https://svelte.dev/docs/svelte/overview)
- [SvelteKit](https://svelte.dev/docs/kit/introduction)
- [Tailwindcss](https://tailwindcss.com/docs/installation)
- [Shadcn-svelte](https://next.shadcn-svelte.com/docs)

## Developer Aids

- Global constants such as `__APP_VERSION__` declared in [package.json](/package.json) See: [app.d.ts](./src/app.d.ts)
- [Internationalization](./src/lib/i18n/index.ts)
  - [English](./src/lib/i18n/en.ts)
  - [Spanish](./src/lib/i18n/es.ts)
- App setup script: [setup-apps.sh](./setup-apps.sh)
  - Initializes [Ionic Capacitor](https://capacitorjs.com/docs/getting-started)
  - Sets up ios
  - Sets up android
  - Creates icons (see [make-icons.sh](./make-icons.sh))
  - Copies icons for ios/android (see [update-app-icons.sh](./update-app-icons.sh))
- Icon build system
  - [make-icons.sh](./make-icons.sh) creates all icons from a base icon svg file [icon.svg](./static/icon.svg)
  - [update-app-icons.sh](./update-app-icons.sh) copies icons needed for `ios` and `android` app versions

## Development Targets

- Web Dev: `npm run dev` or `./dev.sh`
- iOS: `npm run ios`
- iOS with instant reload: `npm run ios-reload`
  - requires `npm run dev` server running on port 5172
- Android: `npm run android`
- Android with instant reload `npm run android-reload`
  - requires `npm run dev` server running on port 5172

## Deploy Targets

- Static Web Site: `npm run build`

## Implementation Notes

- All client-side code

## How to Set Up Keys

- Server URL and ANON_KEY are encrypted (for obfuscation)
  - `cp .keys.json.sample .keys.json`
  - enter your URL and ANON_KEY in `.keys.json`
  - run: `deno run --allow-read --allow-write lock-up-keys.deno.ts`
