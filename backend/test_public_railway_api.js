async function testPublicApis() {
  // Test public IRCTC / Train schedule endpoints
  const endpoints = [
    'https://irctc-api.vercel.app/api/trains?from=NDLS&to=ERS',
    'https://railway-api.vercel.app/api/v1/trains?from=NDLS&to=ERS'
  ];

  for (const ep of endpoints) {
    try {
      console.log('Testing:', ep);
      const res = await fetch(ep);
      const data = await res.text();
      console.log('Response:', data.substring(0, 300));
    } catch (e) {
      console.log('Error:', e.message);
    }
  }
}

testPublicApis();
