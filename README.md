# Quote Editor

A Rails application for creating and managing customer quotes. Each quote is a
collection of line items (name, quantity, unit price, VAT rate); totals are
computed live as items are added, edited, or removed. Once a quote is
validated it becomes immutable.

The UI is rendered with Hotwire (Turbo + Stimulus) and styled with Tailwind
CSS, so quote-list updates and total recalculations happen without full page
reloads.

The choice was made to use the **full Rails 7.2 stack** — sticking to the
framework's defaults to keep things simple, sustainable, and aligned with
the broader Rails ecosystem.

## Tech stack

- **Ruby** 3.4.7
- **Rails** 7.2.1
- **PostgreSQL** (Active Record)
- **Hotwire** — Turbo Streams (broadcast over Action Cable) and Stimulus
- **Tailwind CSS** via `tailwindcss-rails`
- **Importmap** for JavaScript (no Node/Yarn build step required)
- **Minitest** + Capybara + Selenium for unit, integration and system tests
- **I18n** — French (default) and English

## Prerequisites

Make sure the following are installed and running on your machine:

- Ruby 3.4.7
- Bundler
- PostgreSQL

## Getting started

```bash
# 1. Clone the repository
git clone <repository-url>
cd quote_editor

# 2. Install Ruby gems
bundle install

# 3. Create, migrate, and seed the database
bin/rails db:setup
```

`db:setup` creates `quote_editor_development` and `quote_editor_test`, runs
the migrations, then loads `db/seeds.rb` which inserts a handful of draft and
validated quotes (using Faker) so you have something to play with right away.

## Running the app

The app runs two processes in development: the Rails server and the Tailwind
CSS watcher. A `Procfile.dev` is provided and `bin/dev` starts both at once
through Foreman:

```bash
bin/dev
```

Then open http://localhost:3000.

If you prefer to start them individually :

```bash
bin/rails server
bin/rails tailwindcss:watch
```

## Routes overview

The app is mounted under an optional locale scope (`/fr/...` or `/en/...`,
default `fr`):

- `GET  /`                                → list of quotes
- `GET  /quotes/new` · `POST /quotes`     → create a quote
- `PATCH /quotes/:id`                     → update a quote
- `PATCH /quotes/:id/validate`            → mark a quote as validated
- `resources :quote_items` nested under a quote, for adding / editing /
  deleting line items inline via Turbo Streams

## Testing

The full test suite (models, controllers, integration, system):

```bash
bin/rails test          # unit + integration tests
```

Run a single file or a single test:

```bash
bin/rails test test/models/quote_test.rb
bin/rails test test/models/quote_test.rb:42
```

## Code quality and security

Two static-analysis tools are bundled in the `:development, :test` group:

```bash
bundle exec rubocop      # Omakase Ruby style — add `-A` to autofix
bundle exec brakeman     # Static security scanner
```

Both are expected to run clean before committing.

## Internationalization

Locale files live in `config/locales/` (split per concern: `controllers/`,
`models/`, `views/`, plus root `fr.yml` / `en.yml`). The default locale is
`fr`; switch by prefixing the URL with `/en` (e.g.
`http://localhost:3000/en/quotes`).

To add a new locale, create the corresponding YAML files and add the locale
symbol to `config.i18n.available_locales` in `config/application.rb`.

## Useful commands

```bash
bin/rails console        # Rails REPL
bin/rails db:migrate     # apply pending migrations
bin/rails db:reset       # drop, create, migrate, seed
bin/rails routes         # list all routes
bin/rails assets:precompile   # build production assets locally
```

## Roadmap

Upcoming evolutions and planned features are tracked on Notion:
[Quote Editor Roadmap](https://www.notion.so/Quote-Editor-Roadmap-35150b7d6dcc80a4a92af34d2fca447c?source=copy_link).
