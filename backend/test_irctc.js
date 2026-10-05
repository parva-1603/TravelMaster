async function testApi() {
  const apiKey = '3bb29e74bamsh6df9d79706ecae1p1ff4cdjsn76b9637ab4ee';
  const apiHost = 'irctc1.p.rapidapi.com';

  const d = new Date();
  d.setDate(d.getDate() + 7);
  const yyyy = d.getFullYear();
  const mm = String(d.getMonth() + 1).padStart(2, '0');
  const dd = String(d.getDate()).padStart(2, '0');
  const dateStr = `${yyyy}-${mm}-${dd}`;

  console.log('Testing date:', dateStr);

  // Try NDLS to ERS (Ernakulam)
  const url1 = `https://${apiHost}/api/v3/trainBetweenStations?fromStationCode=NDLS&toStationCode=ERS&dateOfJourney=${dateStr}`;
  console.log('Fetching:', url1);
  try {
    const res1 = await fetch(url1, {
      headers: {
        'x-rapidapi-key': apiKey,
        'x-rapidapi-host': apiHost
      }
    });
    const text1 = await res1.text();
    console.log('NDLS -> ERS Result:');
    console.log(text1.substring(0, 1000));
  } catch (err) {
    console.error('Error 1:', err);
  }

  // Try NZM to ERS
  const url2 = `https://${apiHost}/api/v3/trainBetweenStations?fromStationCode=NZM&toStationCode=ERS&dateOfJourney=${dateStr}`;
  console.log('\nFetching:', url2);
  try {
    const res2 = await fetch(url2, {
      headers: {
        'x-rapidapi-key': apiKey,
        'x-rapidapi-host': apiHost
      }
    });
    const text2 = await res2.text();
    console.log('NZM -> ERS Result:');
    console.log(text2.substring(0, 1000));
  } catch (err) {
    console.error('Error 2:', err);
  }
}

testApi();
