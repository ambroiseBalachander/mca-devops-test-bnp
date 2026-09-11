# Frontend

## Prerequisite

Install Node.js and npm.

Install dependencies:

```shell
npm install
```

## Local development

Launch the application:

```shell
ng serve
```

Navigate to `http://localhost:4200/`.

The application will automatically reload if you change any of the source files.

## Production

Set the backend API URL in `src/environments/environment.ts`.

Build the application:

```shell
ng build
```

Expose with a web server (nginx, apache httpd, ...) the folder `dist/frontend/browser/`.

E.g. for local test: `python -m http.server -d dist/frontend/browser/`
