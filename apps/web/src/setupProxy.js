const { createProxyMiddleware } = require('http-proxy-middleware');
const path = require('path');

require('dotenv').config({ path: path.join(__dirname, '../../../.env') });

module.exports = function(app) {
  app.post(
    '*',
    createProxyMiddleware({
      target: process.env.WEB_PROXY_URL,
      changeOrigin: true,
    })
  );
};
