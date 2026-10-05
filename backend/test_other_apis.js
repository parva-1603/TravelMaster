const apiKey = '3bb29e74bamsh6df9d79706ecae1p1ff4cdjsn76b9637ab4ee';

async function checkApis() {
  const hosts = [
    'irctc1.p.rapidapi.com',
    'irctc-indian-railways.p.rapidapi.com',
    'indian-railway-irctc.p.rapidapi.com',
    'indianrailways.p.rapidapi.com'
  ];

  for (const host of hosts) {
    console.log('--- Testing Host:', host);
    try {
      const res = await fetch(`https://${host}/api/v3/trainBetweenStations?fromStationCode=NDLS&toStationCode=ERS&dateOfJourney=2026-10-15`, {
        headers: {
          'x-rapidapi-key': apiKey,
          'x-rapidapi-host': host
        }
      });
      const data = await res.text();
      console.log('Result:', data.substring(0, 300));
    } catch (e) {
      console.log('Error:', e.message);
    }
  }
}

checkApis();
