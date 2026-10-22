# Druid — app

App Flutter di Druid. Documentazione e regole del progetto nel repo `core` (cartella superiore):
`../CLAUDE.md` e `../docs/architettura-app.md`.

```bash
cp env/sviluppo.example.json env/sviluppo.json   # inserire la chiave Pl@ntNet
flutter pub get
flutter test
flutter run -t lib/main_sviluppo.dart --dart-define-from-file=env/sviluppo.json
```
