Package.describe({
  summary: "Icon package for lemonEngine",
  version: "1.0.0",
  git: ""
});

Package.onUse(function(api) {
  api.versionsFrom('METEOR@1.1.0.2');

  api.addFiles([
    'lib/font/lemon.eot',
    'lib/font/lemon.svg',
    'lib/font/lemon.ttf',
    'lib/font/lemon.woff',
    'lib/css/lemon-embedded.css'
    //'lib/lemon.overrides.css'
    ], 'client');
});