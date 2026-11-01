# Демо NatureHub на Vercel (ваш аккаунт)

## Быстрый путь (рекомендуется для показа покупателю)

1. Локально:
   ```bash
   flutter build web --release
   ```
2. Войдите в свой Vercel:
   ```bash
   npx vercel login
   ```
3. Задеплойте статику:
   ```bash
   npx vercel ./build/web --prod
   ```
4. Скопируйте выданный URL (`*.vercel.app`) и отправьте покупателю.

## Автодеплой с GitHub

1. Запушьте репозиторий на GitHub.
2. На [vercel.com](https://vercel.com) под своим аккаунтом: **New Project** → Import repo.
3. Framework: **Other**, Build: `bash tool/vercel_build.sh`, Output: `build/web`  
   (или подхватится из `vercel.json`).
4. Deploy → ссылка в дашборде.

## Важно для демо

- Данные хранятся в браузере посетителя (Hive / IndexedDB), не на общем сервере.
- Голосовые сообщения в web-демо отключены; карта/погода нуждаются в сети.
- Админ-панель: имя пользователя `albert`.
