# AGENTS.md

Flutter storefront + admin app (`crabpay`) backed by Supabase (Auth, pg_graphql, Realtime) and an external payment server.

Only Android and web are supported targets. Treat `linux/`, `macos/`, `windows/`, and `ios/` as out of scope; don't build or fix them.

## Required local config (gitignored)
A fresh clone does not compile until these exist:
- `lib/core/backend/supabase/supabase_conf.dart` → `const Map<String, String> supabaseAccessConf = {'url': ..., 'publishableKey': ...};`
- `lib/core/backend/pyament_services/payment_server_conf.dart` → `final String linkToThePaymentServer = '...';`

Never commit or print real keys.

## Secrets
- `.gitignore` covers `.env*`, `google-services.json`, `key.properties`, keystores, `sentry.properties`, and the two `*_conf.dart` files. Keep it that way.
- `android/app/google-services.json` was committed in old history (removed from HEAD). The repo is public; rotate/restrict its Firebase API key and consider history rewriting.

## Commands
- `flutter pub get` — installs deps. After ARB edits run `flutter gen-l10n` to regenerate the committed `lib/l10n/app_localizations*.dart`.
- `flutter analyze` — primary verification; excludes `build/` and all platform directories. Baseline is 0 errors/warnings but ~100 `deprecated_member_use` infos for `package:flutter/material.dart`. Don't chase that noise or bulk-migrate to `material_ui`.
- `flutter build web` — web compile check.
- `flutter build apk --debug` — Android compile check.
- `dart format .` — style is non-default: `page_width: 256`, `trailing_commas: preserve` from `analysis_options.yaml`. Don't reflow long lines by hand.
- `flutter test` — 286 unit tests (blocs, cubits, outer handlers, models) all pass. Uses `bloc_test` + `mocktail`; helpers live in `test/helpers/`. Outer handlers accept optional injected clients for testing; production wiring in `get_it.dart` uses the defaults.
- No CI, Makefile, build_runner, or codegen besides l10n.

## Architecture
- Backend splits into `*_inner_circle` (abstract handler interfaces, models, blocs/events/states) and `*_outer_circle` (Supabase/HTTP implementations). Depend on the inner interface; implementations are registered in `lib/core/set_up/get_it.dart`.
- `lib/core/set_up/app_providers.dart` exposes handlers via `RepositoryProvider` and creates the global blocs (`AuthBloc`, `DatabaseBloc`, `CartBloc`, `ChatBloc`, admin variants, `PaymentBloc`). Read with `context.read`/`context.watch`. A new handler/bloc must be wired here too; get_it registration alone does not put it in the widget tree.
- Screens use `driver/` + `view/material/`: the `*Driver` is a `StatefulWidget` that owns the page cubit and wires blocs; the material view is pure UI. Routes point at drivers.
- Postgres CRUD goes through pg_graphql (`SupabaseGraphQLClient`; camelCase collections such as `productCollection`, `cartItemCollection`, `userPreferenceCollection`). Realtime `.from(...).stream(...)` is used for cart counters and pending payments. Supabase Auth sits behind `AuthInnerInterface`.
- All route paths/names live in the `AppRoutes` enum (`lib/core/app_routes/app_routes.dart`). Add a route there, then register it in `main_screen_routes.dart`, `admin_routes.dart`, `auth_routes.dart`, or `other_routes.dart`; `app_router.dart` composes them.
- Use `context.appColorScheme` (`views/custom_ui_elements/utilities/ui_utilities.dart`). `AppTheme.light/dark` exist, but `theme:`/`darkTheme:` are commented out in `main.dart`.
- Admin UI lives under `views/main_screen/_sub/admin_views`; `adminShellRoute` in `admin_routes.dart` wraps it in `AdminBloc`.

