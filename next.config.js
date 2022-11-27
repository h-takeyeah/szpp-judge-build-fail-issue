const { PHASE_PRODUCTION_BUILD } = require('next/constants')

/** @type {import('next').NextConfig} */
const sharedConfig = {
  reactStrictMode: true,
  swcMinify: true
}

/**
 * @param {string} phase
 * @param {any} _
 */
module.exports = (phase, { defaultConfig }) => {
  if (phase === PHASE_PRODUCTION_BUILD) {
    /** @type {import('next').NextConfig} */
    const buildConfig = {
      ...sharedConfig,
      output: 'standalone' // for docker image size optimization
    }
    return buildConfig
  } else {
    return sharedConfig
  }
}
