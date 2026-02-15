# Import
```
mongoimport --db lab --collection restaurants --file ~/projects/Laboratory-DB-Andreev/Lab8/restaurants.json
```

# Tasks
### 1) Выведите все документы коллекции Ресторан в формате: restaurant_id, name, borough и cuisine, вывод    _id    для всех документов исключить.
```
db.restaurants.find(
  {},
  { _id: 0, restaurant_id: 1, name: 1, borough: 1, cuisine: 1 }
)
```

### 2) Выведите    первые 5 ресторанов в алфавитном порядке, которые находятся в районе Bronx.
```
db.restaurants.find(
  { borough: "Bronx" },
  { _id: 0, name: 1 }
).sort({ name: 1 }).limit(5)
```

### 3) Найдите рестораны, которые набрали более 80, но менее 100 баллов.
```
db.restaurants.find(
  { "grades.score": { $gt: 80, $lt: 100 } },
  { _id: 0, name: 1, grades: 1 }
)
```

### 4) Найдите рестораны, которые не относятся к    типу кухни American, получили оценку «А», не расположены    в районе Brooklyn.    Документ должен отображаться в соответствии с кухней в порядке убывания.
```
db.restaurants.find(
  {
    cuisine: { $ne: "American" },
    "grades.grade": "A",
    borough: { $ne: "Brooklyn" }
  },
  { _id: 0, name: 1, cuisine: 1, borough: 1 }
).sort({ cuisine: -1 })
```

### 5) Найдите идентификатор ресторана, название, район и кухню для тех ресторанов, чье название начинается с первых трех букв назвали «Wil»
```
db.restaurants.find(
  { name: /^Wil/ },
  { _id: 0, restaurant_id: 1, name: 1, borough: 1, cuisine: 1 }
)
```

### 6) Найдите    рестораны, которые относятся к району Bronx и готовят American  или Chinese блюда.
```
db.restaurants.find(
  {
    borough: "Bronx",
    cuisine: { $in: ["American", "Chinese"] }
  },
  { _id: 0, name: 1, cuisine: 1 }
)
```

### 7) Найдите идентификатор ресторана, название и оценки для тех ресторанов, которые    «2014-08-11T00: 00: 00Z» набрали 9 баллов за оценку А
``` 
db.restaurants.find(
  {
    grades: {
      $elemMatch: {
        date: new Date("2014-08-11T00:00:00Z"),
        grade: "A",
        score: 9
      }
    }
  },
  { _id: 0, restaurant_id: 1, name: 1, grades: 1 }
)
```

### 8) В каждом районе посчитайте количество ресторанов по каждому виду кухни. Документ должен иметь формат    borough, cuisine, count 
```
db.restaurants.aggregate([
  {
    $group: {
      _id: { borough: "$borough", cuisine: "$cuisine" },
      count: { $sum: 1 }
    }
  },
  {
    $project: {
      _id: 0,
      borough: "$_id.borough",
      cuisine: "$_id.cuisine",
      count: 1
    }
  }
])
```

### 9) В    районе Bronx найдите ресторан с минимальной суммой набранных баллов.
```
db.restaurants.aggregate([
  { $match: { borough: "Bronx" } },
  {
    $addFields: {
      totalScore: { $sum: "$grades.score" }
    }
  },
  { $sort: { totalScore: 1 } },
  { $limit: 1 },
  {
    $project: {
      _id: 0,
      name: 1,
      totalScore: 1
    }
  }
])
```

### 10) Добавьте в коллекцию свой любимый ресторан.
```
db.restaurants.insertOne({
  "address": {
    "building": "123",
    "coord": [37.6173, 55.7558],
    "street": "Тверская улица",
    "zipcode": "125009"
  },
  "borough": "Moscow",
  "cuisine": "Russian",
  "grades": [],
  "name": "My Favorite Bistro",
  "restaurant_id": "99999999"
})
```

### 11) В добавленном ресторане укажите информацию о времени его работы.
```
db.restaurants.updateOne(
  { name: "My Favorite Bistro" },
  { $set: { opening_hours: "09:00–22:00" } }
)
```

### 12) Измените время работы вашего любимого ресторана.
```
db.restaurants.updateOne(
  { name: "My Favorite Bistro" },
  { $set: { opening_hours: "10:00–23:00" } }
)
```