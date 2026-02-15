# Import
```
mongoimport --db lab --collection weathers --file ~/projects/Laboratory-DB-Andreev/Lab8/weather.json
```

# Tasks
### 1) Какова разница между максимальной и минимальной температурой в течение года? 
```
db.weather.aggregate([
  { $match: { year: 2014 } },
  {
    $group: {
      _id: null,
      maxTemp: { $max: "$temperature" },
      minTemp: { $min: "$temperature" }
    }
  },
  {
    $project: {
      _id: 0,
      temperature_range: { $subtract: ["$maxTemp", "$minTemp"] }
    }
  }
])
```

### 2) Какова средняя температура в году, если исключить 10 дней с самой низкой температурой и 10 дней с самой высокой?
```
const dailyTemps = db.weather.aggregate([
  { $match: { year: 2014 } },
  {
    $group: {
      _id: { year: "$year", month: "$month", day: "$day" },
      avgTemp: { $avg: "$temperature" }
    }
  }
]).toArray();

dailyTemps.sort((a, b) => a.avgTemp - b.avgTemp);

const excludedDays = [
  ...dailyTemps.slice(0, 10).map(d => d._id),
  ...dailyTemps.slice(-10).map(d => d._id)
];

db.weather.aggregate([
  {
    $match: {
      year: 2014,
      $nor: excludedDays.map(day => ({
        year: day.year,
        month: day.month,
        day: day.day
      }))
    }
  },
  {
    $group: {
      _id: null,
      average_temperature: { $avg: "$temperature" }
    }
  },
  {
    $project: { _id: 0, average_temperature: 1 }
  }
])
```

### 3) Найти первые 10 записей с самой низкой погодой, когда дул ветер с юга и посчитайте    среднюю температуры для этих записей
```
db.weather.aggregate([
  { $match: { wind_direction: "Южный" } },
  { $sort: { temperature: 1 } },
  { $limit: 10 },
  {
    $group: {
      _id: null,
      average_temp: { $avg: "$temperature" },
      records: { $push: "$$ROOT" }
    }
  },
  {
    $project: {
      _id: 0,
      average_temp: 1,
    }
  }
])
```

### 4) Подсчитайте количество дней, когда шел снег. (Будем считать снегом осадки, которые выпали,  когда температура была ниже нуля)
```
db.weather.aggregate([
  {
    $match: {
      temperature: { $lt: 0 },
      code: { $ne: "CL" } // или: code: { $in: ["SN", "PL", "SG"] }
    }
  },
  {
    $group: {
      _id: { year: "$year", month: "$month", day: "$day" }
    }
  },
  {
    $count: "snowy_days"
  }
])
```

### 5) В течение зимы иногда шел снег, а иногда дождь. Насколько больше (или меньше) выпало осадков в виде снега.
```
db.weather.aggregate([
  {
    $match: {
      month: { $in: [12, 1, 2] },
      code: { $ne: "CL" } // есть осадки
    }
  },
  {
    $addFields: {
      precip_type: {
        $cond: {
          if: { $lt: ["$temperature", 0] },
          then: "snow",
          else: "rain"
        }
      }
    }
  },
  {
    $group: {
      _id: "$precip_type",
      count: { $sum: 1 }
    }
  }
])
```

### 6) Какова вероятность того что в ясный день выпадут осадки? (Предположим, что день считается ясным, если ясная погода фиксируется более чем в 75% случаев)
```
db.weather.aggregate([
  {
    $group: {
      _id: {
        y: "$year",
        m: "$month",
        d: "$day"
      },
      total: { $sum: 1 },
      clear: {
        $sum: { $cond: [{ $eq: ["$code", "CL"] }, 1, 0] }
      },
      hasRain: {
        $sum: { $cond: [{ $ne: ["$code", "CL"] }, 1, 0] }
      }
    }
  },
  {
    $addFields: {
      clearPct: { $divide: ["$clear", "$total"] }
    }
  },
  {
    $match: {
      clearPct: { $gt: 0.75 }
    }
  },
  {
    $group: {
      _id: null,
      totalClearDays: { $sum: 1 },
      daysWithPrecip: {
        $sum: { $cond: [{ $gt: ["$hasRain", 0] }, 1, 0] }
      }
    }
  },
  {
    $project: {
      _id: 0,
      totalClearDays: 1,
      daysWithPrecip: 1,
      probability: {
        $cond: {
          if: { $gt: ["$totalClearDays", 0] },
          then: { $divide: ["$daysWithPrecip", "$totalClearDays"] },
          else: 0
        }
      }
    }
  }
])
```

### 7) Увеличьте температуру на один градус при каждом измерении в нечетный день во время зимы.  На сколько градусов изменилась средняя температура?
```
const originalAvg = db.weather.aggregate([
  {
    $group: {
      _id: null,
      avg: { $avg: "$temperature" }
    }
  }
]).toArray()[0].avg;

const newAvg = db.weather.aggregate([
  {
    $addFields: {
      adjusted_temp: {
        $cond: {
          if: {
            $and: [
              { $in: ["$month", [12, 1, 2]] },
              { $eq: [{ $mod: ["$day", 2] }, 1] }
            ]
          },
          then: { $add: ["$temperature", 1] },
          else: "$temperature"
        }
      }
    }
  },
  {
    $group: {
      _id: null,
      avg: { $avg: "$adjusted_temp" }
    }
  }
]).toArray()[0].avg;

print(`Исходная средняя: ${originalAvg}`);
print(`Новая средняя: ${newAvg}`);
print(`Изменение: ${(newAvg - originalAvg).toFixed(4)} °C`);
```