const windDirections = ["Северный", "Северо-Восточный", "Восточный", "Юго-Восточный", "Южный", "Юго-Западный", "Западный", "Северо-Западный"];
const weatherCodes = ["CL", "FW", "SC", "BK", "OV", "RA", "SN", "PL"];
const isPrecipitation = { "RA": true, "SN": true, "PL": true };

function isLeapYear(year) {
  return (year % 4 === 0 && year % 100 !== 0) || (year % 400 === 0);
}

function daysInMonth(month, year) {
  const days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  if (month === 2 && isLeapYear(year)) return 29;
  return days[month - 1];
}

function getTempByMonth(month) {
  const avgTemps = [ -5, -4, 2, 9, 15, 20, 22, 21, 16, 10, 3, -2 ];
  const base = avgTemps[month - 1];
  return Math.round(base + (Math.random() * 16 - 8));
}

const year = 2014;
const bulkOps = [];
let count = 0;

for (let month = 1; month <= 12; month++) {
  const days = daysInMonth(month, year);
  for (let day = 1; day <= days; day++) {
    for (let hour = 0; hour < 24; hour++) {
      const temperature = getTempByMonth(month);
      const code = weatherCodes[Math.floor(Math.random() * weatherCodes.length)];
      
      let finalCode = code;
      if (temperature < 0 && isPrecipitation[code]) {
        finalCode = Math.random() > 0.7 ? "PL" : "SN";
      } else if (temperature >= 0 && isPrecipitation[code]) {
        finalCode = "RA";
      }

      const doc = {
        year: year,
        month: month,
        day: day,
        hour: hour,
        temperature: temperature,
        wind_direction: windDirections[Math.floor(Math.random() * windDirections.length)],
        wind: String(Math.floor(Math.random() * 15) + 1),
        code: finalCode,
        clouds: Math.floor(Math.random() * 10),
        visibility: Math.floor(Math.random() * 10) + 1,
        humidity: Math.floor(Math.random() * 40) + 50,
        pressure: Math.floor(Math.random() * 60) + 990
      };

      bulkOps.push({ insertOne: { document: doc } });
      count++;

      if (bulkOps.length === 1000) {
        db.weather.bulkWrite(bulkOps);
        bulkOps.length = 0;
        print(`Inserted ${count} records...`);
      }
    }
  }
}

if (bulkOps.length > 0) {
  db.weather.bulkWrite(bulkOps);
}

for (let h = 0; h < 24; h++) {
  const code = (h === 12 || h === 18) ? "RA" : "CL";
  db.weather.insertOne({
    year: 2014,
    month: 6,
    day: 1,
    hour: h,
    temperature: 20,
    wind_direction: "Южный",
    wind: "2",
    code: code,
    clouds: code === "CL" ? 1 : 7,
    visibility: code === "CL" ? 10 : 5,
    humidity: code === "CL" ? 60 : 85,
    pressure: 1013
  });
}

print(`✅ Успешно вставлено ${count} записей погоды за ${year} год.`);