require('dotenv').config();
const mongoose = require('mongoose');
const http = require('http');

async function triggerSeed() {
  const req = http.request('http://localhost:5000/api/seed', { method: 'POST' }, (res) => {
    let data = '';
    res.on('data', chunk => data += chunk);
    res.on('end', () => {
      console.log('Seed response:', data);
      process.exit(0);
    });
  });

  req.on('error', (e) => {
    console.error('Problem triggering seed API:', e);
    process.exit(1);
  });

  req.end();
}

triggerSeed();
