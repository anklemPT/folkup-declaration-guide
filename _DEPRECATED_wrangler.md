# wrangler.toml deprecated 2026-06-03

The previous `wrangler.toml` (now `wrangler.toml.disabled`) used Workers-style
configuration (`account_id`, `[[routes]]`) which is invalid for CF Pages
projects. It was a leftover from a never-completed CF Pages migration attempt
(per Кочегар triage 2026-06-03 — `.wrangler/tmp/` was empty, no deployment
history).

The current CF Pages deployment uses `.github/workflows/deploy-cf-backup.yml`
which invokes `wrangler pages deploy dist --project-name=declaration-backup`
explicitly without relying on the config file.

To remove the disabled file completely: `git rm wrangler.toml.disabled` once
this transition is reviewed and accepted.