## Engineering standards
- **Preserve and enforce layer boundaries.**
  - Backend: new features follow `<domain>_inner_circle` (`Inner<Domain>Handler`, models, `<domain>_bloc/`) and `<domain>_outer_circle` (`Outer<Domain>HandlerWithSupabase` or outer impl). Never import Supabase/HTTP/storage details into inner circles or views. Wire new handlers/blocs in both `get_it.dart` and `app_providers.dart`.
  - UI: screens use `<feature>/driver/<feature>_driver.dart` (`<Feature>Driver` + `<Feature>Cubit`) and `<feature>/view/material/material_<feature>.dart` (`Material<Feature>`), with sub-features under `_sub/`.
  - `Driver` owns cubit/bloc wiring, side effects, navigation, and controller disposal (read global blocs via `context.read`/`context.watch`, not constructor passing). `Material*` views stay pure UI—receive state and callbacks, never talk to services or blocs directly.
- **Canonical naming (new code).**
  - Follow `<feature>_driver.dart` / `material_<feature>.dart` / `<feature>_cubit.dart` and `<domain>_bloc.dart` / `<domain>_event.dart` / `<domain>_state.dart` (singular).
  - Do not copy legacy quirks (`*_og.dart`, `dbBLoc` params, global `supabase` variable, misspelled paths), and do not rename existing legacy files unless asked.
- **Senior UI/UX bar (Android + Web).**
  - Reuse `views/custom_ui_elements/` (`widgets/`, `dialogs/`, shimmer/pulsing placeholders, `app_layout.dart`'s `maxWidth`, `globalCornerRadius`/`inRadius`), `context.appColorScheme`, and `context.l10n`. No hardcoded colors, raw user-facing strings, or one-off duplicates.
  - Handle all four UI states explicitly: **loading** (shimmer/placeholder, no blank flash), **empty** (clear guidance + action), **error** (friendly message + retry/recovery, never raw exceptions), and **content**.
  - Protect mutations: immediate visual feedback, prevent duplicate submits while in flight, preserve user input/cart on failure.
  - Polish layout & ergonomics: responsive on narrow Android screens and wide web viewports, respect `SafeArea`/keyboard insets, no overflow at larger text scales, 48×48 min tap targets, and visible hover/focus states on web.
- **Clean, maintainable code.**
  - Keep `build()` methods small and composable (split into private widgets or `_sub/`). Use `BlocSelector` / scoped builders to avoid unnecessary rebuilds.
  - Keep changes minimal and scoped; don't introduce speculative abstractions or unrelated refactors.
  - Verify with `dart format` on changed files, `flutter analyze`, and targeted tests (`flutter test test/<file>_test.dart`) for non-trivial logic (cart totals, pricing, payment/order state).

## Tooling
- The Dart MCP server is configured globally (`opencode mcp list` shows `dart connected`). In Code Mode use `tools.dart.*`; connect to a DTD instance before hot reload, runtime-error, or widget-inspector tools.

## Localization
- ARBs: `lib/l10n/app_en.arb` (template) and `app_ru.arb`. Add every key to both.
- Generated `app_localizations*.dart` are committed. After ARB edits run `flutter gen-l10n` and commit the regenerated files.
- Use `context.l10n.key` (`core/extensions/l10n_extension.dart`), not raw `Text('...')`.
- `main.dart` hardcodes `locale: Locale('ru')`; `GlobalLanguageCubit` only drives the settings toggle and is not connected to `MaterialApp`.
- `tool/*.dart` are destructive one-off codemods (`extract_strings.dart` overwrites `app_en.arb`; `replace_strings.dart` rewrites `Text(...)` across `lib/`). Don't run them without a clear reason.

## Gotchas
- Anonymous auth is the default: `AppLocalStorage` creates a temp user id, and `AuthBloc` may hold an anonymous/temp user while "logged out".
- All `build/` directories are generated; never edit them.
- Markdown uses `flutter_markdown` because `flutter_markdown_latex` depends on it. `flutter_markdown` is discontinued in favor of `flutter_markdown_plus`, but migrating requires replacing the LaTeX extension; don't swap it casually.
- Before commercial release: replace the debug signing config in `android/app/build.gradle.kts` with a real keystore, change the `com.example.crabpay` application ID/namespace, and review `android:usesCleartextTraffic="true"` in `AndroidManifest.xml`.
- Some legacy code hardcodes the Supabase host (`supabase/supanase_server.dart`); prefer `SupabaseGraphQLClient`/`supabaseAccessConf`. The repo also misspells `pyament_services` and `supanase_server.dart`; don't rename them casually.
