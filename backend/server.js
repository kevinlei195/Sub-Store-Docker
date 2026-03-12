const express = require('express');
const cron = require('cron');
const path = require('path');
const fs = require('fs');
const { spawn } = require('child_process');

require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

const BACKEND_FILE = process.env.BACKEND_FILE || '/app/backend/sub-store.min.js';
const FRONTEND_DIR = process.env.FRONTEND_DIR || '/app/frontend/dist';

const BACKEND_PATH = process.env.SUB_STORE_FRONTEND_BACKEND_PATH || '';
const BACKEND_URL = process.env.SUB_STORE_FRONTEND_BACKEND_URL || '';
const AUTH_TOKEN = process.env.AUTH_TOKEN || '';

const SYNC_CRON = process.env.SUB_STORE_BACKEND_SYNC_CRON || '';
const REFRESH_CRON = process.env.SUB_STORE_BACKEND_REFRESH_CRON || '';
const UPLOAD_CRON = process.env.SUB_STORE_BACKEND_UPLOAD_CRON || '';
const DOWNLOAD_CRON = process.env.SUB_STORE_BACKEND_DOWNLOAD_CRON || '';

console.log('=== Sub-Store Configuration ===');
console.log(`Port: ${PORT}`);
console.log(`Backend File: ${BACKEND_FILE}`);
console.log(`Frontend Dir: ${FRONTEND_DIR}`);
console.log(`Backend Path: ${BACKEND_PATH || '(none)'}`);
console.log(`Backend URL: ${BACKEND_URL || '(none)'}`);
console.log(`Sync Cron: ${SYNC_CRON || '(disabled)'}`);
console.log(`Refresh Cron: ${REFRESH_CRON || '(disabled)'}`);
console.log(`Upload Cron: ${UPLOAD_CRON || '(disabled)'}`);
console.log(`Download Cron: ${DOWNLOAD_CRON || '(disabled)'}`);
console.log('================================');

const backendModule = require(BACKEND_FILE);
const backendApp = typeof backendModule === 'function' 
  ? backendModule 
  : (backendModule.default || backendModule.backend || Object.values(backendModule)[0]);

if (typeof backendApp === 'function') {
  backendApp(app);
} else {
  console.error('Failed to load Sub-Store backend module');
  process.exit(1);
}

function makeApiRequest(endpoint, label) {
  const url = `http://127.0.0.1:${PORT}${endpoint}`;
  const args = ['-s', url];
  
  if (AUTH_TOKEN) {
    args.push('-H', `Authorization: Bearer ${AUTH_TOKEN}`);
  }
  
  const proc = spawn('curl', args);
  
  proc.stdout.on('data', (data) => {
    console.log(`[${label}] Response: ${data.toString().trim()}`);
  });
  
  proc.stderr.on('data', (data) => {
    console.error(`[${label}] Error: ${data.toString().trim()}`);
  });
  
  proc.on('close', (code) => {
    console.log(`[${label}] Completed with code ${code}`);
  });
}

if (SYNC_CRON) {
  cron.schedule(SYNC_CRON, () => {
    console.log('[Cron] Running sync artifacts...');
    makeApiRequest('/api/sync/artifacts', 'SYNC');
  });
  console.log(`Sync cron scheduled: ${SYNC_CRON}`);
}

if (REFRESH_CRON) {
  cron.schedule(REFRESH_CRON, () => {
    console.log('[Cron] Running refresh...');
    makeApiRequest('/api/utils/refresh', 'REFRESH');
  });
  console.log(`Refresh cron scheduled: ${REFRESH_CRON}`);
}

if (UPLOAD_CRON) {
  cron.schedule(UPLOAD_CRON, () => {
    console.log('[Cron] Running upload...');
    makeApiRequest('/api/utils/upload', 'UPLOAD');
  });
  console.log(`Upload cron scheduled: ${UPLOAD_CRON}`);
}

if (DOWNLOAD_CRON) {
  cron.schedule(DOWNLOAD_CRON, () => {
    console.log('[Cron] Running download...');
    makeApiRequest('/api/utils/download', 'DOWNLOAD');
  });
  console.log(`Download cron scheduled: ${DOWNLOAD_CRON}`);
}

app.use(express.static(FRONTEND_DIR));

app.get('*', (req, res) => {
  res.sendFile(path.join(FRONTEND_DIR, 'index.html'));
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Sub-Store is running on http://0.0.0.0:${PORT}`);
});
