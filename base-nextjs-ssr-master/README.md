# Next.js with Server-side Rendering

Using Light Modules with SPA rendering (Next.js with Server-side Rendering).  
Next.js on Node.js server.

## Demo

Demo site is based on `minimal-headless-spa-demos` project.  
This project can be found [here](https://git.magnolia-cms.com/projects/DEMOS/repos/minimal-headless-spa-demos/browse).

## Settings

### `.gitlab-ci.yml`

Modify following variables to match your URLs:

- `AUTHOR_MGNL_HOST`
- `PUBLIC_MGNL_HOST`

### Page template definitions

Update `baseUrl` property to match your Author SPA URL in following files:

- /light-modules/nextjs-ssr-minimal-lm/templates/pages/basic.yaml
- /light-modules/nextjs-ssr-minimal-lm/templates/pages/contact.yaml

### `Security App`

In order for images to be displayed

1. Open the `Security App`
2. Open the `Roles `tab
3. Edit the `rest-anonymous `role
4. Go to `Web access` tab
5. Add new with this path `/dam/*` set to `GET`

### `Site App`

In `Site App` import into `fallback` the provided `config.modules.multisite.config.sites.fallback.i18n.yaml` file.

## How to use

In `Pages App` create a root page named `nextjs-ssr-minimal` with `Next.js SSR: Basic` template.
