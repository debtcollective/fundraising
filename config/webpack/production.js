process.env.NODE_ENV = process.env.NODE_ENV || 'production'

const environment = require('./environment')
const SentryCliPlugin = require('@sentry/webpack-plugin')

// Only generate sentry releases when Senry is configured
if (process.env.SENTRY_RELEASE && process.env.SENTRY_AUTH_TOKEN) {
  const release = process.env.SENTRY_RELEASE

  environment.plugins.append(
    'sentry',
    new SentryCliPlugin({
      ignore: ['node_modules', 'webpack.config.js', 'vendor'],
      include: ['app/javascript', 'public/assets'],
      release,
      setCommits: {
        repo: 'https://github.com/debtcollective/membership.git'
      }
    })
  )
}

module.exports = environment.toWebpackConfig()
